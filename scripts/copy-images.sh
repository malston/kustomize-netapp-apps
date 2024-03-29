#!/usr/bin/env bash

set -eo pipefail

__DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

function die() {
  2>&1 echo "$@"
  exit 1
}

function read_password() {
  local prompt="$1"
  unset password

  while IFS= read -p "$prompt" -r -s -n 1 char; do
    if [[ $char == $'\0' ]]; then
      break
    fi
    prompt='*'
    password+="$char"
  done

  echo "$password"
}
 
function usage {
  echo
  echo "Usage: $0 [-h] [-m <manifest_file>]"
  echo ""
  echo "Uses skopeo to copy images from another registry or local file system into another container registry."
  echo ""
  echo "The options are as follows:"
  echo " -h                   Help. Prints this menu."
  echo " -m <manifest_file>    Path to a manifest. (Defaults to $PWD/manifest.yml)."
  echo ""
  echo "Examples:"
  echo "  $0 -m ./manifest.yml"
  echo
}

function create_harbor_project() {
  local project=$1
  local harbor_hostname=$2
  local harbor_admin_user=$3
  local harbor_admin_password=$4
  local public=${5:-true}

  curl --user "$harbor_admin_user:$harbor_admin_password" -X POST \
    "https://$harbor_hostname/api/v2.0/projects" \
    --insecure \
    --silent \
    -H "Content-type: application/json" \
    --data \
    "{
      \"project_name\": \"$project\",
      \"public\": $public,
      \"metadata\": {
        \"enable_content_trust\": \"false\",
        \"enable_content_trust_cosign\": \"false\",
        \"auto_scan\": \"true\",
        \"severity\": \"hight\",
        \"public\": \"$public\",
        \"reuse_sys_cve_allowlist\": \"true\"
      }
    }" &>/dev/null
}

while getopts ":hm:" opt; do
  case "$opt" in
    h)
      usage
      exit 0
      ;;
    m)
      MANIFEST="$OPTARG"
      ;;
   \?)
      echo "Invalid option."
      usage
      exit 1
      ;;
   esac
done

MANIFEST=${MANIFEST:-"${__DIR}/manifest.yml"}
HARBOR_HOSTNAME=$(yq .manifest.registry "$MANIFEST")
HARBOR_USERNAME=$(yq .manifest.registryUsername "$MANIFEST")

if [[ -z "${HARBOR_PASSWORD}" ]]; then
  HARBOR_PASSWORD=$(read_password "Enter harbor password: ")
  echo ""
fi

echo "${HARBOR_PASSWORD}" | skopeo login --username "${HARBOR_USERNAME}" "${HARBOR_HOSTNAME}" --password-stdin

# Copy local images to registry
for image in $(yq "${MANIFEST}" -o=json | jq -r '.manifest.images[] | @base64'); do
  _jq() {
    echo "${image}" | base64 --decode | jq -r "$1 | select( . != null )"
  }
  name=$(_jq '.name')
  tag=$(_jq '.tag')
  transport=$(_jq '.transport')
  project=$(_jq '.project')
  os=$(_jq '.os')
  arch=$(_jq '.arch')
  variant=$(_jq '.variant')
  options=()

  if [[ -n $os ]]; then
    options=("${options[@]}" --override-os "$os")
  fi

  if [[ -n $arch ]]; then
    options=("${options[@]}" --override-arch "$arch")
  fi

  if [[ -n $variant ]]; then
    options=("${options[@]}" --override-variant "$variant")
  fi

  create_harbor_project "$project" "$HARBOR_HOSTNAME" "$HARBOR_USERNAME" "$HARBOR_PASSWORD"

  case $transport in
    "docker")
        src_image="docker://${name}:${tag}"
        # Remove the project name from the name variable
        dest_name="${name/$project\//}"
        dest_image="${project}/${dest_name}:${tag}"
        if [[ $tag =~ ^sha ]]; then
          src_image="docker://${name}@${tag}"
          dest_image="${project}/${name}@${tag}"
        fi
        skopeo --insecure-policy copy "$src_image" \
            "docker://${HARBOR_HOSTNAME}/$dest_image" \
            --dest-creds "${HARBOR_USERNAME}:${HARBOR_PASSWORD}" \
            "${options[@]}"
      ;;
    "docker-archive")
      path=$(_jq '.path')
      skopeo --insecure-policy copy "docker-archive:${path}" \
          "docker://${HARBOR_HOSTNAME}/${project}/${name}:${tag}" \
          --dest-creds "${HARBOR_USERNAME}:${HARBOR_PASSWORD}" \
          "${options[@]}"
      ;;
    "oci-archive")
      path=$(_jq '.path')
      skopeo --insecure-policy copy "oci-archive:${path}" \
          "docker://${HARBOR_HOSTNAME}/${project}/${name}:${tag}" \
          --dest-creds "${HARBOR_USERNAME}:${HARBOR_PASSWORD}" \
          "${options[@]}"
      ;;
    "tarball")
      path=$(_jq '.path')
      skopeo --insecure-policy copy "tarball:${path}" \
           "docker://${HARBOR_HOSTNAME}/${project}/${name}" \
            --dest-creds "${HARBOR_USERNAME}:${HARBOR_PASSWORD}" \
            "${options[@]}"
      ;;
    *)
      die "Format '$transport' not supported"
      ;;
  esac
done

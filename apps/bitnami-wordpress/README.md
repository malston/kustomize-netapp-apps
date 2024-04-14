# Example: Bitnami Wordpress Helm Chart

This directory contains the Kubernetes manifest files of the WordPress and MariaDB using the [Bitnami Helm Chart](https://github.com/bitnami/charts/tree/main/bitnami/wordpress).

## Transfer Images

Download images from Docker and transfer them to Harbor

```sh
../../scripts/copy-images.sh -m images.yml
```

## Deploy

Apply based upon your environment
`istio` is used for ingress and `nas-performance` is used for the storage class

- **dev**

    ```sh
    ./kustomize.sh apply dev-nas-performance
    ```

    ```sh
    ./kustomize.sh apply dev-nas-ultra
    ```

- **prod**

    ```sh
    ./kustomize.sh apply prod
    ```

## Login

Get login credentials:

```sh
echo "username: user"
echo "password: $(kubectl get secret --namespace wordpress wordpress -o jsonpath="{.data.wordpress-password}" | base64 -d)"
```

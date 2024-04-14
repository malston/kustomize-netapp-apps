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
    ./run.sh apply dev-nas-performance
    ```

    ```sh
    ./run.sh apply dev-nas-ultra
    ```

- **prod**

    ```sh
    ./run.sh apply prod
    ```

## Login

Login by running

```sh
echo "username: user"
echo "password: $(kubectl get secret --namespace wordpress wordpress -o jsonpath="{.data.wordpress-password}" | base64 -d)"
```

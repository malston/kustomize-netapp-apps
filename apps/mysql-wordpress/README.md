# Example: WordPress and MySQL on Kubernetes

This directory contains the Kubernetes manifest files of the WordPress and
MySQL [tutorial](https://kubernetes.io/docs/tutorials/stateful-application/mysql-wordpress-persistent-volume/) for Kubernetes.

## Transfer Images

Download images from Docker and transfer them to Harbor

    ../../scripts/copy-images.sh -m images.yml

## Deploy

Apply based upon your choice of storage

- thin-disk

    ```sh
    clusterDomain=$CLUSTER kubectl apply -k ./thin-disk
    ```

- nas-standard

    ```sh
    clusterDomain=$CLUSTER kubectl apply -k ./nas-standard
    ```

- nas-performance

    ```sh
    clusterDomain=$CLUSTER kubectl apply -k ./nas-performance
    ```

- nas-extreme

    ```sh
    clusterDomain=$CLUSTER kubectl apply -k ./nas-extreme
    ```

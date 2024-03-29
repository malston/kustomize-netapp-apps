# Kustomized Applications using NetApp Storage

## Guestbook with MongoDB or Redis

This [app](./apps/guestbook/README.md) creates a `Deployment` using Trident provisioned `PersistentVolume` using one of the Trident provided `StorageClass` options.

## Wordpress with MySQL

This [app](./apps/mysql-wordpress/README.md) creates a `Deployment` using Trident provisioned `PersistentVolume` using one of the Trident provided `StorageClass` options.

## Wordpress from Bitnami Helm Chart

This [app](./apps/bitnami-wordpress/README.md) creates a `StatefulSet` using Trident provisioned `PersistentVolume` using one of the Trident provided `StorageClass` options.

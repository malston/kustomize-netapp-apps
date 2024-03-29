# Applications using NetApp Storage

## Guestbook with MongoDB or Redis

This [app](./guestbook/README.md) creates a `Deployment` using Trident provisioned `PersistentVolume` using one of the Trident provided `StorageClass` options.

## Wordpress with MySQL

This [app](./mysql-wordpress/README.md) creates a `Deployment` using Trident provisioned `PersistentVolume` using one of the Trident provided `StorageClass` options.

## Wordpress from Bitnami Helm Chart

This [app](./bitnami-wordpress/README.md) creates a `StatefulSet` using Trident provisioned `PersistentVolume` using one of the Trident provided `StorageClass` options.

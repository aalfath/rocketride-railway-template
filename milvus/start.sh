#!/bin/sh
# Railway wrapper for Milvus standalone: gives the volume to the image's "milvus"
# user (Railway volumes are root-owned), then runs Milvus as that user.
set -eu

DATA=/var/lib/milvus
uid="$(id -u milvus)"; gid="$(id -g milvus)"
if [ "$(stat -c %u "$DATA")" != "$uid" ]; then
  echo "railway-milvus: giving $DATA to milvus ($uid:$gid)"
  chown -R "$uid:$gid" "$DATA"
fi
[ -f /milvus/configs/user.yaml ] || printf '# Extra config to override default milvus.yaml\n' > /milvus/configs/user.yaml
chown "$uid:$gid" /milvus/configs/user.yaml

for v in ETCD_ENDPOINTS MINIO_ADDRESS MINIO_ACCESS_KEY_ID MINIO_SECRET_ACCESS_KEY; do
  eval "val=\${$v:-}"
  if [ -z "$val" ]; then echo "railway-milvus: $v is empty" >&2; exit 1; fi
done

# setpriv aborts in this image (jemalloc LD_PRELOAD); runuser keeps the environment.
exec runuser -u milvus -- milvus run standalone

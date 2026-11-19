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

# On a fresh deploy etcd and MinIO may still be starting, and Milvus exits if they
# don't answer. Wait up to 3 minutes for each, then start anyway.
wait_for() {
  i=0
  until curl -fsS -o /dev/null --max-time 3 "$2"; do
    i=$((i + 1))
    if [ "$i" -ge 60 ]; then echo "railway-milvus: $1 not answering yet; starting anyway" >&2; return 0; fi
    sleep 3
  done
  echo "railway-milvus: $1 is up"
}
wait_for etcd "http://$ETCD_ENDPOINTS/health"
wait_for MinIO "http://$MINIO_ADDRESS/minio/health/live"

# setpriv aborts in this image (jemalloc LD_PRELOAD); runuser keeps the environment.
exec runuser -u milvus -- milvus run standalone

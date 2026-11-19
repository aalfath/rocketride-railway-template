# etcd, Milvus's metadata store. Official image (etcd's own registry), pinned by
# version and digest. The image has no shell, so everything is set through ETCD_* env.
FROM gcr.io/etcd-development/etcd:v3.5.36@sha256:134632eca07999d6e642a3ef115ccc253c34d9d93be04f85be074f72aa8ac406

# Same settings as Milvus's standalone docker-compose.yml. Data lives in a subfolder
# of the /etcd volume (a fresh volume holds lost+found).
ENV ETCD_DATA_DIR=/etcd/data \
    ETCD_LISTEN_CLIENT_URLS=http://[::]:2379 \
    ETCD_AUTO_COMPACTION_MODE=revision \
    ETCD_AUTO_COMPACTION_RETENTION=1000 \
    ETCD_QUOTA_BACKEND_BYTES=4294967296 \
    ETCD_SNAPSHOT_COUNT=50000

EXPOSE 2379
CMD ["/usr/local/bin/etcd"]

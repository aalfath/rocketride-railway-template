# Milvus standalone for RocketRide, with external etcd and MinIO (upstream's
# deployments/docker/standalone layout). Official image, pinned by version and digest.
FROM milvusdb/milvus:v3.0.6@sha256:6c606011b3d9124487344b80434d98094624ef359e8a33715263fd1206772069

ENV DEPLOY_MODE=STANDALONE \
    MINIO_REGION=us-east-1

USER root
COPY --chmod=755 start.sh /usr/local/bin/railway-milvus-start
EXPOSE 19530 9091
ENTRYPOINT ["/tini", "--", "/usr/local/bin/railway-milvus-start"]

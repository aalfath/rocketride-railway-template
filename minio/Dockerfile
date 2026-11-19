# MinIO, Milvus's object storage. Milvus's own MinIO image (the one its standalone
# docker-compose.yml uses), pinned by version and digest.
FROM milvusdb/minio:RELEASE.2024-12-18T13-15-44Z@sha256:1dce27c494a16bae114774f1cec295493f3613142713130c2d22dd5696be6ad3

EXPOSE 9000
CMD ["minio", "server", "/minio_data", "--address", ":9000"]

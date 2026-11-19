# RocketRide engine (server-v3.6.0) for Railway.
# Official image, pinned by version and digest. Bump both together.
FROM ghcr.io/rocketride-org/rocketride-engine:3.6.0@sha256:ccb906861322f967a5c896940f2ef6bdc80898fee9ac866c473d921e1eb9b6cc

USER root
# psql only runs `CREATE EXTENSION IF NOT EXISTS vector` on the bundled Postgres at start.
RUN apt-get update \
 && apt-get install -y --no-install-recommends postgresql-client \
 && rm -rf /var/lib/apt/lists/*

# Keep the account store (projects, deployed apps) on the /opt/data volume.
# Upstream's default is ~/.rocketlib/store, which a redeploy would wipe.
ENV RR_STORE_URL=filesystem:///opt/data/store

COPY --chmod=755 start.sh /usr/local/bin/railway-rocketride-start
EXPOSE 5565
ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/railway-rocketride-start"]

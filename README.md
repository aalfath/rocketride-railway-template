[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/rocketride?utm_medium=integration&utm_source=button&utm_campaign=rocketride)

# RocketRide on Railway

One-click Railway template for [RocketRide](https://github.com/rocketride-org/rocketride-server), the open-source (MIT) AI pipeline engine with a visual builder, 50+ nodes, TypeScript/Python SDKs and an MCP endpoint. It deploys the engine with the data stores upstream's Docker stack bundles: PostgreSQL with pgvector, and Milvus with its etcd and MinIO.

| Service | Built from | What it does | Volume |
| --- | --- | --- | --- |
| `RocketRide` | `rocketride/` → `ghcr.io/rocketride-org/rocketride-engine:3.6.0` | Engine, web UI and WebSocket API (port 5565, public) | `/opt/data` (projects, deployed apps, task data) |
| `Postgres` | Railway PostgreSQL (has pgvector) | Vector store for the **PostgreSQL (pgvector)** node | Railway's Postgres volume |
| `Milvus` | `milvus/` → `milvusdb/milvus:v3.0.6` | Vector database for the **Milvus** node | `/var/lib/milvus` |
| `etcd` | `etcd/` → `gcr.io/etcd-development/etcd:v3.5.36` | Milvus metadata store | `/etcd` |
| `MinIO` | `minio/` → `milvusdb/minio:RELEASE.2024-12-18T13-15-44Z` | Milvus object storage | `/minio_data` |

Every image is pinned by version **and** digest in its folder's `Dockerfile`. Only `RocketRide` gets a public domain; the data stores are reachable only on Railway's private network.

## Variables

All of them are filled in for you; the deploy form asks for nothing.

| Service | Variable | Value |
| --- | --- | --- |
| RocketRide | `ROCKETRIDE_APIKEY` | Generated secret. The UI, SDKs, VS Code extension and MCP clients sign in with it. The start script refuses to run without it, because an engine with no key accepts anyone. |
| RocketRide | `ROCKETRIDE_POSTGRES_*` | References to the `Postgres` service (host, port, user, password, database) |
| RocketRide | `ROCKETRIDE_MILVUS_HOST`, `ROCKETRIDE_MILVUS_PORT` | `Milvus` private domain and `19530` |
| RocketRide | `PORT` | `5565` |
| Milvus | `ETCD_ENDPOINTS`, `MINIO_ADDRESS`, `MINIO_ACCESS_KEY_ID`, `MINIO_SECRET_ACCESS_KEY` | References to `etcd` and `MinIO` |
| MinIO | `MINIO_ROOT_USER`, `MINIO_ROOT_PASSWORD` | Generated secrets |
| etcd | `ETCD_ADVERTISE_CLIENT_URLS` | `http://${{RAILWAY_PRIVATE_DOMAIN}}:2379` |

RocketRide passes only `ROCKETRIDE_`-prefixed variables into pipelines (`${ROCKETRIDE_…}` in a node's config). Add your model providers' keys to the `RocketRide` service the same way, for example `ROCKETRIDE_OPENAI_KEY`.

## After deploy

1. Open the `RocketRide` service's public URL and sign in with the value of `ROCKETRIDE_APIKEY` (service → Variables).
2. Point SDKs, the CLI or the VS Code extension at `wss://YOUR-DOMAIN` with the same key.
3. In a pipeline, set the **PostgreSQL (pgvector)** node to host `${ROCKETRIDE_POSTGRES_HOST}`, user `${ROCKETRIDE_POSTGRES_USER}`, password `${ROCKETRIDE_POSTGRES_PASSWORD}`, database `${ROCKETRIDE_POSTGRES_DATABASE}`; or the **Milvus** node (profile "Your own Milvus server") to host `${ROCKETRIDE_MILVUS_HOST}`, port `19530`.

## What the wrappers do

- `rocketride/start.sh`: stops if `ROCKETRIDE_APIKEY` is empty, gives the root-owned Railway volume to the engine's user (uid 1000), runs `CREATE EXTENSION IF NOT EXISTS vector` on the bundled Postgres, then starts the engine on `$PORT`. The Dockerfile sets `RR_STORE_URL=filesystem:///opt/data/store` so projects live on the volume (upstream's default is the home folder, which a redeploy wipes).
- `milvus/start.sh`: gives `/var/lib/milvus` to the image's `milvus` user and runs `milvus run standalone` against the external etcd and MinIO, as in upstream's `deployments/docker/standalone`.
- `etcd/` and `minio/`: the same settings as Milvus's standalone `docker-compose.yml`.

## Updates

Railway notifies everyone who deployed this template when a change is merged to `main` here. Each change gets a `CHANGELOG.md` entry (breaking changes first); read it before you apply an update. Data stays on the volumes across updates.

`test/compose.yml` runs the same stack locally (`docker compose -f test/compose.yml up -d --build`).

Independent community packaging; not affiliated with RocketRide or Aparavi Software AG.

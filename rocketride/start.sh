#!/bin/sh
# Railway wrapper for the RocketRide engine: prepares the volume, makes sure the
# bundled Postgres has pgvector, then runs the engine as the image's user (uid 1000).
set -eu

if [ -z "${ROCKETRIDE_APIKEY:-}" ]; then
  echo "railway-rocketride: ROCKETRIDE_APIKEY is empty; refusing to start an engine that accepts anyone" >&2
  exit 1
fi

# Railway volumes are root-owned; the engine refuses to start unless uid 1000 can write /opt/data.
mkdir -p /opt/data/store
if [ "$(stat -c %u /opt/data)" != "1000" ] || [ "$(stat -c %u /opt/data/store)" != "1000" ]; then
  echo "railway-rocketride: giving /opt/data to rocketride (1000:1000)"
  chown -R 1000:1000 /opt/data
fi

# The PostgreSQL (pgvector) node needs the vector extension in its database.
if [ -n "${ROCKETRIDE_POSTGRES_HOST:-}" ]; then
  export PGHOST="$ROCKETRIDE_POSTGRES_HOST" PGPORT="${ROCKETRIDE_POSTGRES_PORT:-5432}" \
    PGUSER="${ROCKETRIDE_POSTGRES_USER:-postgres}" PGPASSWORD="${ROCKETRIDE_POSTGRES_PASSWORD:-}" \
    PGDATABASE="${ROCKETRIDE_POSTGRES_DATABASE:-postgres}" PGCONNECT_TIMEOUT=5
  i=0
  until psql -qAtc 'CREATE EXTENSION IF NOT EXISTS vector' >/dev/null 2>&1; do
    i=$((i + 1))
    if [ "$i" -ge 24 ]; then
      echo "railway-rocketride: could not enable pgvector on $PGHOST yet; the engine starts anyway" >&2
      break
    fi
    sleep 5
  done
  [ "$i" -lt 24 ] && echo "railway-rocketride: pgvector is enabled on $PGHOST/$PGDATABASE"
  unset PGHOST PGPORT PGUSER PGPASSWORD PGDATABASE PGCONNECT_TIMEOUT
fi

cd /opt/rocketride
exec runuser -u rocketride -- ./engine ./ai/eaas.py --host=0.0.0.0 --port="${PORT:-5565}"

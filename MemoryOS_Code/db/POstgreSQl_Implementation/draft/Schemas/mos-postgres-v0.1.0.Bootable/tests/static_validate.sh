#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BOOT="$ROOT/docker/initdb/000000_bootstrap.sql"
for f in "$ROOT"/migrations/*.sql; do
  test -s "$f" || { echo "EMPTY: $f"; exit 1; }
done
for expected in 000001_extensions.sql 000002_schemas.sql 000003_types.sql 000004_identity.sql 000005_events.sql 000006_memory.sql 000007_provenance.sql 000008_knowledge.sql 000009_cognition.sql 000010_procedure.sql 000011_planning.sql 000012_execution.sql 000013_retrieval.sql 000014_embedding.sql 000015_projection.sql 000016_graph.sql 000017_cache.sql 000018_network.sql 000019_telemetry.sql 000020_security.sql 000021_constraints_triggers.sql 000022_indexes.sql 000023_seed.sql; do
  grep -q "$expected" "$BOOT" || { echo "BOOTSTRAP MISSING: $expected"; exit 1; }
done
# Ensure no obvious accidental bootstrap path typo remains.
if grep -q '/docker-entrypoint/initdb' "$BOOT"; then echo 'BAD BOOTSTRAP PATH'; exit 1; fi
# Ensure immutable-event enforcement exists.
grep -q 'events_reject_update' "$ROOT/migrations/000021_constraints_triggers.sql"
grep -q 'events_reject_delete' "$ROOT/migrations/000021_constraints_triggers.sql"
echo 'Static MOS migration validation passed.'

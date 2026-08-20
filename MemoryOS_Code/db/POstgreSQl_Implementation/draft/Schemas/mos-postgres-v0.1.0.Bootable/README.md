# MOS PostgreSQL v0.1.0

Bootable PostgreSQL reference implementation for the Memory Operating System.

## Start

```bash
docker compose up -d
docker compose logs -f mos-postgres
```

Connect:

```bash
psql postgresql://mos:mos_dev_password@localhost:5432/mos
```

Validate:

```bash
docker exec -i mos-postgres psql -U mos -d mos < tests/validate.sql
```

The included password is for local development only. Change it before any non-development deployment.

Events are append-only and protected by database triggers. Derived projections (graph, embeddings, cache) never become authoritative memory.

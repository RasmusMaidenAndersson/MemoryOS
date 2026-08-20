# MOS V005 Knowledge + TerminusDB Projection Contract

This package implements the refined knowledge version semantics for MOS PostgreSQL
v0.1 and defines the PostgreSQL → TerminusDB graph boundary.

The important invariant is:

    Fact identity ≠ Fact version ≠ Current knowledge state

The old fact version remains immutable and addressable. A newer version becomes the
current state without deleting historical information.

Files:

- `migrations/V005__knowledge.sql`
- `migrations/V006__add_operation_provenance_fks.sql`
- `docs/FACT_VERSION_MODEL.md`
- `docs/TERMINUSDB_PROJECTION_CONTRACT_v0.1.md`

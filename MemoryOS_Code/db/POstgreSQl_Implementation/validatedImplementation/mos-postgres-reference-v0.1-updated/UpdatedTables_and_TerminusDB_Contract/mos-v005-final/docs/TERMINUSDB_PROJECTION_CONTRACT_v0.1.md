# MOS PostgreSQL → TerminusDB Projection Contract v0.1

## Status

Normative architecture contract for the MOS graph projection layer.

## 1. Authority boundary

PostgreSQL is the authoritative transactional store for MOS cognitive state.
TerminusDB is a derived semantic graph projection.

TerminusDB MUST NOT become an independent source of truth for MOS facts.

A graph-side discovery may generate a proposal, but authoritative knowledge changes
must return to MOS as a governed operation that creates a new assertion/fact version.

## 2. Why TerminusDB fits this role

TerminusDB's published architecture describes a revision-oriented graph database with
WOQL as its query language and an RDF/OWL-based graph model. Its technical material
also describes change-set/layer based revision-control mechanisms and commit metadata.
Those properties make it a strong candidate for the MOS relationship/version-history
projection layer.

MOS does not depend on TerminusDB-specific semantics in the Core specification.
The contract only requires equivalent graph capabilities from a conforming backend.

## 3. Canonical identity

MOS UUIDs remain canonical.

Recommended graph identifiers:

    urn:mos:<object-type>:<uuid>

Examples:

    urn:mos:entity:<uuid>
    urn:mos:fact:<uuid>
    urn:mos:fact-version:<uuid>
    urn:mos:assertion:<uuid>
    urn:mos:principal:<uuid>

The graph backend's internal identifiers MUST NOT replace MOS identifiers.

## 4. Authoritative objects projected

The initial graph projection includes:

- Principals
- Agents
- Entities
- Facts
- Fact Versions
- Assertions
- Evidence references
- Policies
- Intents
- Goals
- Decisions
- Procedures
- Resources
- Environments
- Predictions

Large raw payloads, credentials, telemetry, caches, and operational-only records
remain PostgreSQL/object-storage concerns unless a later projection requires them.

## 5. Fact identity and version semantics

A `knowledge.facts.fact_id` represents stable semantic identity.

A `knowledge.fact_versions.fact_version_id` represents an immutable state/version.

The graph MUST model both.

Required relationships:

    Fact --hasVersion--> FactVersion
    Fact --hasCurrentVersion--> FactVersion
    FactVersion --supersedes--> FactVersion

A newer fact version MUST NOT delete its predecessors.

Example:

    Fact F123
       |
       +-- v1  superseded
       +-- v2  superseded
       +-- v3  current

Normal current-state retrieval resolves through `current_fact_version_id` or the
corresponding Knowledge State. Historical queries explicitly traverse versions.

## 6. Assertion and evidence projection

Assertions represent what a source/actor asserted.

Evidence represents supporting material.

Required relationships:

    Assertion --assertedBy--> Principal
    Assertion --derivedFrom--> Event
    Assertion --supportedBy--> Evidence
    Assertion --supports--> FactVersion

This preserves the distinction between source assertion and MOS-maintained belief.

## 7. Knowledge state projection

`knowledge.knowledge_states` represents the currently effective interpretation for a
subject/state type.

The graph may materialize a convenient `current` view, but it MUST retain enough
information to reconstruct historical versions.

Current state is a projection; historical fact versions are authoritative history.

## 8. Event-driven projection

The graph worker consumes MOS events including:

- entity.created
- assertion.created
- fact.created
- fact.version.created
- knowledge_state.changed
- conflict.created
- decision.created
- policy.changed

Each projection operation MUST be idempotent.

The projection record MUST retain:

- source event ID
- source object ID
- source version
- source operation ID where available
- graph revision/commit identifier
- projection worker identity/version
- projected_at

## 9. Commit boundary and consistency

The PostgreSQL transaction is the authoritative commit boundary.

Graph projection is asynchronous:

    PostgreSQL transaction
          ↓
        event
          ↓
    projection worker
          ↓
    TerminusDB commit

Graph state MAY temporarily lag PostgreSQL.

A failed graph projection MUST NOT roll back already committed authoritative
PostgreSQL state.

## 10. Rebuildability

The graph MUST be rebuildable from PostgreSQL authoritative state plus retained
MOS events.

This requirement prevents graph corruption from becoming permanent cognitive loss.

## 11. Query responsibilities

Use PostgreSQL for:

- exact current-state reads
- transactions
- provenance lookup
- authorization
- resource accounting
- temporal structured queries
- authoritative writes

Use pgvector for:

- semantic candidate generation
- similarity search

Use TerminusDB for:

- multi-hop traversal
- relationship exploration
- graph-oriented causal exploration
- graph revision inspection

The Attention Gateway selects the cheapest sufficient strategy.

## 12. Performance rule

Do not query every backend for every request.

Typical escalation:

    cache
      ↓
    PostgreSQL exact/structured
      ↓
    pgvector semantic
      ↓
    TerminusDB graph
      ↓
    hybrid retrieval
      ↓
    expensive model-assisted reasoning

The Resource/Economy and Attention layers may adapt this order according to latency,
confidence, cost, locality, and resource availability.

## 13. Projection safety

TerminusDB MUST NOT directly mutate PostgreSQL facts.

Graph changes must be treated as derived state or explicit proposals.

A proposal becomes authoritative only after a MOS operation creates the corresponding
assertion/fact version and provenance record.

## 14. Audit chain

For every graph revision, MOS SHOULD be able to answer:

- which event caused it?
- which operation caused it?
- which worker/version projected it?
- which PostgreSQL object/version was the source?
- which TerminusDB revision/commit contains it?

## 15. Compliance

A conforming graph projection MUST preserve:

- stable MOS identity
- immutable fact history
- assertion/evidence provenance
- current-state semantics
- idempotency
- rebuildability
- authorization boundaries
- auditability
- eventual-consistency transparency

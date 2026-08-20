# MOS PostgreSQL Reference Schema v0.1 — Cross-Spec Validation Report

**Assessment:** RC1 is **not yet ready to freeze** as MOS PostgreSQL Reference Schema v0.1.0.

The existing implementation is a useful bootstrapping draft, but the schema does not yet represent the full stabilized MOS Core + Storage + API + Worker + Attention + Network architecture.

## 1. Immediate Identity/Foundation finding

The intended foundation:

```text
Foundation
  -> Identity
      -> Namespace
      -> Principal
          -> Agent Identity
              -> Agent
```

is **not fully implemented**.

Current draft has:

```text
identity.agents
identity.identities
identity.agent_identities
```

but is missing:

```text
identity.namespaces
identity.principals
identity.principal_identities
identity.agent_principals
```

### Canonical semantics

- **Namespace**: administrative/security scope in which principals and resources exist.
- **Principal**: authorization subject: human, organization, service, agent-owning subject, etc.
- **Identity**: authentication/identity assertion bound to a principal.
- **Agent**: cognitive runtime/actor.
- **Agent Identity binding**: relationship connecting an agent to its principal and authentication identities.

These concepts must remain distinct.

## 2. Critical blockers

### B1 — Event partitioning breaks canonical event identity

The current `event.events` table uses:

```text
PRIMARY KEY (event_id, recorded_at)
```

because it is range-partitioned by `recorded_at`.

MOS Core, however, defines stable globally unique event identity. Making `(event_id, recorded_at)` the primary key means `event_id` alone is not unique at the database level.

**Decision:** Do not partition `event.events` in v0.1. Keep:

```text
PRIMARY KEY (event_id)
```

and use BRIN/B-tree temporal indexes. Revisit physical partitioning after benchmarks.

### B2 — Version numbers exist without version history

Several tables have `version BIGINT`, but there is no authoritative version-history model.

Need:

```text
system.object_versions
```

with source object, version, operation, actor, timestamp, and immutable snapshot/delta semantics.

### B3 — Intent and Decision are absent

RFC-0006 is a core RFC, but there are no persistent:

```text
planning.intents
planning.decisions
planning.decision_alternatives
planning.commitments
```

This is a major omission.

### B4 — Resource model is absent

RFC-0007 requires persistent resource cognition. Missing:

```text
resource.resource_types
resource.resources
resource.allocations
resource.consumptions
resource.cost_models
```

### B5 — Communication memory is absent

RFC-0008 requires persistent communication semantics. Missing:

```text
communication.messages
communication.delegations
communication.sync_operations
communication.message_participants
```

### B6 — Evaluation/reflection storage is incomplete

RFC-0011 requires persistent evaluation and improvement. Missing:

```text
evaluation.evaluations
evaluation.metrics
evaluation.measurements
reflection.reflections
reflection.lessons
reflection.improvement_proposals
```

### B7 — Governance is incomplete

Policies and constraints are first-class Meta-Cognitive Elements, but the current schema contains only permissions/grants.

Missing:

```text
governance.policies
governance.policy_versions
governance.constraints
governance.approvals
governance.policy_evaluations
```

### B8 — World model is absent

RFC-0013 requires persistent environments/world state. Missing:

```text
world.environments
world.objects
world.states
world.observations
world.simulations
world.predictions
world.processes
```

### B9 — Retrieval/attention persistence is incomplete

The current retrieval schema only stores documents/chunks.

Missing the actual Attention Gateway state needed by the API/spec:

```text
retrieval.requests
retrieval.runs
retrieval.candidates
retrieval.activations
retrieval.contexts
retrieval.context_items
retrieval.feedback
```

### B10 — Principal/authority semantics are too weak

`security.authority_records` currently uses polymorphic `object_type/object_id` and `identity_id`, but there is no proper Principal/Namespace foundation.

Authority must be grounded in:

```text
Principal
Namespace
Permission
Policy
Grant
Delegation
```

### B11 — Model identity is conflated

`cognition.operations.model_id` points toward embedding model identity, while reasoning models are a different semantic object.

Need a generic:

```text
system.models
```

with specialized model capability metadata; embedding models can reference it.

### B12 — Provenance is missing from several foundational objects

Identity, namespace, principal, agent, policy, decision, and procedure objects need explicit provenance/version semantics or a consistent common object-history mechanism.

## 3. Important non-blocking refinements

### R1 — Cache is correctly non-authoritative

Keep cache separate from memory truth.

### R2 — Graph is correctly derived

Graph edges must retain source fact/assertion references.

### R3 — Embeddings are correctly derived

Embeddings must reference source objects and model versions.

### R4 — JSONB policy is correct

Keep core semantic fields typed; reserve JSONB for extension metadata.

### R5 — `ON DELETE RESTRICT` is the correct default for authoritative cognition

Avoid cascading deletion through knowledge/provenance graphs.

### R6 — AGE should remain optional

The MOS semantic graph must work using ordinary relational tables. Native graph extensions are implementation optimizations.

## 4. Canonical storage dependency model

```text
Namespace
  |
  v
Principal
  |
  +--> Identity
  |
  +--> Agent
          |
          v
       Operations
          |
          v
        Events
          |
          v
     Observations
          |
          v
       Evidence
          |
          v
      Assertions
          |
          v
         Facts
          |
          v
    Knowledge State
      /    |     \
     v     v      v
  Graph  Vector  Search
```

Action loop:

```text
Intent
  -> Decision
  -> Commitment
  -> Plan
  -> Task
  -> Execution
  -> Action
  -> Tool Call
  -> Outcome Event
  -> Observation
  -> Evaluation
  -> Reflection
  -> Learning
```

## 5. Identity/Foundation target

The first reference-schema artifact should therefore be:

```text
MOS PostgreSQL Reference Schema v0.1 — Part I

Foundation
Identity
Namespace
Principal
Agent Identity
```

The minimum tables should be:

```text
system.schema_migrations
system.models
system.workers

identity.namespaces
identity.principals
identity.identities
identity.principal_identities
identity.agents
identity.agent_principals
identity.agent_identities
```

Every applicable object should define:

- UUID identity
- lifecycle state
- namespace
- provenance
- version semantics
- created/updated timestamps
- actor/authority semantics
- explicit foreign keys
- restrictive deletion behavior

## 6. Versioning target

Versioned objects should use a consistent pattern:

```text
object_id
version
valid_from
valid_until
created_at
operation_id
created_by_principal_id
```

plus immutable history in:

```text
system.object_versions
```

The current row represents the current state; the history table preserves prior states.

## 7. Final assessment

The RC1 schema is **not missing a few cosmetic tables**. It currently implements only a subset of the stabilized MOS architecture.

It should therefore be retained as:

```text
MOS PostgreSQL Bootstrap RC1
```

and not frozen as:

```text
MOS PostgreSQL Reference Schema v0.1.0
```

The correct next implementation step is to rebuild the migration sequence around the canonical dependency order, beginning with the Foundation → Namespace → Principal → Identity → Agent Identity layer, then adding events, provenance, knowledge, cognition, planning, resource, communication, evaluation, governance, world model, retrieval, and derived projections.

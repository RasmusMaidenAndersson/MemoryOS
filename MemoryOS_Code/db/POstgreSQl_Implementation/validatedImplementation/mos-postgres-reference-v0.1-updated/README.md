# MOS PostgreSQL Reference Schema v0.1

Canonical dependency-ordered PostgreSQL reference schema for Memory Operating System (MOS) v0.1.

This rebuild supersedes the earlier RC1 layout. It is designed from the stabilized MOS Core, Storage, API, Worker, Attention/Reasoning, and Network specifications.

## Migration order

- V001 Foundation: Namespace, Principal, Identity, Credentials, Agent, Agent Identity, Version Registry
- V002 Events: immutable event log, event links
- V003 Provenance: Sources, Evidence, Provenance Links
- V004 Memory: Entities, Observations, Episodes
- V005 Knowledge: Assertions, Facts, Knowledge State, Conflicts
- V006 Cognition: Operations, Reasoning Runs, Evidence Sets, Working Memory, Contexts
- V007 Governance: Domains, Policies, Policy Versions, Constraints, Permissions, Grants, Authority, Approvals
- V008 Agency: Intents, Decisions, Commitments
- V009 Resources: Resources, Allocations, Consumption
- V010 Planning & Execution: Goals, Plans, Milestones, Tasks, Dependencies, Executions, Actions, Tool Calls
- V011 Communication: Messages, Delegations, Synchronizations
- V012 World Model: Environments, World Objects, World States, Simulations, Predictions
- V013 Retrieval: Documents, Chunks, Retrieval Requests/Runs/Candidates, Activations
- V014 Representations: Embedding Models, Embeddings, Projections, Graph Nodes/Edges
- V015 Runtime: Cache, Network Nodes/Delivery, Telemetry
- V016 Integrity: indexes, triggers, immutable-event guard, derived-state guard, validation views/functions

## Design rules frozen for v0.1

1. Events are immutable.
2. Authoritative objects are never silently deleted; lifecycle transitions are preferred.
3. Namespace -> Principal -> Identity -> Agent is the identity hierarchy.
4. Assertions are source claims; Facts are accepted semantic knowledge.
5. Evidence is first-class and supports explainability.
6. Knowledge State is distinct from an individual Fact.
7. Graphs, embeddings, summaries, indexes, and caches are derived representations.
8. Object identity and version identity are distinct.
9. Core semantics are typed columns; JSONB is for extensible metadata/payloads.
10. Foreign-key integrity is preferred; polymorphic references require MOS-level validation.
11. PostgreSQL is the reference backend, not the MOS semantic contract.

## Status

This package is the canonical schema candidate for MOS PostgreSQL v0.1.0. A live PostgreSQL boot test is still required before freezing the migrations as final.

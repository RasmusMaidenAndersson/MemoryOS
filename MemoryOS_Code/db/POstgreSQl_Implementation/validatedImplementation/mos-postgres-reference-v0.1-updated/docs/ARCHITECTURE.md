# MOS PostgreSQL Reference Architecture v0.1

```text
Namespace
  -> Principal
    -> Identity
      -> Agent
        -> Agent Identity

Event
  -> Observation
    -> Evidence
      -> Assertion
        -> Fact
          -> Knowledge State
            -> Derived Projections

Intent
  -> Decision
    -> Commitment
      -> Goal
        -> Plan
          -> Task
            -> Execution
              -> Action
                -> Tool Call
                  -> Event

Retrieval Request
  -> Retrieval Run
    -> Candidates
      -> Activations
        -> Context / Working Memory
```

Authoritative data and derived representations are intentionally separated.
Graph, embeddings, cache, search/ranking outputs and other projections may be rebuilt from authoritative state.

General architecture:
MOS
 │
Authoritative
state
 │
 ▼
PostgreSQL
 │
events
 │
 ▼
Graph Projection
Worker
 │
 ▼
TerminusDB
 │
┌──────┼──────┐
▼      ▼      ▼
traversal causal history
queries   graph     graph

TerminusDB is the semantic graph, not a second independed copy of the whole relational database.
It should represent this such as: 
Entity
Fact
FactVersion
Assertion
Evidence
Principal
Agent
Policy
Decision
Goal
Procedure
Resource
Environment
Prediction

And relationships such as. 
ASSERTED_BY
SUPPORTED_BY
CONTRADICTS
DERIVED_FROM
SUPERSEDES
HAS_VERSION
HAS_CURRENT_VERSION
CREATED_BY
EVALUATED_BY
GOVERNED_BY
DEPENDS_ON
USES
OWNS
CAUSES
LOCATED_IN
DELEGATED_TO

The projection contract explicitly requires every graph revision to remain traceable back to the PostgreSQL event/operation/object/version that produced it.

Retrival the becomes very powerful, the attention gateway can choose the cheapest most sufficent backend.
Simple exact fact
    → PostgreSQL

Semantic similarity
    → pgvector

Relationship traversal
    → TerminusDB

Complex question
    → PostgreSQL
      + pgvector
      + TerminusDB
      + temporal filtering
      + evidence ranking

That aligns directly with our RFC-0007 resource economy and RFC-0014 activation model: don't perform expensive graph traversal or model reasoning when a cheap exact lookup is enough.

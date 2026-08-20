# MOS Fact Version Model v0.1

## Stable identity

`knowledge.facts.fact_id` is a stable semantic identity.

It does not contain mutable semantic content.

## Immutable history

`knowledge.fact_versions` contains the actual semantic content of each version.

A version is append-only and immutable.

## Current knowledge

`knowledge.facts.current_fact_version_id` points to the active version.

`knowledge.knowledge_states.current_fact_version_id` represents the current semantic
state used by higher-level retrieval/planning contexts.

## Update example

Initial:

    F1
      └── V1: project uses MongoDB

New evidence arrives:

    F1
      ├── V1: project uses MongoDB       [superseded]
      └── V2: project uses PostgreSQL    [current]

No DELETE or UPDATE of V1 occurs.

## Retrieval behavior

Default/current queries follow the current pointer.

Historical queries explicitly request:

- fact version
- temporal validity
- historical knowledge state
- or a graph revision

## Why this matters

This gives MOS both:

1. efficient current-state retrieval;
2. complete historical/provenance reconstruction.

The two use cases do not compete with each other.

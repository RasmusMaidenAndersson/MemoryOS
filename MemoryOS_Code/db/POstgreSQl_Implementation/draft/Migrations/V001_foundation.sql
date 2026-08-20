-- ============================================================
-- MOS PostgreSQL Foundation
-- Migration: V001
-- MOS Storage Specification v0.1
-- ============================================================

BEGIN;

-- ------------------------------------------------------------
-- Extensions
-- ------------------------------------------------------------

CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS vector;


-- ------------------------------------------------------------
-- MOS schemas
-- ------------------------------------------------------------

CREATE SCHEMA IF NOT EXISTS identity;
CREATE SCHEMA IF NOT EXISTS event;
CREATE SCHEMA IF NOT EXISTS memory;
CREATE SCHEMA IF NOT EXISTS provenance;
CREATE SCHEMA IF NOT EXISTS knowledge;
CREATE SCHEMA IF NOT EXISTS graph;
CREATE SCHEMA IF NOT EXISTS cognition;
CREATE SCHEMA IF NOT EXISTS planning;
CREATE SCHEMA IF NOT EXISTS procedure;
CREATE SCHEMA IF NOT EXISTS execution;
CREATE SCHEMA IF NOT EXISTS embedding;
CREATE SCHEMA IF NOT EXISTS retrieval;
CREATE SCHEMA IF NOT EXISTS cache;
CREATE SCHEMA IF NOT EXISTS network;
CREATE SCHEMA IF NOT EXISTS telemetry;
CREATE SCHEMA IF NOT EXISTS auth;
CREATE SCHEMA IF NOT EXISTS system;


-- ------------------------------------------------------------
-- Lifecycle
-- ------------------------------------------------------------

CREATE TYPE system.lifecycle_status AS ENUM (
    'active',
    'archived',
    'superseded',
    'expired'
);


-- ------------------------------------------------------------
-- Provenance
-- ------------------------------------------------------------

CREATE TYPE provenance.source_type AS ENUM (
    'user',
    'agent',
    'system',
    'tool',
    'document',
    'database',
    'api',
    'web',
    'sensor',
    'inference',
    'import',
    'unknown'
);


-- ------------------------------------------------------------
-- Confidence semantics
-- ------------------------------------------------------------

CREATE TYPE system.confidence_basis AS ENUM (
    'explicit',
    'observed',
    'derived',
    'inferred',
    'aggregated',
    'speculative',
    'unknown'
);


-- ------------------------------------------------------------
-- Migration registry
-- ------------------------------------------------------------

CREATE TABLE system.schema_versions (
    migration_id TEXT PRIMARY KEY,

    version INTEGER NOT NULL,

    description TEXT NOT NULL,

    applied_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT schema_versions_version_positive
        CHECK (version > 0)
);


-- ------------------------------------------------------------
-- Record migration
-- ------------------------------------------------------------

INSERT INTO system.schema_versions (
    migration_id,
    version,
    description
)
VALUES (
    'V001',
    1,
    'MOS PostgreSQL Foundation'
);


COMMIT;

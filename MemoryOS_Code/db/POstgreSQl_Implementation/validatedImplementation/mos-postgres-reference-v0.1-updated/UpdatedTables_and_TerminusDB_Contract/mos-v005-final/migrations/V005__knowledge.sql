BEGIN;

-- MOS PostgreSQL Reference Schema v0.1
-- V005: Knowledge model with immutable fact versions.
--
-- Design rule:
--   knowledge.facts       = stable semantic identity
--   knowledge.fact_versions = immutable historical content
--   knowledge.knowledge_states = current semantic interpretation/projection
--
-- A fact is never overwritten. A new version is appended.

CREATE SCHEMA IF NOT EXISTS knowledge;

CREATE TABLE knowledge.facts (
  fact_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  status system.lifecycle_status NOT NULL DEFAULT 'active',
  current_version BIGINT NOT NULL DEFAULT 0 CHECK (current_version >= 0),
  current_fact_version_id UUID,

  retired_at TIMESTAMPTZ,
  retired_reason TEXT,

  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb
);

CREATE TABLE knowledge.fact_versions (
  fact_version_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fact_id UUID NOT NULL
    REFERENCES knowledge.facts(fact_id) ON DELETE RESTRICT,

  version_number BIGINT NOT NULL CHECK (version_number > 0),
  previous_fact_version_id UUID
    REFERENCES knowledge.fact_versions(fact_version_id) ON DELETE RESTRICT,

  subject_entity_id UUID NOT NULL
    REFERENCES memory.entities(entity_id) ON DELETE RESTRICT,
  predicate TEXT NOT NULL,
  object_entity_id UUID
    REFERENCES memory.entities(entity_id) ON DELETE RESTRICT,
  value JSONB,

  confidence NUMERIC(5,4) NOT NULL
    CHECK (confidence BETWEEN 0 AND 1),
  confidence_basis TEXT,

  valid_from TIMESTAMPTZ,
  valid_until TIMESTAMPTZ,
  recorded_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  created_by_principal_id UUID
    REFERENCES identity.principals(principal_id) ON DELETE RESTRICT,
  created_by_operation_id UUID,
  supersession_reason TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  CHECK (object_entity_id IS NOT NULL OR value IS NOT NULL),
  CHECK (valid_until IS NULL OR valid_from IS NULL OR valid_until >= valid_from),
  UNIQUE (fact_id, version_number)
);

ALTER TABLE knowledge.facts
  ADD CONSTRAINT facts_current_version_fk
  FOREIGN KEY (current_fact_version_id)
  REFERENCES knowledge.fact_versions(fact_version_id)
  ON DELETE RESTRICT;

ALTER TABLE knowledge.facts
  ADD CONSTRAINT facts_current_version_consistency
  CHECK (
    (current_version = 0 AND current_fact_version_id IS NULL)
    OR
    (current_version > 0 AND current_fact_version_id IS NOT NULL)
  );

CREATE TABLE knowledge.fact_version_assertions (
  fact_version_id UUID NOT NULL
    REFERENCES knowledge.fact_versions(fact_version_id) ON DELETE RESTRICT,
  assertion_id UUID NOT NULL
    REFERENCES knowledge.assertions(assertion_id) ON DELETE RESTRICT,
  support_type TEXT NOT NULL,
  weight NUMERIC(5,4)
    CHECK (weight BETWEEN 0 AND 1),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (fact_version_id, assertion_id)
);

CREATE TABLE knowledge.knowledge_states (
  knowledge_state_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  subject_type TEXT NOT NULL,
  subject_id UUID NOT NULL,
  state_type TEXT NOT NULL,

  current_fact_version_id UUID
    REFERENCES knowledge.fact_versions(fact_version_id) ON DELETE RESTRICT,

  current_version BIGINT NOT NULL DEFAULT 0 CHECK (current_version >= 0),
  confidence NUMERIC(5,4)
    CHECK (confidence BETWEEN 0 AND 1),
  confidence_basis TEXT,

  status system.lifecycle_status NOT NULL DEFAULT 'active',
  determined_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  determined_by_operation_id UUID,

  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  UNIQUE (subject_type, subject_id, state_type),
  CHECK (
    (current_version = 0 AND current_fact_version_id IS NULL)
    OR
    (current_version > 0 AND current_fact_version_id IS NOT NULL)
  )
);

CREATE OR REPLACE FUNCTION knowledge.advance_fact_current_version()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE knowledge.facts
     SET current_version = NEW.version_number,
         current_fact_version_id = NEW.fact_version_id,
         updated_at = now()
   WHERE fact_id = NEW.fact_id
     AND NEW.version_number > current_version;

  RETURN NEW;
END;
$$;

CREATE TRIGGER fact_versions_advance_current
AFTER INSERT ON knowledge.fact_versions
FOR EACH ROW
EXECUTE FUNCTION knowledge.advance_fact_current_version();

CREATE OR REPLACE FUNCTION knowledge.reject_fact_version_mutation()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  RAISE EXCEPTION
    'MOS fact version % is immutable; append a new version instead',
    OLD.fact_version_id
    USING ERRCODE = '55000';
END;
$$;

CREATE TRIGGER fact_versions_reject_update
BEFORE UPDATE ON knowledge.fact_versions
FOR EACH ROW
EXECUTE FUNCTION knowledge.reject_fact_version_mutation();

CREATE TRIGGER fact_versions_reject_delete
BEFORE DELETE ON knowledge.fact_versions
FOR EACH ROW
EXECUTE FUNCTION knowledge.reject_fact_version_mutation();

CREATE INDEX fact_versions_fact_version_idx
  ON knowledge.fact_versions (fact_id, version_number DESC);

CREATE INDEX fact_versions_subject_predicate_idx
  ON knowledge.fact_versions (subject_entity_id, predicate, version_number DESC);

CREATE INDEX fact_versions_validity_idx
  ON knowledge.fact_versions (valid_from, valid_until);

CREATE INDEX fact_versions_current_source_idx
  ON knowledge.facts (current_fact_version_id)
  WHERE current_fact_version_id IS NOT NULL;

CREATE INDEX knowledge_states_current_fact_idx
  ON knowledge.knowledge_states (current_fact_version_id)
  WHERE current_fact_version_id IS NOT NULL;

-- V005R1 note:
-- created_by_operation_id and determined_by_operation_id intentionally remain
-- UUID references until cognition.operations exists in V006. V006 adds the
-- foreign-key constraints after the dependency becomes available.

INSERT INTO system.schema_migrations(version, description)
VALUES ('V005', 'Knowledge: immutable fact identity, fact versions, current knowledge state')
ON CONFLICT (version) DO UPDATE
SET description = EXCLUDED.description,
    applied_at = now();

COMMIT;

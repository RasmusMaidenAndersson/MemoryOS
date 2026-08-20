CREATE TABLE procedure.skills(
 skill_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), name TEXT NOT NULL, description TEXT,
 confidence NUMERIC(5,4) CHECK(confidence BETWEEN 0 AND 1), success_rate NUMERIC(5,4) CHECK(success_rate BETWEEN 0 AND 1),
 version BIGINT NOT NULL DEFAULT 1 CHECK(version>0), status system.lifecycle_status NOT NULL DEFAULT 'active', created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
 updated_at TIMESTAMPTZ NOT NULL DEFAULT now(), metadata JSONB NOT NULL DEFAULT '{}'::jsonb);
CREATE TABLE procedure.procedures(
 procedure_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), skill_id UUID REFERENCES procedure.skills(skill_id) ON DELETE RESTRICT,
 name TEXT NOT NULL, description TEXT, version BIGINT NOT NULL DEFAULT 1 CHECK(version>0), confidence NUMERIC(5,4) CHECK(confidence BETWEEN 0 AND 1),
 status system.lifecycle_status NOT NULL DEFAULT 'active', created_at TIMESTAMPTZ NOT NULL DEFAULT now(), updated_at TIMESTAMPTZ NOT NULL DEFAULT now());
CREATE TABLE procedure.steps(
 step_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), procedure_id UUID NOT NULL REFERENCES procedure.procedures(procedure_id) ON DELETE RESTRICT,
 sequence_number INTEGER NOT NULL CHECK(sequence_number>0), instruction TEXT NOT NULL, required_tool TEXT, verification TEXT, created_at TIMESTAMPTZ NOT NULL DEFAULT now(), UNIQUE(procedure_id,sequence_number));
CREATE TABLE procedure.failure_modes(
 failure_mode_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), procedure_id UUID NOT NULL REFERENCES procedure.procedures(procedure_id) ON DELETE RESTRICT,
 description TEXT NOT NULL, recovery TEXT, severity TEXT, created_at TIMESTAMPTZ NOT NULL DEFAULT now());

BEGIN;
CREATE SCHEMA world;
CREATE TABLE world.environments(
 environment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), environment_type TEXT NOT NULL, name TEXT NOT NULL,
 status system.lifecycle_status NOT NULL DEFAULT 'active', created_at TIMESTAMPTZ NOT NULL DEFAULT now(), updated_at TIMESTAMPTZ NOT NULL DEFAULT now(), metadata JSONB NOT NULL DEFAULT '{}'::jsonb
);
CREATE TABLE world.objects(
 world_object_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), environment_id UUID REFERENCES world.environments(environment_id) ON DELETE RESTRICT,
 object_type TEXT NOT NULL, name TEXT, status system.lifecycle_status NOT NULL DEFAULT 'active', created_at TIMESTAMPTZ NOT NULL DEFAULT now(), updated_at TIMESTAMPTZ NOT NULL DEFAULT now(), metadata JSONB NOT NULL DEFAULT '{}'::jsonb
);
CREATE TABLE world.states(
 state_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), environment_id UUID NOT NULL REFERENCES world.environments(environment_id) ON DELETE RESTRICT,
 observed_at TIMESTAMPTZ NOT NULL, state JSONB NOT NULL, source_event_id UUID REFERENCES event.events(event_id) ON DELETE RESTRICT, created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TABLE world.simulations(
 simulation_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), environment_id UUID REFERENCES world.environments(environment_id) ON DELETE RESTRICT,
 scenario JSONB NOT NULL, assumptions JSONB NOT NULL DEFAULT '{}'::jsonb, result JSONB,
 confidence NUMERIC(5,4) CHECK(confidence BETWEEN 0 AND 1), created_at TIMESTAMPTZ NOT NULL DEFAULT now(), completed_at TIMESTAMPTZ
);
CREATE TABLE world.predictions(
 prediction_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), environment_id UUID REFERENCES world.environments(environment_id) ON DELETE RESTRICT,
 target_type TEXT NOT NULL, target_id UUID, prediction JSONB NOT NULL, predicted_for TIMESTAMPTZ,
 confidence NUMERIC(5,4) CHECK(confidence BETWEEN 0 AND 1), source_operation_id UUID REFERENCES cognition.operations(operation_id) ON DELETE RESTRICT,
 status TEXT NOT NULL DEFAULT 'active', created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
INSERT INTO system.schema_migrations VALUES('V012','World environments objects states simulations predictions');
COMMIT;

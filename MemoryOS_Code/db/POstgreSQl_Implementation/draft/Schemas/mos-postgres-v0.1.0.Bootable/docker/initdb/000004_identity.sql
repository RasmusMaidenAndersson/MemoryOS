CREATE TABLE identity.agents(
 agent_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), name TEXT NOT NULL, agent_type TEXT NOT NULL,
 status system.lifecycle_status NOT NULL DEFAULT 'active', created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
 updated_at TIMESTAMPTZ NOT NULL DEFAULT now(), metadata JSONB NOT NULL DEFAULT '{}'::jsonb);
CREATE TABLE identity.identities(
 identity_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), identity_type TEXT NOT NULL, external_id TEXT,
 display_name TEXT, created_at TIMESTAMPTZ NOT NULL DEFAULT now(), updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
 metadata JSONB NOT NULL DEFAULT '{}'::jsonb);
CREATE TABLE identity.agent_identities(
 agent_id UUID NOT NULL REFERENCES identity.agents(agent_id) ON DELETE RESTRICT,
 identity_id UUID NOT NULL REFERENCES identity.identities(identity_id) ON DELETE RESTRICT,
 relationship TEXT NOT NULL, created_at TIMESTAMPTZ NOT NULL DEFAULT now(), PRIMARY KEY(agent_id,identity_id));

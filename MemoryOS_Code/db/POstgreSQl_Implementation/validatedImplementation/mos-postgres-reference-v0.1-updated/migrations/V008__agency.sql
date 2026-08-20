BEGIN;
CREATE TABLE planning.intents(
 intent_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), principal_id UUID REFERENCES identity.principals(principal_id) ON DELETE RESTRICT,
 owner_agent_id UUID REFERENCES identity.agents(agent_id) ON DELETE RESTRICT, intent_type TEXT NOT NULL, purpose TEXT NOT NULL,
 priority NUMERIC(10,4) NOT NULL DEFAULT 0, status TEXT NOT NULL DEFAULT 'active', desired_outcome JSONB,
 constraints JSONB NOT NULL DEFAULT '{}'::jsonb, created_at TIMESTAMPTZ NOT NULL DEFAULT now(), updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TABLE planning.decisions(
 decision_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), intent_id UUID REFERENCES planning.intents(intent_id) ON DELETE RESTRICT,
 agent_id UUID REFERENCES identity.agents(agent_id) ON DELETE RESTRICT, decision_status TEXT NOT NULL DEFAULT 'proposed',
 selected_action JSONB NOT NULL, alternatives JSONB NOT NULL DEFAULT '[]'::jsonb, assumptions JSONB NOT NULL DEFAULT '[]'::jsonb,
 confidence NUMERIC(5,4) CHECK(confidence BETWEEN 0 AND 1), decided_at TIMESTAMPTZ NOT NULL DEFAULT now(), rationale TEXT, created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TABLE planning.commitments(
 commitment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), decision_id UUID NOT NULL REFERENCES planning.decisions(decision_id) ON DELETE RESTRICT,
 principal_id UUID REFERENCES identity.principals(principal_id) ON DELETE RESTRICT, status TEXT NOT NULL DEFAULT 'active',
 committed_at TIMESTAMPTZ NOT NULL DEFAULT now(), expires_at TIMESTAMPTZ, constraints JSONB NOT NULL DEFAULT '{}'::jsonb
);
INSERT INTO system.schema_migrations VALUES('V008','Intents, decisions, commitments');
COMMIT;

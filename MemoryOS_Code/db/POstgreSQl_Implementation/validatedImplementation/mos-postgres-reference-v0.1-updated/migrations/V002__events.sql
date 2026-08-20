BEGIN;
CREATE SCHEMA IF NOT EXISTS event;
CREATE TABLE event.events(
 event_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
 event_type TEXT NOT NULL,
 occurred_at TIMESTAMPTZ NOT NULL,
 recorded_at TIMESTAMPTZ NOT NULL DEFAULT now(),
 actor_principal_id UUID REFERENCES identity.principals(principal_id) ON DELETE RESTRICT,
 agent_id UUID REFERENCES identity.agents(agent_id) ON DELETE RESTRICT,
 causal_event_id UUID REFERENCES event.events(event_id) ON DELETE RESTRICT,
 correlation_id UUID,
 sequence_number BIGINT,
 payload JSONB NOT NULL DEFAULT '{}'::jsonb,
 metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
 CHECK(recorded_at>=occurred_at)
);
CREATE TABLE event.event_links(
 event_link_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
 source_event_id UUID NOT NULL REFERENCES event.events(event_id) ON DELETE RESTRICT,
 target_event_id UUID NOT NULL REFERENCES event.events(event_id) ON DELETE RESTRICT,
 link_type TEXT NOT NULL,
 created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
 UNIQUE(source_event_id,target_event_id,link_type)
);
INSERT INTO system.schema_migrations VALUES('V002','Immutable event foundation');
COMMIT;

CREATE TABLE event.events(
 event_id UUID NOT NULL DEFAULT gen_random_uuid(), event_type TEXT NOT NULL, occurred_at TIMESTAMPTZ NOT NULL,
 recorded_at TIMESTAMPTZ NOT NULL DEFAULT now(), actor_id UUID, agent_id UUID REFERENCES identity.agents(agent_id) ON DELETE RESTRICT,
 session_id UUID, sequence_number BIGINT, payload JSONB NOT NULL DEFAULT '{}'::jsonb,
 metadata JSONB NOT NULL DEFAULT '{}'::jsonb, created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
 PRIMARY KEY(event_id, recorded_at)) PARTITION BY RANGE(recorded_at);
CREATE TABLE event.events_default PARTITION OF event.events DEFAULT;
CREATE TABLE event.event_links(
 event_link_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), source_event_id UUID NOT NULL, source_recorded_at TIMESTAMPTZ NOT NULL,
 target_event_id UUID NOT NULL, target_recorded_at TIMESTAMPTZ NOT NULL, link_type TEXT NOT NULL, created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
 FOREIGN KEY(source_event_id,source_recorded_at) REFERENCES event.events(event_id,recorded_at) ON DELETE RESTRICT,
 FOREIGN KEY(target_event_id,target_recorded_at) REFERENCES event.events(event_id,recorded_at) ON DELETE RESTRICT,
 UNIQUE(source_event_id,target_event_id,link_type));

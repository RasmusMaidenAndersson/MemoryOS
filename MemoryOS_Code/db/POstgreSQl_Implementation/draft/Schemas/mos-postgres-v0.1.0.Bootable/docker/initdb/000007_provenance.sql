CREATE TABLE provenance.sources(
 source_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), source_type TEXT NOT NULL, source_uri TEXT, actor_id UUID,
 agent_id UUID REFERENCES identity.agents(agent_id) ON DELETE RESTRICT, reliability NUMERIC(5,4) CHECK(reliability BETWEEN 0 AND 1),
 created_at TIMESTAMPTZ NOT NULL DEFAULT now(), metadata JSONB NOT NULL DEFAULT '{}'::jsonb);
CREATE TABLE provenance.evidence(
 evidence_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), evidence_type TEXT NOT NULL,
 source_id UUID REFERENCES provenance.sources(source_id) ON DELETE RESTRICT,
 event_id UUID, event_recorded_at TIMESTAMPTZ, content TEXT, content_hash TEXT, captured_at TIMESTAMPTZ NOT NULL,
 created_at TIMESTAMPTZ NOT NULL DEFAULT now(), metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
 FOREIGN KEY(event_id,event_recorded_at) REFERENCES event.events(event_id,recorded_at) ON DELETE RESTRICT,
 CHECK((event_id IS NULL AND event_recorded_at IS NULL) OR (event_id IS NOT NULL AND event_recorded_at IS NOT NULL)));
CREATE TABLE provenance.evidence_links(
 evidence_link_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), evidence_id UUID NOT NULL REFERENCES provenance.evidence(evidence_id) ON DELETE RESTRICT,
 target_type TEXT NOT NULL, target_id UUID NOT NULL, role TEXT NOT NULL, weight NUMERIC(5,4) CHECK(weight BETWEEN 0 AND 1), created_at TIMESTAMPTZ NOT NULL DEFAULT now());

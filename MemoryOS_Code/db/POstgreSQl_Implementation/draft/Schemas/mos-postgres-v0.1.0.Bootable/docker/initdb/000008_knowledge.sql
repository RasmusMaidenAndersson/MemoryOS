CREATE TABLE knowledge.assertions(
 assertion_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), subject_entity_id UUID NOT NULL REFERENCES memory.entities(entity_id) ON DELETE RESTRICT,
 predicate TEXT NOT NULL, object_entity_id UUID REFERENCES memory.entities(entity_id) ON DELETE RESTRICT, value JSONB,
 source_id UUID REFERENCES provenance.sources(source_id) ON DELETE RESTRICT, event_id UUID, event_recorded_at TIMESTAMPTZ,
 asserted_at TIMESTAMPTZ NOT NULL DEFAULT now(), valid_from TIMESTAMPTZ, valid_until TIMESTAMPTZ,
 confidence NUMERIC(5,4) NOT NULL CHECK(confidence BETWEEN 0 AND 1), status system.lifecycle_status NOT NULL DEFAULT 'active', created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
 CHECK(object_entity_id IS NOT NULL OR value IS NOT NULL), CHECK(valid_until IS NULL OR valid_from IS NULL OR valid_until>=valid_from),
 FOREIGN KEY(event_id,event_recorded_at) REFERENCES event.events(event_id,recorded_at) ON DELETE RESTRICT,
 CHECK((event_id IS NULL AND event_recorded_at IS NULL) OR (event_id IS NOT NULL AND event_recorded_at IS NOT NULL)));
CREATE TABLE knowledge.facts(
 fact_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), subject_entity_id UUID NOT NULL REFERENCES memory.entities(entity_id) ON DELETE RESTRICT,
 predicate TEXT NOT NULL, object_entity_id UUID REFERENCES memory.entities(entity_id) ON DELETE RESTRICT, value JSONB,
 confidence NUMERIC(5,4) NOT NULL CHECK(confidence BETWEEN 0 AND 1), status system.lifecycle_status NOT NULL DEFAULT 'active',
 valid_from TIMESTAMPTZ, valid_until TIMESTAMPTZ, recorded_at TIMESTAMPTZ NOT NULL DEFAULT now(), created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
 updated_at TIMESTAMPTZ NOT NULL DEFAULT now(), version BIGINT NOT NULL DEFAULT 1 CHECK(version>0),
 CHECK(object_entity_id IS NOT NULL OR value IS NOT NULL), CHECK(valid_until IS NULL OR valid_from IS NULL OR valid_until>=valid_from));
CREATE TABLE knowledge.fact_assertions(
 fact_id UUID NOT NULL REFERENCES knowledge.facts(fact_id) ON DELETE RESTRICT, assertion_id UUID NOT NULL REFERENCES knowledge.assertions(assertion_id) ON DELETE RESTRICT,
 support_type TEXT NOT NULL, weight NUMERIC(5,4) CHECK(weight BETWEEN 0 AND 1), created_at TIMESTAMPTZ NOT NULL DEFAULT now(), PRIMARY KEY(fact_id,assertion_id));
CREATE TABLE knowledge.knowledge_states(
 knowledge_state_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), subject_type TEXT NOT NULL, subject_id UUID NOT NULL, state_type TEXT NOT NULL,
 current_version BIGINT NOT NULL DEFAULT 1 CHECK(current_version>0), confidence NUMERIC(5,4) CHECK(confidence BETWEEN 0 AND 1),
 status system.lifecycle_status NOT NULL DEFAULT 'active', determined_at TIMESTAMPTZ NOT NULL DEFAULT now(), created_at TIMESTAMPTZ NOT NULL DEFAULT now(), updated_at TIMESTAMPTZ NOT NULL DEFAULT now());
CREATE TABLE knowledge.conflicts(
 conflict_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), conflict_type TEXT NOT NULL, status TEXT NOT NULL DEFAULT 'open', detected_at TIMESTAMPTZ NOT NULL DEFAULT now(), resolved_at TIMESTAMPTZ, resolution TEXT, created_at TIMESTAMPTZ NOT NULL DEFAULT now(), metadata JSONB NOT NULL DEFAULT '{}'::jsonb);
CREATE TABLE knowledge.conflict_items(
 conflict_item_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), conflict_id UUID NOT NULL REFERENCES knowledge.conflicts(conflict_id) ON DELETE RESTRICT,
 assertion_id UUID REFERENCES knowledge.assertions(assertion_id) ON DELETE RESTRICT, fact_id UUID REFERENCES knowledge.facts(fact_id) ON DELETE RESTRICT,
 role TEXT NOT NULL, confidence NUMERIC(5,4) CHECK(confidence BETWEEN 0 AND 1), created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
 CHECK(assertion_id IS NOT NULL OR fact_id IS NOT NULL));

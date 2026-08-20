BEGIN;

CREATE OR REPLACE FUNCTION system.touch_updated_at() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN NEW.updated_at := now(); RETURN NEW; END $$;

DO $$
DECLARE r RECORD;
BEGIN
 FOR r IN
   SELECT table_schema, table_name
   FROM information_schema.columns
   WHERE column_name='updated_at'
     AND table_schema IN('namespace','identity','memory','knowledge','cognition','governance','planning','resources','world','retrieval','projection','graph')
 LOOP
   EXECUTE format('CREATE TRIGGER %I BEFORE UPDATE ON %I.%I FOR EACH ROW EXECUTE FUNCTION system.touch_updated_at()', r.table_name||'_touch_updated_at', r.table_schema, r.table_name);
 END LOOP;
END $$;

CREATE OR REPLACE FUNCTION event.reject_mutation() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN RAISE EXCEPTION 'MOS event % is immutable', OLD.event_id USING ERRCODE='55000'; END $$;
CREATE TRIGGER events_reject_update BEFORE UPDATE ON event.events FOR EACH ROW EXECUTE FUNCTION event.reject_mutation();
CREATE TRIGGER events_reject_delete BEFORE DELETE ON event.events FOR EACH ROW EXECUTE FUNCTION event.reject_mutation();

CREATE OR REPLACE FUNCTION system.prevent_direct_version_decrease() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
 IF NEW.current_version < OLD.current_version THEN RAISE EXCEPTION 'current_version cannot decrease'; END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER facts_version_guard BEFORE UPDATE ON knowledge.facts FOR EACH ROW EXECUTE FUNCTION system.prevent_direct_version_decrease();
CREATE TRIGGER entities_version_guard BEFORE UPDATE ON memory.entities FOR EACH ROW EXECUTE FUNCTION system.prevent_direct_version_decrease();

CREATE OR REPLACE FUNCTION system.validate_embedding_dimension() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE expected INTEGER;
BEGIN
 SELECT dimension INTO expected FROM embedding.models WHERE model_id=NEW.model_id;
 IF expected IS NULL THEN RAISE EXCEPTION 'unknown embedding model %', NEW.model_id; END IF;
 IF expected<>NEW.dimension THEN RAISE EXCEPTION 'embedding dimension % does not match model dimension %', NEW.dimension, expected; END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER embeddings_dimension_guard BEFORE INSERT OR UPDATE ON embedding.embeddings FOR EACH ROW EXECUTE FUNCTION system.validate_embedding_dimension();

CREATE INDEX entities_type_idx ON memory.entities(entity_type);
CREATE INDEX entities_name_trgm_idx ON memory.entities USING gin(canonical_name gin_trgm_ops);
CREATE INDEX aliases_trgm_idx ON memory.entity_aliases USING gin(alias gin_trgm_ops);
CREATE INDEX events_type_time_idx ON event.events(event_type, recorded_at);
CREATE INDEX events_agent_time_idx ON event.events(agent_id, recorded_at);
CREATE INDEX events_causal_idx ON event.events(causal_event_id);
CREATE INDEX facts_subject_predicate_idx ON knowledge.facts(subject_entity_id,predicate);
CREATE INDEX facts_object_predicate_idx ON knowledge.facts(object_entity_id,predicate);
CREATE INDEX facts_active_idx ON knowledge.facts(subject_entity_id,predicate) WHERE status='active';
CREATE INDEX assertions_subject_predicate_idx ON knowledge.assertions(subject_entity_id,predicate);
CREATE INDEX assertions_source_idx ON knowledge.assertions(source_id);
CREATE INDEX operations_agent_time_idx ON cognition.operations(agent_id,started_at);
CREATE INDEX operations_status_idx ON cognition.operations(status);
CREATE INDEX working_memory_agent_idx ON cognition.working_memory(agent_id,updated_at);
CREATE INDEX retrieval_runs_request_idx ON retrieval.runs(request_id,started_at);
CREATE INDEX retrieval_candidates_run_idx ON retrieval.candidates(retrieval_run_id,final_score DESC);
CREATE INDEX retrieval_activations_run_idx ON retrieval.activations(retrieval_run_id,attention_score DESC);
CREATE INDEX graph_edges_from_idx ON graph.edges(from_node_id,relation);
CREATE INDEX graph_edges_to_idx ON graph.edges(to_node_id,relation);
CREATE INDEX embeddings_object_idx ON embedding.embeddings(object_type,object_id);
CREATE INDEX projections_source_idx ON projection.projections(source_type,source_id);
CREATE INDEX cache_expiry_idx ON cache.semantic_cache(expires_at) WHERE expires_at IS NOT NULL;
CREATE INDEX network_delivery_pending_idx ON network.event_delivery(status,created_at) WHERE status='pending';
CREATE INDEX telemetry_worker_time_idx ON telemetry.worker_runs(started_at);
CREATE INDEX telemetry_llm_operation_idx ON telemetry.llm_calls(operation_id,created_at);

CREATE OR REPLACE VIEW system.authoritative_object_counts AS
SELECT 'entity' AS object_type, count(*)::bigint AS count FROM memory.entities
UNION ALL SELECT 'fact', count(*) FROM knowledge.facts
UNION ALL SELECT 'assertion', count(*) FROM knowledge.assertions
UNION ALL SELECT 'event', count(*) FROM event.events
UNION ALL SELECT 'evidence', count(*) FROM provenance.evidence;

CREATE OR REPLACE FUNCTION system.validate_foundation() RETURNS TABLE(check_name TEXT, passed BOOLEAN, detail TEXT)
LANGUAGE sql STABLE AS $$
  SELECT 'foundation_tables'::text,
    (SELECT count(*) FROM information_schema.tables WHERE table_schema='namespace' AND table_name='namespaces')=1
    AND (SELECT count(*) FROM information_schema.tables WHERE table_schema='identity' AND table_name IN('principals','identities','credentials','agents','agent_identities'))=5,
    'Namespace, Principal, Identity, Credentials, Agent, Agent Identity';
$$;

INSERT INTO system.schema_migrations VALUES('V016','Integrity guards, indexes, immutable event policy, validation');
COMMIT;

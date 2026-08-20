\set ON_ERROR_STOP on
DO $$
DECLARE s text;
BEGIN
  FOREACH s IN ARRAY ARRAY['system','identity','event','memory','provenance','knowledge','cognition','procedure','planning','execution','retrieval','embedding','projection','graph','cache','network','telemetry','security'] LOOP
    IF NOT EXISTS (SELECT 1 FROM pg_namespace WHERE nspname=s) THEN RAISE EXCEPTION 'Missing schema %',s; END IF;
  END LOOP;
END $$;
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname='events_reject_update') THEN RAISE EXCEPTION 'Missing event UPDATE protection'; END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname='events_reject_delete') THEN RAISE EXCEPTION 'Missing event DELETE protection'; END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname='embedding' AND indexname='embeddings_vector_cosine_idx') THEN RAISE EXCEPTION 'Missing vector index'; END IF;
END $$;
DO $$
DECLARE eid uuid; ert timestamptz; sid uuid; ent uuid; aid uuid; fid uuid;
BEGIN
  INSERT INTO event.events(event_type,occurred_at,payload) VALUES('validation.test',now(),'{}') RETURNING event_id,recorded_at INTO eid,ert;
  BEGIN UPDATE event.events SET payload='{"tampered":true}' WHERE event_id=eid AND recorded_at=ert; RAISE EXCEPTION 'Event UPDATE unexpectedly succeeded'; EXCEPTION WHEN SQLSTATE '55000' THEN NULL; END;
  BEGIN DELETE FROM event.events WHERE event_id=eid AND recorded_at=ert; RAISE EXCEPTION 'Event DELETE unexpectedly succeeded'; EXCEPTION WHEN SQLSTATE '55000' THEN NULL; END;
  INSERT INTO provenance.sources(source_type,source_uri,reliability) VALUES('validation','mos://validation',1) RETURNING source_id INTO sid;
  INSERT INTO memory.entities(entity_type,canonical_name) VALUES('Concept','MOS') RETURNING entity_id INTO ent;
  INSERT INTO knowledge.assertions(subject_entity_id,predicate,value,source_id,event_id,event_recorded_at,confidence) VALUES(ent,'HAS_STATUS','"validating"',sid,eid,ert,0.99) RETURNING assertion_id INTO aid;
  INSERT INTO knowledge.facts(subject_entity_id,predicate,value,confidence) VALUES(ent,'HAS_STATUS','"validating"',0.99) RETURNING fact_id INTO fid;
  INSERT INTO knowledge.fact_assertions(fact_id,assertion_id,support_type,weight) VALUES(fid,aid,'supports',1);
END $$;
SELECT system.schema_version() AS schema_version;
SELECT 'MOS validation passed' AS result;

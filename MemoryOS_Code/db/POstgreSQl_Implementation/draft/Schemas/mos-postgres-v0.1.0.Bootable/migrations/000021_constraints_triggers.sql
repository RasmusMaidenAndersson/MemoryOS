CREATE OR REPLACE FUNCTION system.touch_updated_at() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN NEW.updated_at := now(); RETURN NEW; END; $$;
DO $$ DECLARE r RECORD; BEGIN
 FOR r IN SELECT n.nspname schema_name,c.relname table_name FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE c.relkind='r' AND n.nspname IN('identity','memory','knowledge','cognition','procedure','planning','retrieval','projection','graph') AND EXISTS(SELECT 1 FROM information_schema.columns col WHERE col.table_schema=n.nspname AND col.table_name=c.relname AND col.column_name='updated_at') LOOP
  EXECUTE format('CREATE TRIGGER %I BEFORE UPDATE ON %I.%I FOR EACH ROW EXECUTE FUNCTION system.touch_updated_at()',r.table_name||'_touch_updated_at',r.schema_name,r.table_name);
 END LOOP; END $$;
CREATE OR REPLACE FUNCTION event.reject_mutation() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN RAISE EXCEPTION 'MOS event % is immutable; events cannot be updated or deleted',OLD.event_id USING ERRCODE='55000'; END; $$;
CREATE TRIGGER events_reject_update BEFORE UPDATE ON event.events FOR EACH ROW EXECUTE FUNCTION event.reject_mutation();
CREATE TRIGGER events_reject_delete BEFORE DELETE ON event.events FOR EACH ROW EXECUTE FUNCTION event.reject_mutation();
CREATE OR REPLACE FUNCTION event.validate_event_times() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN IF NEW.recorded_at<NEW.occurred_at THEN RAISE EXCEPTION 'recorded_at cannot precede occurred_at'; END IF; RETURN NEW; END; $$;
CREATE TRIGGER events_validate_times BEFORE INSERT ON event.events FOR EACH ROW EXECUTE FUNCTION event.validate_event_times();
CREATE OR REPLACE FUNCTION embedding.validate_dimension() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE expected INTEGER; BEGIN SELECT dimension INTO expected FROM embedding.models WHERE model_id=NEW.model_id;
 IF expected IS NULL THEN RAISE EXCEPTION 'embedding model % does not exist',NEW.model_id; END IF;
 IF expected<>NEW.dimension THEN RAISE EXCEPTION 'embedding dimension % does not match model dimension %',NEW.dimension,expected; END IF; RETURN NEW; END; $$;
CREATE TRIGGER embeddings_validate_dimension BEFORE INSERT OR UPDATE ON embedding.embeddings FOR EACH ROW EXECUTE FUNCTION embedding.validate_dimension();
INSERT INTO system.schema_migrations(version) VALUES('0.1.0') ON CONFLICT DO NOTHING;

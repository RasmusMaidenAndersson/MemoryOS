\set ON_ERROR_STOP on
SELECT system.schema_version() AS current_schema_version;

SELECT version, description FROM system.schema_migrations ORDER BY version;

SELECT table_schema, count(*) AS tables
FROM information_schema.tables
WHERE table_schema IN('namespace','identity','event','provenance','memory','knowledge','cognition','governance','security','planning','resources','execution','communication','world','retrieval','embedding','projection','graph','cache','network','telemetry','system')
GROUP BY table_schema ORDER BY table_schema;

SELECT * FROM system.validate_foundation();

DO $$
DECLARE p UUID; n UUID; i UUID; a UUID; e UUID;
BEGIN
  INSERT INTO namespace.namespaces(name,namespace_type) VALUES('test','system') RETURNING namespace_id INTO n;
  INSERT INTO identity.principals(namespace_id,principal_type,canonical_name) VALUES(n,'agent','test-principal') RETURNING principal_id INTO p;
  INSERT INTO identity.identities(principal_id,identity_type,issuer,external_id) VALUES(p,'service','mos-test','test-1') RETURNING identity_id INTO i;
  INSERT INTO identity.agents(principal_id,agent_type,name) VALUES(p,'worker','test-agent') RETURNING agent_id INTO a;
  INSERT INTO identity.agent_identities(agent_id,identity_id,is_primary) VALUES(a,i,true);
  INSERT INTO event.events(event_type,occurred_at,actor_principal_id,agent_id) VALUES('validation.test',now(),p,a) RETURNING event_id INTO e;
  BEGIN
    UPDATE event.events SET payload='{"tampered":true}'::jsonb WHERE event_id=e;
    RAISE EXCEPTION 'immutable event guard failed';
  EXCEPTION WHEN SQLSTATE '55000' THEN NULL;
  END;
  RAISE NOTICE 'MOS foundation validation passed';
END $$;

CREATE TYPE system.lifecycle_status AS ENUM ('active','archived','superseded','expired','quarantined');
CREATE TYPE system.operation_status AS ENUM ('pending','running','completed','failed','cancelled');
CREATE TYPE system.projection_status AS ENUM ('building','active','stale','invalid','retired');
CREATE TABLE system.schema_migrations(version TEXT PRIMARY KEY, applied_at TIMESTAMPTZ NOT NULL DEFAULT now());
CREATE OR REPLACE FUNCTION system.schema_version() RETURNS TEXT LANGUAGE sql STABLE AS $$ SELECT COALESCE(max(version),'0.0.0') FROM system.schema_migrations $$;

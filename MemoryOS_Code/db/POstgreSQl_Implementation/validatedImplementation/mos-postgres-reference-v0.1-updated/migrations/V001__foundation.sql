BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS pg_trgm;

CREATE SCHEMA IF NOT EXISTS system;
CREATE SCHEMA IF NOT EXISTS namespace;
CREATE SCHEMA IF NOT EXISTS identity;

CREATE TYPE system.lifecycle_status AS ENUM ('active','suspended','archived','revoked','superseded','expired','quarantined');
CREATE TYPE system.principal_type AS ENUM ('human','agent','service','organization','device','system');
CREATE TYPE system.operation_status AS ENUM ('pending','running','completed','failed','cancelled');
CREATE TYPE system.projection_status AS ENUM ('building','active','stale','invalid','retired');

CREATE TABLE system.schema_migrations(
 version TEXT PRIMARY KEY,
 description TEXT NOT NULL,
 applied_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE namespace.namespaces(
 namespace_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
 parent_namespace_id UUID REFERENCES namespace.namespaces(namespace_id) ON DELETE RESTRICT,
 name TEXT NOT NULL,
 namespace_type TEXT NOT NULL,
 status system.lifecycle_status NOT NULL DEFAULT 'active',
 created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
 updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
 metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
 CHECK (length(trim(name))>0),
 UNIQUE(parent_namespace_id,name)
);

CREATE TABLE identity.principals(
 principal_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
 namespace_id UUID NOT NULL REFERENCES namespace.namespaces(namespace_id) ON DELETE RESTRICT,
 principal_type system.principal_type NOT NULL,
 canonical_name TEXT NOT NULL,
 status system.lifecycle_status NOT NULL DEFAULT 'active',
 created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
 updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
 metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
 CHECK (length(trim(canonical_name))>0)
);

CREATE TABLE identity.identities(
 identity_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
 principal_id UUID NOT NULL REFERENCES identity.principals(principal_id) ON DELETE RESTRICT,
 identity_type TEXT NOT NULL,
 issuer TEXT,
 external_id TEXT,
 display_name TEXT,
 status system.lifecycle_status NOT NULL DEFAULT 'active',
 created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
 updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
 metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
 UNIQUE(issuer,external_id)
);

CREATE TABLE identity.credentials(
 credential_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
 identity_id UUID NOT NULL REFERENCES identity.identities(identity_id) ON DELETE RESTRICT,
 credential_type TEXT NOT NULL,
 fingerprint TEXT NOT NULL UNIQUE,
 issued_at TIMESTAMPTZ NOT NULL DEFAULT now(),
 expires_at TIMESTAMPTZ,
 status system.lifecycle_status NOT NULL DEFAULT 'active',
 metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
 CHECK(expires_at IS NULL OR expires_at>issued_at)
);

CREATE TABLE identity.agents(
 agent_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
 principal_id UUID NOT NULL REFERENCES identity.principals(principal_id) ON DELETE RESTRICT,
 agent_type TEXT NOT NULL,
 name TEXT NOT NULL,
 runtime_class TEXT,
 status system.lifecycle_status NOT NULL DEFAULT 'active',
 created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
 updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
 metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
 UNIQUE(principal_id,name)
);

CREATE TABLE identity.agent_identities(
 agent_id UUID NOT NULL REFERENCES identity.agents(agent_id) ON DELETE RESTRICT,
 identity_id UUID NOT NULL REFERENCES identity.identities(identity_id) ON DELETE RESTRICT,
 relationship TEXT NOT NULL,
 is_primary BOOLEAN NOT NULL DEFAULT false,
 valid_from TIMESTAMPTZ NOT NULL DEFAULT now(),
 valid_until TIMESTAMPTZ,
 created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
 PRIMARY KEY(agent_id,identity_id),
 CHECK(valid_until IS NULL OR valid_until>=valid_from)
);
CREATE UNIQUE INDEX agent_primary_identity_uq ON identity.agent_identities(agent_id) WHERE is_primary;

CREATE TABLE system.object_versions(
 version_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
 object_type TEXT NOT NULL,
 object_id UUID NOT NULL,
 version_number BIGINT NOT NULL CHECK(version_number>0),
 previous_version_id UUID REFERENCES system.object_versions(version_id) ON DELETE RESTRICT,
 created_by_principal_id UUID REFERENCES identity.principals(principal_id) ON DELETE RESTRICT,
 created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
 change_reason TEXT,
 snapshot JSONB,
 UNIQUE(object_type,object_id,version_number)
);

INSERT INTO system.schema_migrations(version,description) VALUES('V001','Foundation: namespace, principal, identity, credentials, agent identity, version registry');
COMMIT;

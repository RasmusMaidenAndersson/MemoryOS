BEGIN;
CREATE SCHEMA IF NOT EXISTS governance;
CREATE SCHEMA IF NOT EXISTS security;
CREATE TABLE security.domains(
 domain_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
 namespace_id UUID REFERENCES namespace.namespaces(namespace_id) ON DELETE RESTRICT,
 name TEXT NOT NULL UNIQUE,
 parent_domain_id UUID REFERENCES security.domains(domain_id) ON DELETE RESTRICT,
 created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TABLE governance.policies(
 policy_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), policy_type TEXT NOT NULL, name TEXT NOT NULL, description TEXT,
 current_version BIGINT NOT NULL DEFAULT 1 CHECK(current_version>0), status system.lifecycle_status NOT NULL DEFAULT 'active',
 created_at TIMESTAMPTZ NOT NULL DEFAULT now(), updated_at TIMESTAMPTZ NOT NULL DEFAULT now(), metadata JSONB NOT NULL DEFAULT '{}'::jsonb
);
CREATE TABLE governance.policy_versions(
 policy_version_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
 policy_id UUID NOT NULL REFERENCES governance.policies(policy_id) ON DELETE RESTRICT,
 version_number BIGINT NOT NULL CHECK(version_number>0), rule_definition JSONB NOT NULL,
 created_by_principal_id UUID REFERENCES identity.principals(principal_id) ON DELETE RESTRICT,
 created_at TIMESTAMPTZ NOT NULL DEFAULT now(), UNIQUE(policy_id,version_number)
);
CREATE TABLE governance.constraints(
 constraint_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), constraint_type TEXT NOT NULL, name TEXT NOT NULL,
 definition JSONB NOT NULL, status system.lifecycle_status NOT NULL DEFAULT 'active', created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TABLE security.permissions(
 permission_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), resource_type TEXT NOT NULL, action TEXT NOT NULL, UNIQUE(resource_type,action)
);
CREATE TABLE security.grants(
 grant_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), identity_id UUID NOT NULL REFERENCES identity.identities(identity_id) ON DELETE RESTRICT,
 domain_id UUID REFERENCES security.domains(domain_id) ON DELETE RESTRICT,
 permission_id UUID NOT NULL REFERENCES security.permissions(permission_id) ON DELETE RESTRICT,
 created_at TIMESTAMPTZ NOT NULL DEFAULT now(), expires_at TIMESTAMPTZ
);
CREATE TABLE security.authority_records(
 authority_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), object_type TEXT NOT NULL, object_id UUID NOT NULL,
 authority_type TEXT NOT NULL, identity_id UUID NOT NULL REFERENCES identity.identities(identity_id) ON DELETE RESTRICT,
 domain_id UUID REFERENCES security.domains(domain_id) ON DELETE RESTRICT, created_at TIMESTAMPTZ NOT NULL DEFAULT now(), expires_at TIMESTAMPTZ
);
CREATE TABLE governance.approvals(
 approval_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), operation_id UUID REFERENCES cognition.operations(operation_id) ON DELETE RESTRICT,
 requested_by_principal_id UUID REFERENCES identity.principals(principal_id) ON DELETE RESTRICT,
 approved_by_principal_id UUID REFERENCES identity.principals(principal_id) ON DELETE RESTRICT,
 status TEXT NOT NULL DEFAULT 'pending', requested_at TIMESTAMPTZ NOT NULL DEFAULT now(), decided_at TIMESTAMPTZ, reason TEXT
);
INSERT INTO system.schema_migrations VALUES('V007','Governance, security domains, policies, permissions, authority, approvals');
COMMIT;

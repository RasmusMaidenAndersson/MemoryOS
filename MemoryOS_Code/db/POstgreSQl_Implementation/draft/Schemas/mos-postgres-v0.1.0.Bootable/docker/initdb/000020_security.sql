CREATE TABLE security.domains(
 domain_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), name TEXT NOT NULL UNIQUE, parent_domain_id UUID REFERENCES security.domains(domain_id) ON DELETE RESTRICT, created_at TIMESTAMPTZ NOT NULL DEFAULT now());
CREATE TABLE security.permissions(
 permission_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), resource_type TEXT NOT NULL, action TEXT NOT NULL, UNIQUE(resource_type,action));
CREATE TABLE security.grants(
 grant_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), identity_id UUID NOT NULL REFERENCES identity.identities(identity_id) ON DELETE RESTRICT,
 domain_id UUID REFERENCES security.domains(domain_id) ON DELETE RESTRICT, permission_id UUID NOT NULL REFERENCES security.permissions(permission_id) ON DELETE RESTRICT,
 created_at TIMESTAMPTZ NOT NULL DEFAULT now(), expires_at TIMESTAMPTZ);
CREATE TABLE security.authority_records(
 authority_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), object_type TEXT NOT NULL, object_id UUID NOT NULL, authority_type TEXT NOT NULL,
 identity_id UUID NOT NULL REFERENCES identity.identities(identity_id) ON DELETE RESTRICT, domain_id UUID REFERENCES security.domains(domain_id) ON DELETE RESTRICT,
 created_at TIMESTAMPTZ NOT NULL DEFAULT now(), expires_at TIMESTAMPTZ);

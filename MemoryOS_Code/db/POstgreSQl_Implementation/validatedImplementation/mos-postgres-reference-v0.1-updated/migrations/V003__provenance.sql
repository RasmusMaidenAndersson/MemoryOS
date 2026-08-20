BEGIN;
CREATE SCHEMA IF NOT EXISTS provenance;
CREATE TABLE provenance.sources(
 source_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
 principal_id UUID REFERENCES identity.principals(principal_id) ON DELETE RESTRICT,
 source_type TEXT NOT NULL,
 source_uri TEXT,
 reliability NUMERIC(5,4) CHECK(reliability BETWEEN 0 AND 1),
 created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
 metadata JSONB NOT NULL DEFAULT '{}'::jsonb
);
CREATE TABLE provenance.evidence(
 evidence_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
 source_id UUID REFERENCES provenance.sources(source_id) ON DELETE RESTRICT,
 event_id UUID REFERENCES event.events(event_id) ON DELETE RESTRICT,
 evidence_type TEXT NOT NULL,
 content TEXT,
 content_hash TEXT,
 captured_at TIMESTAMPTZ NOT NULL,
 created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
 metadata JSONB NOT NULL DEFAULT '{}'::jsonb
);
CREATE TABLE provenance.evidence_links(
 evidence_link_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
 evidence_id UUID NOT NULL REFERENCES provenance.evidence(evidence_id) ON DELETE RESTRICT,
 target_type TEXT NOT NULL,
 target_id UUID NOT NULL,
 role TEXT NOT NULL,
 weight NUMERIC(5,4) CHECK(weight BETWEEN 0 AND 1),
 created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TABLE provenance.provenance_links(
 provenance_link_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
 source_type TEXT NOT NULL,
 source_id UUID NOT NULL,
 target_type TEXT NOT NULL,
 target_id UUID NOT NULL,
 relationship TEXT NOT NULL,
 created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
INSERT INTO system.schema_migrations VALUES('V003','Sources, evidence, provenance links');
COMMIT;

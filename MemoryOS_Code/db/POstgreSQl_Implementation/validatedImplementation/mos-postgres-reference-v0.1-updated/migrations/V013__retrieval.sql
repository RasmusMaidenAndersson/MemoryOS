BEGIN;
CREATE SCHEMA retrieval;
CREATE TABLE retrieval.documents(
 document_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), source_id UUID REFERENCES provenance.sources(source_id) ON DELETE RESTRICT,
 title TEXT, content_hash TEXT NOT NULL, created_at TIMESTAMPTZ NOT NULL DEFAULT now(), updated_at TIMESTAMPTZ NOT NULL DEFAULT now(), metadata JSONB NOT NULL DEFAULT '{}'::jsonb
);
CREATE TABLE retrieval.chunks(
 chunk_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), document_id UUID NOT NULL REFERENCES retrieval.documents(document_id) ON DELETE RESTRICT,
 sequence_number INTEGER NOT NULL CHECK(sequence_number>=0), content TEXT NOT NULL, content_hash TEXT NOT NULL,
 created_at TIMESTAMPTZ NOT NULL DEFAULT now(), UNIQUE(document_id,sequence_number)
);
CREATE TABLE retrieval.requests(
 request_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), agent_id UUID REFERENCES identity.agents(agent_id) ON DELETE RESTRICT,
 context_id UUID REFERENCES cognition.contexts(context_id) ON DELETE RESTRICT, query TEXT NOT NULL, intent_type TEXT,
 confidence_threshold NUMERIC(5,4) CHECK(confidence_threshold BETWEEN 0 AND 1), max_objects INTEGER, max_tokens INTEGER,
 created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TABLE retrieval.runs(
 retrieval_run_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), request_id UUID NOT NULL REFERENCES retrieval.requests(request_id) ON DELETE RESTRICT,
 strategy JSONB NOT NULL DEFAULT '[]'::jsonb, started_at TIMESTAMPTZ NOT NULL DEFAULT now(), completed_at TIMESTAMPTZ,
 status system.operation_status NOT NULL DEFAULT 'pending', candidate_count INTEGER, activated_count INTEGER, latency_ms BIGINT
);
CREATE TABLE retrieval.candidates(
 candidate_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), retrieval_run_id UUID NOT NULL REFERENCES retrieval.runs(retrieval_run_id) ON DELETE RESTRICT,
 object_type TEXT NOT NULL, object_id UUID NOT NULL, retrieval_method TEXT NOT NULL,
 relevance_score NUMERIC(12,6), confidence_score NUMERIC(12,6), final_score NUMERIC(12,6)
);
CREATE TABLE retrieval.activations(
 activation_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), retrieval_run_id UUID NOT NULL REFERENCES retrieval.runs(retrieval_run_id) ON DELETE RESTRICT,
 object_type TEXT NOT NULL, object_id UUID NOT NULL, attention_score NUMERIC(12,6) NOT NULL,
 activation_reason TEXT, activated_at TIMESTAMPTZ NOT NULL DEFAULT now(), expires_at TIMESTAMPTZ
);
INSERT INTO system.schema_migrations VALUES('V013','Documents chunks retrieval requests runs candidates activations');
COMMIT;

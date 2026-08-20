CREATE TABLE retrieval.documents(
 document_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), source_id UUID REFERENCES provenance.sources(source_id) ON DELETE RESTRICT,
 title TEXT, content_hash TEXT NOT NULL, created_at TIMESTAMPTZ NOT NULL DEFAULT now(), updated_at TIMESTAMPTZ NOT NULL DEFAULT now(), metadata JSONB NOT NULL DEFAULT '{}'::jsonb);
CREATE TABLE retrieval.chunks(
 chunk_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), document_id UUID NOT NULL REFERENCES retrieval.documents(document_id) ON DELETE RESTRICT,
 sequence_number INTEGER NOT NULL CHECK(sequence_number>=0), content TEXT NOT NULL, content_hash TEXT NOT NULL, created_at TIMESTAMPTZ NOT NULL DEFAULT now(), UNIQUE(document_id,sequence_number));

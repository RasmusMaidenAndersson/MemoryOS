CREATE TABLE embedding.models(
 model_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), provider TEXT NOT NULL, name TEXT NOT NULL, version TEXT,
 dimension INTEGER NOT NULL CHECK(dimension>0), metric TEXT NOT NULL DEFAULT 'cosine', created_at TIMESTAMPTZ NOT NULL DEFAULT now(), UNIQUE(provider,name,version));
CREATE TABLE embedding.embeddings(
 embedding_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), object_type TEXT NOT NULL, object_id UUID NOT NULL,
 model_id UUID NOT NULL REFERENCES embedding.models(model_id) ON DELETE RESTRICT, model_version TEXT,
 dimension INTEGER NOT NULL CHECK(dimension>0), vector vector(1024) NOT NULL, created_at TIMESTAMPTZ NOT NULL DEFAULT now(), UNIQUE(object_type,object_id,model_id));

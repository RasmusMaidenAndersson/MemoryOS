BEGIN;
CREATE SCHEMA embedding;
CREATE SCHEMA projection;
CREATE SCHEMA graph;
CREATE TABLE embedding.models(
 model_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), provider TEXT NOT NULL, name TEXT NOT NULL, version TEXT,
 dimension INTEGER NOT NULL CHECK(dimension>0), metric TEXT NOT NULL DEFAULT 'cosine', created_at TIMESTAMPTZ NOT NULL DEFAULT now(), UNIQUE(provider,name,version)
);
CREATE TABLE embedding.embeddings(
 embedding_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), object_type TEXT NOT NULL, object_id UUID NOT NULL,
 model_id UUID NOT NULL REFERENCES embedding.models(model_id) ON DELETE RESTRICT, model_version TEXT,
 dimension INTEGER NOT NULL CHECK(dimension>0), vector vector(1024) NOT NULL, created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
 UNIQUE(object_type,object_id,model_id)
);
CREATE TABLE projection.projections(
 projection_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), projection_type TEXT NOT NULL, source_type TEXT NOT NULL, source_id UUID NOT NULL,
 version BIGINT NOT NULL DEFAULT 1 CHECK(version>0), status system.projection_status NOT NULL DEFAULT 'building',
 created_at TIMESTAMPTZ NOT NULL DEFAULT now(), updated_at TIMESTAMPTZ NOT NULL DEFAULT now(), UNIQUE(projection_type,source_type,source_id,version)
);
CREATE TABLE graph.nodes(
 node_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), entity_id UUID NOT NULL REFERENCES memory.entities(entity_id) ON DELETE RESTRICT,
 projection_version BIGINT NOT NULL DEFAULT 1 CHECK(projection_version>0), created_at TIMESTAMPTZ NOT NULL DEFAULT now(), updated_at TIMESTAMPTZ NOT NULL DEFAULT now(), UNIQUE(entity_id,projection_version)
);
CREATE TABLE graph.edges(
 edge_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), from_node_id UUID NOT NULL REFERENCES graph.nodes(node_id) ON DELETE RESTRICT,
 to_node_id UUID NOT NULL REFERENCES graph.nodes(node_id) ON DELETE RESTRICT, relation TEXT NOT NULL,
 weight NUMERIC(10,4), confidence NUMERIC(5,4) CHECK(confidence BETWEEN 0 AND 1), projection_version BIGINT NOT NULL DEFAULT 1 CHECK(projection_version>0),
 created_at TIMESTAMPTZ NOT NULL DEFAULT now(), updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TABLE graph.edge_sources(
 edge_id UUID NOT NULL REFERENCES graph.edges(edge_id) ON DELETE RESTRICT,
 fact_id UUID REFERENCES knowledge.facts(fact_id) ON DELETE RESTRICT,
 assertion_id UUID REFERENCES knowledge.assertions(assertion_id) ON DELETE RESTRICT,
 PRIMARY KEY(edge_id,fact_id,assertion_id), CHECK(fact_id IS NOT NULL OR assertion_id IS NOT NULL)
);
INSERT INTO system.schema_migrations VALUES('V014','Embedding models, embeddings, projections and graph projections');
COMMIT;

CREATE TABLE graph.nodes(
 node_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), entity_id UUID NOT NULL REFERENCES memory.entities(entity_id) ON DELETE RESTRICT,
 projection_version BIGINT NOT NULL DEFAULT 1 CHECK(projection_version>0), created_at TIMESTAMPTZ NOT NULL DEFAULT now(), updated_at TIMESTAMPTZ NOT NULL DEFAULT now(), UNIQUE(entity_id,projection_version));
CREATE TABLE graph.edges(
 edge_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), from_node_id UUID NOT NULL REFERENCES graph.nodes(node_id) ON DELETE RESTRICT,
 to_node_id UUID NOT NULL REFERENCES graph.nodes(node_id) ON DELETE RESTRICT, relation TEXT NOT NULL, weight NUMERIC(10,4),
 confidence NUMERIC(5,4) CHECK(confidence BETWEEN 0 AND 1), projection_version BIGINT NOT NULL DEFAULT 1 CHECK(projection_version>0),
 created_at TIMESTAMPTZ NOT NULL DEFAULT now(), updated_at TIMESTAMPTZ NOT NULL DEFAULT now());
CREATE TABLE graph.edge_sources(
 edge_id UUID NOT NULL REFERENCES graph.edges(edge_id) ON DELETE RESTRICT,
 fact_id UUID REFERENCES knowledge.facts(fact_id) ON DELETE RESTRICT,
 assertion_id UUID REFERENCES knowledge.assertions(assertion_id) ON DELETE RESTRICT,
 PRIMARY KEY(edge_id,fact_id,assertion_id), CHECK(fact_id IS NOT NULL OR assertion_id IS NOT NULL));

BEGIN;
CREATE SCHEMA cache;
CREATE SCHEMA network;
CREATE SCHEMA telemetry;
CREATE TABLE cache.semantic_cache(
 cache_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), cache_key TEXT NOT NULL UNIQUE, query_hash TEXT NOT NULL, context_hash TEXT NOT NULL,
 result JSONB NOT NULL, created_at TIMESTAMPTZ NOT NULL DEFAULT now(), expires_at TIMESTAMPTZ, hit_count BIGINT NOT NULL DEFAULT 0 CHECK(hit_count>=0), last_hit TIMESTAMPTZ
);
CREATE TABLE network.nodes(
 node_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), node_identity TEXT NOT NULL UNIQUE, node_type TEXT NOT NULL, status TEXT NOT NULL DEFAULT 'active',
 capabilities JSONB NOT NULL DEFAULT '{}'::jsonb, created_at TIMESTAMPTZ NOT NULL DEFAULT now(), last_seen TIMESTAMPTZ, metadata JSONB NOT NULL DEFAULT '{}'::jsonb
);
CREATE TABLE network.event_delivery(
 delivery_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), event_id UUID NOT NULL REFERENCES event.events(event_id) ON DELETE RESTRICT,
 source_node_id UUID REFERENCES network.nodes(node_id) ON DELETE RESTRICT, target_node_id UUID REFERENCES network.nodes(node_id) ON DELETE RESTRICT,
 status TEXT NOT NULL DEFAULT 'pending', attempt_count INTEGER NOT NULL DEFAULT 0 CHECK(attempt_count>=0), created_at TIMESTAMPTZ NOT NULL DEFAULT now(), delivered_at TIMESTAMPTZ
);
CREATE TABLE telemetry.worker_runs(
 run_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), worker_id UUID, worker_version TEXT, started_at TIMESTAMPTZ NOT NULL, completed_at TIMESTAMPTZ,
 status system.operation_status, duration_ms BIGINT CHECK(duration_ms IS NULL OR duration_ms>=0), resource_usage JSONB, created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TABLE telemetry.llm_calls(
 call_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), operation_id UUID REFERENCES cognition.operations(operation_id) ON DELETE RESTRICT, model TEXT NOT NULL,
 tokens_in BIGINT NOT NULL DEFAULT 0 CHECK(tokens_in>=0), tokens_out BIGINT NOT NULL DEFAULT 0 CHECK(tokens_out>=0), latency_ms BIGINT CHECK(latency_ms IS NULL OR latency_ms>=0),
 cost NUMERIC(20,8) CHECK(cost IS NULL OR cost>=0), created_at TIMESTAMPTZ NOT NULL DEFAULT now(), metadata JSONB NOT NULL DEFAULT '{}'::jsonb
);
INSERT INTO system.schema_migrations VALUES('V015','Cache network delivery telemetry');
COMMIT;

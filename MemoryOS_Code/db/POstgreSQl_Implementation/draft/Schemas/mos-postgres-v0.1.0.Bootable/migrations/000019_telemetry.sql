CREATE TABLE telemetry.worker_runs(
 run_id UUID NOT NULL DEFAULT gen_random_uuid(), worker_id UUID, worker_version TEXT, started_at TIMESTAMPTZ NOT NULL, completed_at TIMESTAMPTZ,
 status system.operation_status, duration_ms BIGINT CHECK(duration_ms IS NULL OR duration_ms>=0), resource_usage JSONB, created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
 PRIMARY KEY(run_id,started_at)) PARTITION BY RANGE(started_at);
CREATE TABLE telemetry.worker_runs_default PARTITION OF telemetry.worker_runs DEFAULT;
CREATE TABLE telemetry.llm_calls(
 call_id UUID NOT NULL DEFAULT gen_random_uuid(), operation_id UUID REFERENCES cognition.operations(operation_id) ON DELETE RESTRICT, model TEXT NOT NULL,
 tokens_in BIGINT NOT NULL DEFAULT 0 CHECK(tokens_in>=0), tokens_out BIGINT NOT NULL DEFAULT 0 CHECK(tokens_out>=0), latency_ms BIGINT CHECK(latency_ms IS NULL OR latency_ms>=0),
 cost NUMERIC(20,8) CHECK(cost IS NULL OR cost>=0), created_at TIMESTAMPTZ NOT NULL DEFAULT now(), metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
 PRIMARY KEY(call_id,created_at)) PARTITION BY RANGE(created_at);
CREATE TABLE telemetry.llm_calls_default PARTITION OF telemetry.llm_calls DEFAULT;

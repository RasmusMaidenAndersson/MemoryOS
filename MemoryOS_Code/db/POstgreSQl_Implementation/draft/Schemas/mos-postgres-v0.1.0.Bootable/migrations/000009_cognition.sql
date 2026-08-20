CREATE TABLE cognition.operations(
 operation_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), operation_type TEXT NOT NULL, actor_id UUID,
 agent_id UUID REFERENCES identity.agents(agent_id) ON DELETE RESTRICT, worker_id UUID, model_id UUID,
 started_at TIMESTAMPTZ NOT NULL DEFAULT now(), completed_at TIMESTAMPTZ, status system.operation_status NOT NULL DEFAULT 'pending',
 result JSONB, created_at TIMESTAMPTZ NOT NULL DEFAULT now(), metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
 CHECK(completed_at IS NULL OR completed_at>=started_at));
CREATE TABLE cognition.operation_inputs(
 operation_id UUID NOT NULL REFERENCES cognition.operations(operation_id) ON DELETE RESTRICT, object_type TEXT NOT NULL, object_id UUID NOT NULL, role TEXT NOT NULL,
 PRIMARY KEY(operation_id,object_type,object_id,role));
CREATE TABLE cognition.operation_outputs(
 operation_id UUID NOT NULL REFERENCES cognition.operations(operation_id) ON DELETE RESTRICT, object_type TEXT NOT NULL, object_id UUID NOT NULL, role TEXT NOT NULL,
 PRIMARY KEY(operation_id,object_type,object_id,role));
CREATE TABLE cognition.reasoning_runs(
 reasoning_run_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), operation_id UUID NOT NULL REFERENCES cognition.operations(operation_id) ON DELETE RESTRICT,
 model TEXT NOT NULL, model_version TEXT, prompt_version TEXT, policy_version TEXT, started_at TIMESTAMPTZ NOT NULL, completed_at TIMESTAMPTZ,
 status system.operation_status NOT NULL DEFAULT 'pending', CHECK(completed_at IS NULL OR completed_at>=started_at));
CREATE TABLE cognition.working_memory(
 working_memory_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), agent_id UUID NOT NULL REFERENCES identity.agents(agent_id) ON DELETE RESTRICT,
 session_id UUID, capacity INTEGER NOT NULL DEFAULT 200 CHECK(capacity>0), created_at TIMESTAMPTZ NOT NULL DEFAULT now(), updated_at TIMESTAMPTZ NOT NULL DEFAULT now(), expires_at TIMESTAMPTZ);
CREATE TABLE cognition.working_memory_items(
 item_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), working_memory_id UUID NOT NULL REFERENCES cognition.working_memory(working_memory_id) ON DELETE RESTRICT,
 object_type TEXT NOT NULL, object_id UUID NOT NULL, priority NUMERIC(10,4) NOT NULL DEFAULT 0, attention_score NUMERIC(10,4) NOT NULL DEFAULT 0,
 added_at TIMESTAMPTZ NOT NULL DEFAULT now(), last_accessed TIMESTAMPTZ, expires_at TIMESTAMPTZ);
CREATE TABLE cognition.evidence_sets(
 evidence_set_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), operation_id UUID REFERENCES cognition.operations(operation_id) ON DELETE RESTRICT,
 purpose TEXT NOT NULL, created_at TIMESTAMPTZ NOT NULL DEFAULT now());
CREATE TABLE cognition.evidence_set_items(
 evidence_set_id UUID NOT NULL REFERENCES cognition.evidence_sets(evidence_set_id) ON DELETE RESTRICT,
 evidence_id UUID NOT NULL REFERENCES provenance.evidence(evidence_id) ON DELETE RESTRICT,
 rank INTEGER, weight NUMERIC(5,4) CHECK(weight BETWEEN 0 AND 1), PRIMARY KEY(evidence_set_id,evidence_id));

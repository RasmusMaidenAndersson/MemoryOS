CREATE TABLE execution.executions(
 execution_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), task_id UUID REFERENCES planning.tasks(task_id) ON DELETE RESTRICT,
 agent_id UUID REFERENCES identity.agents(agent_id) ON DELETE RESTRICT, started_at TIMESTAMPTZ, completed_at TIMESTAMPTZ,
 status system.operation_status NOT NULL DEFAULT 'pending', result JSONB, created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
 CHECK(completed_at IS NULL OR started_at IS NULL OR completed_at>=started_at));
CREATE TABLE execution.actions(
 action_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), execution_id UUID NOT NULL REFERENCES execution.executions(execution_id) ON DELETE RESTRICT,
 action_type TEXT NOT NULL, status system.operation_status NOT NULL DEFAULT 'pending', started_at TIMESTAMPTZ, completed_at TIMESTAMPTZ, result JSONB,
 CHECK(completed_at IS NULL OR started_at IS NULL OR completed_at>=started_at));
CREATE TABLE execution.tool_calls(
 tool_call_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), action_id UUID NOT NULL REFERENCES execution.actions(action_id) ON DELETE RESTRICT,
 tool_id TEXT NOT NULL, arguments JSONB NOT NULL DEFAULT '{}'::jsonb, result JSONB, status system.operation_status NOT NULL DEFAULT 'pending',
 started_at TIMESTAMPTZ, completed_at TIMESTAMPTZ, created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
 CHECK(completed_at IS NULL OR started_at IS NULL OR completed_at>=started_at));

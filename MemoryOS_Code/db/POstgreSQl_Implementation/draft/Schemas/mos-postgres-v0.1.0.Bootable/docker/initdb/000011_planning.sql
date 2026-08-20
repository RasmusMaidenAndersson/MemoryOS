CREATE TABLE planning.goals(
 goal_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), owner_id UUID, title TEXT NOT NULL, description TEXT, priority NUMERIC(10,4) NOT NULL DEFAULT 0,
 status TEXT NOT NULL DEFAULT 'active', created_at TIMESTAMPTZ NOT NULL DEFAULT now(), updated_at TIMESTAMPTZ NOT NULL DEFAULT now(), deadline TIMESTAMPTZ);
CREATE TABLE planning.plans(
 plan_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), goal_id UUID NOT NULL REFERENCES planning.goals(goal_id) ON DELETE RESTRICT,
 version BIGINT NOT NULL DEFAULT 1 CHECK(version>0), status TEXT NOT NULL DEFAULT 'active', created_at TIMESTAMPTZ NOT NULL DEFAULT now(), updated_at TIMESTAMPTZ NOT NULL DEFAULT now());
CREATE TABLE planning.milestones(
 milestone_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), plan_id UUID NOT NULL REFERENCES planning.plans(plan_id) ON DELETE RESTRICT,
 title TEXT NOT NULL, sequence_number INTEGER NOT NULL CHECK(sequence_number>0), status TEXT NOT NULL DEFAULT 'pending', created_at TIMESTAMPTZ NOT NULL DEFAULT now(), updated_at TIMESTAMPTZ NOT NULL DEFAULT now(), UNIQUE(plan_id,sequence_number));
CREATE TABLE planning.tasks(
 task_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), plan_id UUID NOT NULL REFERENCES planning.plans(plan_id) ON DELETE RESTRICT,
 milestone_id UUID REFERENCES planning.milestones(milestone_id) ON DELETE RESTRICT, parent_task_id UUID REFERENCES planning.tasks(task_id) ON DELETE RESTRICT,
 title TEXT NOT NULL, description TEXT, status TEXT NOT NULL DEFAULT 'pending', priority NUMERIC(10,4) NOT NULL DEFAULT 0,
 created_at TIMESTAMPTZ NOT NULL DEFAULT now(), updated_at TIMESTAMPTZ NOT NULL DEFAULT now(), deadline TIMESTAMPTZ);
CREATE TABLE planning.dependencies(
 dependency_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), task_id UUID NOT NULL REFERENCES planning.tasks(task_id) ON DELETE RESTRICT,
 depends_on_task_id UUID NOT NULL REFERENCES planning.tasks(task_id) ON DELETE RESTRICT, dependency_type TEXT NOT NULL,
 UNIQUE(task_id,depends_on_task_id), CHECK(task_id<>depends_on_task_id));

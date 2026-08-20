BEGIN;

CREATE SCHEMA IF NOT EXISTS cognition;

CREATE TABLE cognition.operations(
    operation_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    operation_type TEXT NOT NULL,

    actor_principal_id UUID
        REFERENCES identity.principals(principal_id)
        ON DELETE RESTRICT,

    agent_id UUID
        REFERENCES identity.agents(agent_id)
        ON DELETE RESTRICT,

    worker_id UUID,
    model_id UUID,

    started_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    completed_at TIMESTAMPTZ,

    status system.operation_status
        NOT NULL DEFAULT 'pending',

    result JSONB,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    CHECK (
        completed_at IS NULL
        OR completed_at >= started_at
    )
);

CREATE TABLE cognition.operation_inputs(
    operation_id UUID NOT NULL
        REFERENCES cognition.operations(operation_id)
        ON DELETE RESTRICT,

    object_type TEXT NOT NULL,
    object_id UUID NOT NULL,
    role TEXT NOT NULL,

    PRIMARY KEY (
        operation_id,
        object_type,
        object_id,
        role
    )
);

CREATE TABLE cognition.operation_outputs(
    operation_id UUID NOT NULL
        REFERENCES cognition.operations(operation_id)
        ON DELETE RESTRICT,

    object_type TEXT NOT NULL,
    object_id UUID NOT NULL,
    role TEXT NOT NULL,

    PRIMARY KEY (
        operation_id,
        object_type,
        object_id,
        role
    )
);

CREATE TABLE cognition.reasoning_runs(
    reasoning_run_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    operation_id UUID NOT NULL
        REFERENCES cognition.operations(operation_id)
        ON DELETE RESTRICT,

    model TEXT NOT NULL,
    model_version TEXT,
    prompt_version TEXT,
    policy_version TEXT,

    started_at TIMESTAMPTZ NOT NULL,
    completed_at TIMESTAMPTZ,

    status system.operation_status
        NOT NULL DEFAULT 'pending',

    CHECK (
        completed_at IS NULL
        OR completed_at >= started_at
    )
);

CREATE TABLE cognition.evidence_sets(
    evidence_set_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    operation_id UUID NOT NULL
        REFERENCES cognition.operations(operation_id)
        ON DELETE RESTRICT,

    purpose TEXT NOT NULL,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE cognition.evidence_set_items(
    evidence_set_id UUID NOT NULL
        REFERENCES cognition.evidence_sets(evidence_set_id)
        ON DELETE RESTRICT,

    evidence_id UUID NOT NULL
        REFERENCES provenance.evidence(evidence_id)
        ON DELETE RESTRICT,

    rank INTEGER,

    weight NUMERIC(5,4)
        CHECK (weight BETWEEN 0 AND 1),

    PRIMARY KEY (
        evidence_set_id,
        evidence_id
    )
);

CREATE TABLE cognition.contexts(
    context_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    owner_agent_id UUID
        REFERENCES identity.agents(agent_id)
        ON DELETE RESTRICT,

    context_type TEXT NOT NULL,
    title TEXT,

    status system.lifecycle_status
        NOT NULL DEFAULT 'active',

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    expires_at TIMESTAMPTZ,

    metadata JSONB NOT NULL DEFAULT '{}'::jsonb
);

CREATE TABLE cognition.context_items(
    context_id UUID NOT NULL
        REFERENCES cognition.contexts(context_id)
        ON DELETE RESTRICT,

    object_type TEXT NOT NULL,
    object_id UUID NOT NULL,

    role TEXT NOT NULL,

    priority NUMERIC(10,4)
        NOT NULL DEFAULT 0,

    PRIMARY KEY (
        context_id,
        object_type,
        object_id,
        role
    )
);

CREATE TABLE cognition.working_memory(
    working_memory_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    agent_id UUID NOT NULL
        REFERENCES identity.agents(agent_id)
        ON DELETE RESTRICT,

    context_id UUID
        REFERENCES cognition.contexts(context_id)
        ON DELETE RESTRICT,

    capacity INTEGER NOT NULL DEFAULT 200
        CHECK (capacity > 0),

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    expires_at TIMESTAMPTZ
);

CREATE TABLE cognition.working_memory_items(
    item_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    working_memory_id UUID NOT NULL
        REFERENCES cognition.working_memory(working_memory_id)
        ON DELETE RESTRICT,

    object_type TEXT NOT NULL,
    object_id UUID NOT NULL,

    priority NUMERIC(10,4)
        NOT NULL DEFAULT 0,

    attention_score NUMERIC(10,4)
        NOT NULL DEFAULT 0,

    activation_reason TEXT,

    added_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    last_accessed TIMESTAMPTZ,

    expires_at TIMESTAMPTZ
);

COMMIT;

BEGIN;

ALTER TABLE knowledge.fact_versions
    ADD CONSTRAINT fact_versions_created_by_operation_fk
    FOREIGN KEY (created_by_operation_id)
    REFERENCES cognition.operations(operation_id)
    ON DELETE RESTRICT;

ALTER TABLE knowledge.knowledge_states
    ADD CONSTRAINT knowledge_states_determined_by_operation_fk
    FOREIGN KEY (determined_by_operation_id)
    REFERENCES cognition.operations(operation_id)
    ON DELETE RESTRICT;

INSERT INTO system.schema_migrations(
    version,
    description
)
VALUES (
    'V006',
    'Cognitive operations, reasoning, contexts, working memory and knowledge-operation provenance'
)
ON CONFLICT (version) DO NOTHING;

COMMIT;

/*No validation transaction is needed because PostgreSQL validates those constraints during creation and our new database has no historical rows.*/
/*BUT FOR AN EXISTING MOS DATABASE OR EVOLVING, WE WANT A "NOT VALID" ALTER TABLE, SO WE DON'T LOCK THE DATABSE, AS WE CAN VALIDATE THE CONSTRAINTS LATER ON*/
/*But due to MOS design around immutabillity VALIDATE CONTRAINT, should be done after data migration and should be required migration gate*/
/*A migration can be deployed with NOT VALID, but should not be considered a totally valid migration until the validation constraint is added and validated*/

/*So a totally new deployment is as above, but existing database shoudl use the NOT VALID option to avoid locking, then separately run the validation constraint, like below*/
/*BEGIN;

ALTER TABLE knowledge.fact_versions
    ADD CONSTRAINT fact_versions_created_by_operation_fk
    FOREIGN KEY (created_by_operation_id)
    REFERENCES cognition.operations(operation_id)
    ON DELETE RESTRICT
    NOT VALID;

ALTER TABLE knowledge.knowledge_states
    ADD CONSTRAINT knowledge_states_determined_by_operation_fk
    FOREIGN KEY (determined_by_operation_id)
    REFERENCES cognition.operations(operation_id)
    ON DELETE RESTRICT
    NOT VALID;

COMMIT;
And then later validate these constraints like below

BEGIN;

ALTER TABLE knowledge.fact_versions
    VALIDATE CONSTRAINT fact_versions_created_by_operation_fk;

ALTER TABLE knowledge.knowledge_states
    VALIDATE CONSTRAINT knowledge_states_determined_by_operation_fk;

COMMIT;*/

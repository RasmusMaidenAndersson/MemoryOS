BEGIN;
CREATE SCHEMA resources;
CREATE TABLE resources.resources(
 resource_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), resource_type TEXT NOT NULL, name TEXT NOT NULL,
 capacity NUMERIC, available NUMERIC, unit TEXT, status system.lifecycle_status NOT NULL DEFAULT 'active',
 owner_principal_id UUID REFERENCES identity.principals(principal_id) ON DELETE RESTRICT,
 created_at TIMESTAMPTZ NOT NULL DEFAULT now(), updated_at TIMESTAMPTZ NOT NULL DEFAULT now(), metadata JSONB NOT NULL DEFAULT '{}'::jsonb
);
CREATE TABLE resources.allocations(
 allocation_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), resource_id UUID NOT NULL REFERENCES resources.resources(resource_id) ON DELETE RESTRICT,
 operation_id UUID REFERENCES cognition.operations(operation_id) ON DELETE RESTRICT, amount NUMERIC NOT NULL CHECK(amount>=0), unit TEXT,
 allocated_at TIMESTAMPTZ NOT NULL DEFAULT now(), released_at TIMESTAMPTZ
);
CREATE TABLE resources.consumption(
 consumption_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), resource_id UUID NOT NULL REFERENCES resources.resources(resource_id) ON DELETE RESTRICT,
 operation_id UUID REFERENCES cognition.operations(operation_id) ON DELETE RESTRICT, amount NUMERIC NOT NULL CHECK(amount>=0), unit TEXT,
 cost NUMERIC(20,8) CHECK(cost IS NULL OR cost>=0), consumed_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
INSERT INTO system.schema_migrations VALUES('V009','Resources allocations and consumption');
COMMIT;

CREATE TABLE projection.projections(
 projection_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), projection_type TEXT NOT NULL, source_type TEXT NOT NULL, source_id UUID NOT NULL,
 version BIGINT NOT NULL DEFAULT 1 CHECK(version>0), status system.projection_status NOT NULL DEFAULT 'building', created_at TIMESTAMPTZ NOT NULL DEFAULT now(), updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
 UNIQUE(projection_type,source_type,source_id,version));

BEGIN;
CREATE SCHEMA IF NOT EXISTS memory;
CREATE TABLE memory.entities(
 entity_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
 entity_type TEXT NOT NULL,
 canonical_name TEXT NOT NULL,
 status system.lifecycle_status NOT NULL DEFAULT 'active',
 current_version BIGINT NOT NULL DEFAULT 1 CHECK(current_version>0),
 created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
 updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
 metadata JSONB NOT NULL DEFAULT '{}'::jsonb
);
CREATE TABLE memory.entity_aliases(
 alias_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
 entity_id UUID NOT NULL REFERENCES memory.entities(entity_id) ON DELETE RESTRICT,
 alias TEXT NOT NULL,
 alias_type TEXT NOT NULL,
 confidence NUMERIC(5,4) CHECK(confidence BETWEEN 0 AND 1),
 created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TABLE memory.entity_identifiers(
 identifier_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
 entity_id UUID NOT NULL REFERENCES memory.entities(entity_id) ON DELETE RESTRICT,
 identifier_type TEXT NOT NULL,
 identifier_value TEXT NOT NULL,
 namespace TEXT,
 created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
 UNIQUE(identifier_type,identifier_value,namespace)
);
CREATE TABLE memory.observations(
 observation_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
 event_id UUID NOT NULL REFERENCES event.events(event_id) ON DELETE RESTRICT,
 observer_principal_id UUID REFERENCES identity.principals(principal_id) ON DELETE RESTRICT,
 observation_type TEXT NOT NULL,
 content TEXT NOT NULL,
 confidence NUMERIC(5,4) NOT NULL CHECK(confidence BETWEEN 0 AND 1),
 observed_at TIMESTAMPTZ NOT NULL,
 created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
 metadata JSONB NOT NULL DEFAULT '{}'::jsonb
);
CREATE TABLE memory.episodes(
 episode_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
 started_at TIMESTAMPTZ NOT NULL,
 ended_at TIMESTAMPTZ,
 title TEXT,
 summary TEXT,
 outcome TEXT,
 importance NUMERIC(5,4) CHECK(importance BETWEEN 0 AND 1),
 status system.lifecycle_status NOT NULL DEFAULT 'active',
 created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
 updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
 CHECK(ended_at IS NULL OR ended_at>=started_at)
);
CREATE TABLE memory.episode_events(
 episode_id UUID NOT NULL REFERENCES memory.episodes(episode_id) ON DELETE RESTRICT,
 event_id UUID NOT NULL REFERENCES event.events(event_id) ON DELETE RESTRICT,
 sequence_number BIGINT NOT NULL,
 PRIMARY KEY(episode_id,event_id), UNIQUE(episode_id,sequence_number)
);
INSERT INTO system.schema_migrations VALUES('V004','Entities, observations, episodes');
COMMIT;

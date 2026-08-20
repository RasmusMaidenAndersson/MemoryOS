CREATE TABLE network.nodes(
 node_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), node_identity TEXT NOT NULL UNIQUE, node_type TEXT NOT NULL, status TEXT NOT NULL DEFAULT 'active',
 capabilities JSONB NOT NULL DEFAULT '{}'::jsonb, created_at TIMESTAMPTZ NOT NULL DEFAULT now(), last_seen TIMESTAMPTZ, metadata JSONB NOT NULL DEFAULT '{}'::jsonb);
CREATE TABLE network.event_delivery(
 delivery_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), event_id UUID NOT NULL, event_recorded_at TIMESTAMPTZ NOT NULL,
 source_node_id UUID REFERENCES network.nodes(node_id) ON DELETE RESTRICT, target_node_id UUID REFERENCES network.nodes(node_id) ON DELETE RESTRICT,
 status TEXT NOT NULL DEFAULT 'pending', attempt_count INTEGER NOT NULL DEFAULT 0 CHECK(attempt_count>=0), created_at TIMESTAMPTZ NOT NULL DEFAULT now(), delivered_at TIMESTAMPTZ,
 FOREIGN KEY(event_id,event_recorded_at) REFERENCES event.events(event_id,recorded_at) ON DELETE RESTRICT);

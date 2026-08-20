BEGIN;
CREATE SCHEMA communication;
CREATE TABLE communication.messages(
 message_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), sender_principal_id UUID REFERENCES identity.principals(principal_id) ON DELETE RESTRICT,
 receiver_principal_id UUID REFERENCES identity.principals(principal_id) ON DELETE RESTRICT,
 intent_id UUID REFERENCES planning.intents(intent_id) ON DELETE RESTRICT,
 message_type TEXT NOT NULL, payload JSONB NOT NULL DEFAULT '{}'::jsonb, correlation_id UUID, causation_id UUID,
 sent_at TIMESTAMPTZ NOT NULL DEFAULT now(), status TEXT NOT NULL DEFAULT 'sent'
);
CREATE TABLE communication.delegations(
 delegation_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
 delegating_principal_id UUID NOT NULL REFERENCES identity.principals(principal_id) ON DELETE RESTRICT,
 receiving_principal_id UUID NOT NULL REFERENCES identity.principals(principal_id) ON DELETE RESTRICT,
 capability TEXT NOT NULL, authority_scope JSONB NOT NULL DEFAULT '{}'::jsonb, created_at TIMESTAMPTZ NOT NULL DEFAULT now(), expires_at TIMESTAMPTZ
);
CREATE TABLE communication.synchronizations(
 synchronization_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
 source_node_id UUID, target_node_id UUID, object_type TEXT NOT NULL, object_id UUID NOT NULL,
 source_version BIGINT, target_version BIGINT, status TEXT NOT NULL DEFAULT 'pending', created_at TIMESTAMPTZ NOT NULL DEFAULT now(), completed_at TIMESTAMPTZ
);
INSERT INTO system.schema_migrations VALUES('V011','Messages delegations synchronizations');
COMMIT;

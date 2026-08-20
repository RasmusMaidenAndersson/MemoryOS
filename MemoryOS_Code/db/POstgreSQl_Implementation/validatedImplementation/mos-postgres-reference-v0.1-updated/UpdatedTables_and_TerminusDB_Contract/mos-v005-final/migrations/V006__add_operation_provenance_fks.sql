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

INSERT INTO system.schema_migrations(version, description)
VALUES ('V006-KNOWLEDGE-FK', 'Attach knowledge version provenance to cognitive operations')
ON CONFLICT (version) DO UPDATE
SET description = EXCLUDED.description,
    applied_at = now();

COMMIT;

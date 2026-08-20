from __future__ import annotations
import json, os, uuid
import psycopg

class MOSPersistence:
    """PostgreSQL audit/operation boundary; never writes facts directly."""
    def __init__(self, dsn: str | None = None) -> None:
        self.dsn = dsn or os.getenv("MOS_POSTGRES_DSN", "postgresql://mos:mos_dev_password@localhost:5432/mos")

    def record_operation_start(self, *, agent_id: str, capability_id: str) -> str:
        operation_id = str(uuid.uuid4())
        try:
            with psycopg.connect(self.dsn) as conn, conn.cursor() as cur:
                cur.execute("""
                    INSERT INTO cognition.operations(operation_id, operation_type, agent_id, started_at, status, metadata)
                    VALUES (%s, 'mcp.tool_call', %s::uuid, now(), 'running', %s::jsonb)
                """, (operation_id, agent_id, json.dumps({"capability_id": capability_id})))
        except Exception:
            # v0.1 fail-open for telemetry only; production governance should choose fail-closed where required.
            pass
        return operation_id

    def record_operation_end(self, operation_id: str, *, status: str, result_hash: str | None = None, error: str | None = None) -> None:
        try:
            with psycopg.connect(self.dsn) as conn, conn.cursor() as cur:
                cur.execute("""
                    UPDATE cognition.operations
                    SET completed_at = now(), status = %s, result = %s::jsonb
                    WHERE operation_id = %s::uuid
                """, (status, json.dumps({"result_hash": result_hash, "error": error}), operation_id))
        except Exception:
            pass

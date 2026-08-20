from __future__ import annotations
import hashlib, json
from typing import Any
from redis.asyncio import Redis

def stable_hash(value: Any) -> str:
    payload = json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=False).encode()
    return hashlib.sha256(payload).hexdigest()

class MCPRedisCache:
    def __init__(self, redis: Redis, *, capability_ttl: int = 300, result_ttl: int = 60) -> None:
        self.redis = redis
        self.capability_ttl = capability_ttl
        self.result_ttl = result_ttl

    async def get_capabilities(self, server_id: str) -> list[dict] | None:
        raw = await self.redis.get(f"mos:mcp:server:{server_id}:capabilities")
        return json.loads(raw) if raw else None

    async def set_capabilities(self, server_id: str, capabilities: list[dict]) -> None:
        await self.redis.set(
            f"mos:mcp:server:{server_id}:capabilities",
            json.dumps(capabilities, separators=(",", ":")),
            ex=self.capability_ttl,
        )

    def result_key(self, *, server_id: str, capability_id: str, request: Any, tool_schema_hash: str | None, host_context_hash: str | None) -> str:
        signature = stable_hash({
            "server_id": server_id,
            "capability_id": capability_id,
            "request": request,
            "tool_schema_hash": tool_schema_hash,
            "host_context_hash": host_context_hash,
        })
        return f"mos:mcp:tool-result:{signature}"

    async def get_result(self, key: str) -> dict | None:
        raw = await self.redis.get(key)
        return json.loads(raw) if raw else None

    async def set_result(self, key: str, value: dict) -> None:
        await self.redis.set(key, json.dumps(value, separators=(",", ":")), ex=self.result_ttl)

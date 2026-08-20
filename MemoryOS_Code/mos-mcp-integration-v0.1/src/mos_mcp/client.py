from __future__ import annotations
import hashlib, json
from typing import Any
from mcp import Client, StdioServerParameters
from mcp.client.stdio import stdio_client
from mcp.client.streamable_http import streamable_http_client
from .cache import MCPRedisCache, stable_hash
from .models import Capability, MCPServerRegistration
from .persistence import MOSPersistence
from .policy import DefaultPolicy

class MOSMCPClient:
    def __init__(self, *, agent_id: str, redis_cache: MCPRedisCache | None = None, persistence: MOSPersistence | None = None, policy: DefaultPolicy | None = None) -> None:
        self.agent_id = agent_id
        self.cache = redis_cache
        self.persistence = persistence
        self.policy = policy or DefaultPolicy()

    def _transport(self, server: MCPServerRegistration):
        if server.transport == "stdio":
            params = StdioServerParameters(
                command=server.target,
                args=server.metadata.get("args", []),
                env=server.metadata.get("env"),
            )
            return stdio_client(params)
        if server.transport == "streamable_http":
            return streamable_http_client(server.target)
        raise ValueError(f"unsupported MCP transport: {server.transport}")

    async def discover_tools(self, server: MCPServerRegistration) -> list[Capability]:
        async with self._transport(server) as transport:
            async with Client(transport) as client:
                result = await client.list_tools()
        capabilities: list[Capability] = []
        for tool in result.tools:
            schema = getattr(tool, "inputSchema", None)
            schema_hash = stable_hash(schema) if schema else None
            capability_id = f"{server.server_id}:tool:{tool.name}:{schema_hash or 'noschema'}"
            capabilities.append(Capability(
                capability_id=capability_id,
                server_id=server.server_id,
                kind="tool",
                name=tool.name,
                description=getattr(tool, "description", None),
                schema_hash=schema_hash,
            ))
        if self.cache:
            await self.cache.set_capabilities(server.server_id, [c.__dict__ | {"risk": c.risk.value} for c in capabilities])
        return capabilities

    async def call_tool(self, server: MCPServerRegistration, capability: Capability, arguments: dict[str, Any], *, host_context_hash: str | None = None) -> dict[str, Any]:
        decision = self.policy.authorize(self.agent_id, server, capability)
        if not decision.allowed:
            raise PermissionError(decision.reason)

        cache_key = None
        if self.cache and capability.cacheable:
            cache_key = self.cache.result_key(
                server_id=server.server_id,
                capability_id=capability.capability_id,
                request=arguments,
                tool_schema_hash=capability.schema_hash,
                host_context_hash=host_context_hash,
            )
            cached = await self.cache.get_result(cache_key)
            if cached is not None:
                return {**cached, "_cache_hit": True}

        operation_id = self.persistence.record_operation_start(agent_id=self.agent_id, capability_id=capability.capability_id) if self.persistence else None
        try:
            async with self._transport(server) as transport:
                async with Client(transport) as client:
                    result = await client.call_tool(capability.name, arguments)
            structured = getattr(result, "structured_content", None)
            if structured is None:
                structured = {"content": [str(x) for x in getattr(result, "content", [])]}
            payload = {
                "operation_id": operation_id,
                "server_id": server.server_id,
                "capability_id": capability.capability_id,
                "tool": capability.name,
                "result": structured,
                "_cache_hit": False,
            }
            if self.cache and cache_key:
                await self.cache.set_result(cache_key, payload)
            if self.persistence and operation_id:
                result_hash = hashlib.sha256(json.dumps(structured, sort_keys=True, default=str).encode()).hexdigest()
                self.persistence.record_operation_end(operation_id, status="completed", result_hash=result_hash)
            return payload
        except Exception as exc:
            if self.persistence and operation_id:
                self.persistence.record_operation_end(operation_id, status="failed", error=str(exc))
            raise

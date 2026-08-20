from __future__ import annotations
from dataclasses import dataclass, field
from datetime import datetime, timezone
from enum import Enum
from typing import Any

class Risk(str, Enum):
    READ = "read"
    WRITE = "write"
    MUTATE = "mutate"
    EXECUTE = "execute"
    DESTRUCTIVE = "destructive"
    PRIVILEGED = "privileged"

@dataclass(frozen=True)
class MCPServerRegistration:
    server_id: str
    name: str
    transport: str  # stdio | streamable_http
    target: str
    protocol_version: str = "2026-07-28"
    trust_level: str = "experimental"
    enabled: bool = True
    metadata: dict[str, Any] = field(default_factory=dict)

@dataclass(frozen=True)
class Capability:
    capability_id: str
    server_id: str
    kind: str  # tool | resource | prompt
    name: str
    description: str | None
    schema_hash: str | None = None
    risk: Risk = Risk.READ
    cacheable: bool = False
    metadata: dict[str, Any] = field(default_factory=dict)

@dataclass(frozen=True)
class ToolPolicyDecision:
    allowed: bool
    reason: str
    capability_id: str
    agent_id: str
    decided_at: datetime = field(default_factory=lambda: datetime.now(timezone.utc))

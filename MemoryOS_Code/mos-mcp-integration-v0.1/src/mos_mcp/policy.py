from __future__ import annotations
from .models import Capability, MCPServerRegistration, Risk, ToolPolicyDecision

class DefaultPolicy:
    """Safe v0.1 baseline. Mutating/destructive operations require explicit allow-listing."""
    def __init__(self, allowed_capabilities: set[str] | None = None) -> None:
        self.allowed_capabilities = allowed_capabilities or set()

    def authorize(self, agent_id: str, server: MCPServerRegistration, capability: Capability) -> ToolPolicyDecision:
        if not server.enabled:
            return ToolPolicyDecision(False, "MCP server is disabled", capability.capability_id, agent_id)
        risky = {Risk.WRITE, Risk.MUTATE, Risk.EXECUTE, Risk.DESTRUCTIVE, Risk.PRIVILEGED}
        if capability.risk in risky and capability.capability_id not in self.allowed_capabilities:
            return ToolPolicyDecision(False, "capability is not explicitly authorized", capability.capability_id, agent_id)
        return ToolPolicyDecision(True, "allowed by MOS v0.1 default policy", capability.capability_id, agent_id)

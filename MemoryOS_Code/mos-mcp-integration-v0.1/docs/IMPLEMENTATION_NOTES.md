# MOS MCP Integration implementation notes

- PostgreSQL is authoritative for durable MOS operation/audit state.
- Redis is runtime cache only.
- MCP is the external capability protocol.
- The graph layer remains a projection.
- The default v0.1 policy denies write/mutate/execute/destructive/privileged tools unless explicitly allow-listed.
- MCP resource discovery/reads, prompts, Redis Streams invalidation, and TerminusDB operation projection are subsequent vertical slices.
- Tool-result caching is intended only for explicitly cacheable, safely reusable operations.
- Side-effecting calls always create a fresh MOS operation and are never satisfied from a result cache.

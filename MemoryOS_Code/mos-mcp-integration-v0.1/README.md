# MOS MCP Integration v0.1

Implementation of the MOS MCP Integration Specification v0.1.

Architecture:

```text
Agent -> MOS MCP Gateway -> Governance/Policy
                         -> PostgreSQL (authoritative operations)
                         -> Redis (runtime cache)
                         -> MCP Client (stdio / Streamable HTTP)
```

The implementation deliberately keeps MCP, Redis and the graph layer non-authoritative.

## Install

```bash
uv sync
pytest -q
```

Or:

```bash
pip install -e '.[dev]'
```

## Current v0.1 implementation

- MCP server registration
- tool discovery
- deny-by-default policy for mutating/destructive tools
- PostgreSQL operation audit boundary
- Redis capability cache
- safe tool-result cache
- stdio and Streamable HTTP transport adapters
- in-memory MCP integration test
- demo local MCP server

The project targets the current official MCP Python SDK v2 line and MCP 2026-07-28.

Production TODOs are documented in `docs/IMPLEMENTATION_NOTES.md`.

# MOS MCP Integration architecture

```text
Agent
  |
  v
MOS MCP Gateway
  +--> Governance / Authorization
  +--> PostgreSQL operation/provenance
  +--> Redis runtime cache
  +--> Official MCP Python SDK
            +--> stdio
            +--> Streamable HTTP
                 |
                 v
              MCP Server
                 |
                 v
          Host / API / Service
```

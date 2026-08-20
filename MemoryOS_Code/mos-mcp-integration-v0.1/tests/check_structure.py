from pathlib import Path
root=Path(__file__).resolve().parents[1]
required=['pyproject.toml','src/mos_mcp/client.py','src/mos_mcp/cache.py','src/mos_mcp/policy.py','src/mos_mcp/persistence.py','examples/demo_server.py']
missing=[x for x in required if not (root/x).exists()]
assert not missing, missing
print('MOS MCP structure: PASS')

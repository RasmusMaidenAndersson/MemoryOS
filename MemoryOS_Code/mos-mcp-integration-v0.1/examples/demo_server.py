from mcp.server.fastmcp import FastMCP

mcp = FastMCP("mos-demo-host")

@mcp.tool()
def system_info() -> dict:
    """Return harmless local host information."""
    import platform
    return {"platform": platform.platform(), "python": platform.python_version()}

@mcp.tool()
def echo(value: str) -> str:
    """Return an input value."""
    return value

if __name__ == "__main__":
    mcp.run()

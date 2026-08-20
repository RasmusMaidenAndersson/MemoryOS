import pytest
from mcp import Client
from mcp.server.fastmcp import FastMCP

@pytest.mark.asyncio
async def test_real_sdk_in_memory():
    server=FastMCP('test')
    @server.tool()
    def add(a:int,b:int)->int:
        return a+b
    async with Client(server) as client:
        result=await client.call_tool('add',{'a':2,'b':3})
        assert result.structured_content == {'result':5}

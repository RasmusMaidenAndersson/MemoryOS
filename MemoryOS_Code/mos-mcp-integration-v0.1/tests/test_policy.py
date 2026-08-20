from mos_mcp.models import Capability, MCPServerRegistration, Risk
from mos_mcp.policy import DefaultPolicy

def test_read_allowed():
    p=DefaultPolicy(); s=MCPServerRegistration('s1','test','stdio','python')
    c=Capability('c1','s1','tool','read','',risk=Risk.READ)
    assert p.authorize('a',s,c).allowed

def test_execute_denied_by_default():
    p=DefaultPolicy(); s=MCPServerRegistration('s1','test','stdio','python')
    c=Capability('c1','s1','tool','shell','',risk=Risk.EXECUTE)
    assert not p.authorize('a',s,c).allowed

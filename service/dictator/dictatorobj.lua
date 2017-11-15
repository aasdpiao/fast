local skynet = require "skynet"
local baseobj = require "base.baseobj"

function NewDictatorObj(...)
    return CDictator:New(...)
end


CDictator = {}
CDictator.__index = CDictator
inherit(CDictator, baseobj)

function CDictator:New(...)
    local o = super(CDictator).New(self)
    o.m_mService = {}
    return o
end

function CDictator:RegisterService(name, addr)
    printf("RegisterService %s 0x%x", name, addr)
    if not self.m_mService[name] then
        self.m_mService[name] = {}
    end
    self.m_mService[name][addr] = true
end

function CDictator:UnRegisterService(name, addr)
    printf("RegisterService %s 0x%x", name, addr)
    self.m_mService[name][addr] = nil
end

function CDictator:CallSvr(name,  ...)
    local mInst = self.m_mService[name]
    for addr in pairs(mInst) do
        printf("CDictator:CallSvr %s 0x%x %s", name, addr, table.concat({...}, " "))
        skynet.call(addr, "lua", ...)
    end
end

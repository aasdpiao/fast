local skynet = require "skynet"
local protopack = require "rpc.protopack"
local socket = require "skynet.socket"
local baseobj = require "base.baseobj"

function NewAgentObj(...)
    return CAgent:New(...)
end

CAgent = {}
CAgent.__index = CAgent
inherit(CAgent, baseobj)

function CAgent:New(fd, account)
    local o = setmetatable({}, self)
    o.m_fd = fd
    o.m_account = account
    o.m_player = nil
    return o
end

-- 加载用户数据
function CAgent:LoadPlayer()
    local v = skynet.call(".gamedb", "lua", "dbproxy", "Get", self.m_account)
    self.m_player = v
end

-- 用户数据落地
function CAgent:DumpPlayer()
    assert(self.m_player)
    skynet.call(".gamedb", "lua", "dbproxy", "Set", self.m_account, self.m_player)
end


-- 发消息给客户端
function CAgent:SendMessage(name, msg)
	local data = protopack.pack(name, msg)
	socket.write(self.m_fd, data)
end

-- 分发命令
function CAgent:Dispatch(name, msg)
    local func = "On" .. name
    print("CAgent.Dispatch", func, "msg", msg)
    if not self[func] then
        printf('agent, account = %d, Dispatch failed, name = %s', self.m_account, name)
        return
    end
    self[func](self, msg)
end

----------- 逻辑处理 ---------------
function CAgent:OnGetUserReq(msg)
    print("GetUserReq", msg)
    local resp = {
        head = {result = 0, errmsg = "succ"}
    }
    self:SendMessage("GetUserRsp", resp)
end

return CAgent

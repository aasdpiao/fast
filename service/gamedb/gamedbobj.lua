local skynet = require "skynet"
local redis = require "skynet.db.redis"
local baseobj =  require "base.baseobj"

function NewGameDbObj(...)
    return CGameDb:New(...)
end

CGameDb = {}
CGameDb.__index = CGameDb
inherit(CGameDb, baseobj)

function CGameDb:New(mConfig, sDbName)
    local o = super(CGameDb).New(self)
    o.m_oClient = nil
    o.m_sDbName = sDbName
    o:Init(mConfig)
    return o
end

function CGameDb:Init(mConfig)
    local oClient = assert(redis.connect{
        host = mConfig.host,
        port = mConfig.port,
        db = mConfig.db or 0,
        auth = mConfig.auth,
    }, 'redis connect error')
    self.m_oClient = oClient
end


function CGameDb:Get(key)
    local result = self.m_oClient:get(key)
    return result
end

function CGameDb:Set(key, value)
    assert(self.m_oClient:set(key, value))
end

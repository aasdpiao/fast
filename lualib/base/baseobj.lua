local CBaseObj = {}
CBaseObj.__index = CBaseObj

function CBaseObj:New()
    local o = setmetatable({}, self)
    o.m_mData = {}
    return o
end

function CBaseObj:GetData(k, default)
    return self.m_mData[k] or defalut
end

function CBaseObj:SetData(k, v)
    self.m_mData[k] = v
end

return CBaseObj

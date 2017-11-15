require "base.lstring"
require "base.ltable"
require "base.reload"
local tableDump = require "base.luaTableDump"

local skynet = require "skynet"

SVR_NAME = ...

print = function(...)
    local args = {}
    for _, v in ipairs({...}) do
        s = tostring(v)
        if type(v) == 'table' then
            s = string.format('%s', tableDump(v))
        end
        table.insert(args, s)
    end
    local msg = table.concat(args, " ")
    local info = debug.getinfo(2)
    if info then
        msg = string.format("[%s:%d] %s", info.short_src, info.currentline, msg)
    end
    skynet.error(msg)
end

printf = function (fmt, ...)
    local msg = string.format(fmt, ...)
    local info = debug.getinfo(2)
    if info then
        msg = string.format("[%s:%d] %s", info.short_src, info.currentline, msg)
    end
    skynet.error(msg)
end

inherit = function(children, parent)
    setmetatable(children, parent)
end

super = function(class)
    return getmetatable(class)
end

trace_msg = function(msg)
    print(debug.traceback("=====" .. msg .. "====="))
end

safe_call = function(func, ...)
    xpcall(func, trace_msg, ...)
end

loadfile_ex = function(file_name, mode, env)
    mode = mode or "rb"
    local fp = io.open(file_name, mode)
    local data = fp:read("a")
    fp:close()
    local f, s = load(data, file_name, "bt", env)
    assert(f, s)
    return f
end

service_path = function(dotfile)
    return "service." .. SVR_NAME .. "." .. dotfile
end

lualib_path = function(dotfile)
    return "lualib".."."..dotfile
end

local skynet = require "skynet.manager"
local global = require "global"
local gamedb = import(service_path("gamedbobj"))

local CMD = {}

-- 热更新
function CMD.reload()
    print("reload gamedb")
    reload(service_path("gamedbobj"))
end

-- CGameDb 代理
function CMD.dbproxy(func, ...)
    local ret =  global.oGameDb[func](global.oGameDb, ...)
    return ret
end

skynet.dispatch("lua", function (session, address, command, ...)
    local f = CMD[command]
    skynet.ret(skynet.pack(f(...)))
end)

skynet.start(function()
    local path = skynet.getenv("gamedb")
    local f = loadfile_ex(path)
    local cfg = assert(f())
    global.oGameDb = gamedb.NewGameDbObj(cfg, "game")

    skynet.call(".dictator", "lua", "register_service", SVR_NAME, skynet.self())

    skynet.register(".gamedb")
    skynet.error("gamedb service booted")
end)

local skynet = require "skynet"
local protopack = require "rpc.protopack"

local global = require "global"
local agentobj = import(service_path("agentobj"))

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
	unpack = function (data, sz)
		print("agent recv socket data",sz)
		return skynet.tostring(data,sz)
	end,
	dispatch = function (_, _, str)
		local name, msg = protopack.unpack(str)
		global.oAgentObj:Dispatch(name, msg)
	end
}

----------------------------------------------------------------------
local CMD = {}

function CMD.start(gate, watchdog, fd, account)
    global.gate = gate
    global.watchdog = watchdog
    global.oAgentObj = agentobj.NewAgentObj(fd, account)
    global.oAgentObj:LoadPlayer()

    -- 通知gate 接收客户端数据
	skynet.call(gate, "lua", "forward", fd)
    print("agent start")
end

function CMD.disconnect()
    print("agent exit")
    skynet.call(".dictator", "lua", "unregister_service", SVR_NAME, skynet.self())
	skynet.exit()
end

function CMD.send(name, msg)
    global.oAgentObj:SendMessage(name, msg)
end

-- 热更新
function CMD.reload()
    print("reload agent")
    reload(service_path("agentobj"))
end

skynet.dispatch("lua", function(_,_, command, ...)
    local f = CMD[command]
    skynet.ret(skynet.pack(f(...)))
end)

skynet.start(function()
    skynet.call(".dictator", "lua", "register_service", SVR_NAME, skynet.self())
    skynet.error("agent service booted")
end)

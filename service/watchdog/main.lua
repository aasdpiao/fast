local skynet = require "skynet"
local protopack = require "rpc.protopack"
local socket = require "skynet.socket"

local gate
local agents = {}

local SOCKET = {}
---------------------------socket数据处理----------------------------
local sock_handler = {}

-- 功能:
--   * 检验平台用户名, token
--   * 根据 username, token 获取唯一的 account
--   * 处理重复登陆
--   * 分配agent
sock_handler["LoginReq"] = function (fd, msg)
    -- TODO
    local account = 100

	agents[fd] = skynet.newservice("agent")
	skynet.call(agents[fd], "lua", "start", gate, skynet.self(), fd, account)

	SOCKET.send(fd, "LoginRsp", {account = account})
	printf("login success, account = %d", account)
end

------------------------ socket消息开始 -----------------------------
function SOCKET.open(fd, addr)
	printf("New client from : %s", addr)
	skynet.call(gate, "lua", "accept", fd)
end

local function close_agent(fd)
	local a = agents[fd]
	agents[fd] = nil
	if a then
		skynet.call(gate, "lua", "kick", fd)
		-- disconnect never return
		skynet.send(a, "lua", "disconnect")
	end
end

function SOCKET.close(fd)
	printf("socket close fd=%d", fd)
	close_agent(fd)
end

function SOCKET.error(fd, msg)
	printf("socket error fd = %d msg=%s", fd, msg)
	close_agent(fd)
end

function SOCKET.warning(fd, size)
	-- size K bytes havn't send out in fd
	printf("socket warning fd=%d size=%d", fd, size)
end

function SOCKET.data(fd, data)
	local name, msg = protopack.unpack(data)
	sock_handler[name](fd, msg)
end

function SOCKET.send(fd, name, msg)
	local data = protopack.pack(name, msg)
	socket.write(fd, data)
end

------------------------ socket消息结束-----------------------------

local CMD = {}

function CMD.close(fd)
	close_agent(fd)
end

skynet.dispatch("lua", function(_, _, cmd, subcmd, ...)
    if cmd == "socket" then
        local f = SOCKET[subcmd]
        f(...)
        -- socket api don't need return
    else
        local f = assert(CMD[cmd])
        skynet.ret(skynet.pack(f(subcmd, ...)))
    end
end)

skynet.start(function()
	gate = skynet.newservice("gate")
    local path = skynet.getenv("gateconf")
    local f = loadfile_ex(path)
    local cfg = assert(f())
    skynet.call(gate, "lua", "open", cfg)

    skynet.error("watchdog service booted")
end)

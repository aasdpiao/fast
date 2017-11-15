local skynet = require "skynet"
require "skynet.manager"
local path = require "os.path"

local protobuf
-- 记录所有的消息名称
local message_names

local function reload_proto()
    message_names = {}
    package.loaded["protobuf"] = nil
    protobuf = require "protobuf"

    local dirname = skynet.getenv("proto_dir")
    local paths = path.listdir(dirname)
	for _, p in ipairs(paths) do
        print("register proto:", p)
        local fp = io.open(p, "rb")
        local buffer = fp:read "*a"
        fp:close()
		protobuf.register(buffer)
        local t = protobuf.decode("google.protobuf.FileDescriptorSet", buffer)
        local proto = t.file[1]
        for _, v in ipairs(proto.message_type) do
            message_names[v.name] = true
            --print("message_name: ", v.name)
        end
	end
end

local CMD = {}

function CMD.encode(msg_name, msg)
    if not message_names[msg_name] then
        assert(false, "pbc, encode error, invalid message: " .. msg_name)
    end
	return protobuf.encode(msg_name, msg)
end

function CMD.decode(msg_name, data)
    if not message_names[msg_name] then
        assert(false, "pbc, decode error, invalid message: " .. msg_name)
    end
	return protobuf.decode(msg_name, data)
end

function CMD.reload()
    print("pbc reload")
    reload_proto()
end

skynet.dispatch("lua", function(session, address, command, ...)
    local f = CMD[command]
    skynet.ret(skynet.pack(f(...)))
end)

skynet.start(function ()
    reload_proto()
    skynet.register(".pbc")
    skynet.call(".dictator", "lua", "register_service", SVR_NAME, skynet.self())
    skynet.error("pbc service booted")
end)

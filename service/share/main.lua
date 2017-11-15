local skynet = require "skynet"
local manager = require "skynet.manager"
local sharedata = require "skynet.sharedata"
local path = require "os.path"

-- 已经加载的配置文件
local filenames = {}

local function reload_sharedata()
    local dirname = skynet.getenv("sharedata_dir")
    local paths = path.listdir(dirname)
    for _, p in ipairs(paths) do
        local t = loadfile_ex(p)
        local basename = string.match(p, "%a+//(.+)")
        if not filenames[basename] then
            filenames[basename] = true
            print("new share file: ", p)
            sharedata.new(p, value)
        else
            sharedata.update(basename)
            print("reload share file: ", p)
        end
    end
end

local CMD = {}

-- 热更新配置
function CMD.reload()
    reload_sharedata()
    return
end

skynet.dispatch("lua", function(_,_, command, ...)
    local f = CMD[command]
    skynet.ret(skynet.pack(f(...)))
end)

skynet.start(function()
    reload_sharedata()
    manager.register ".share"
    skynet.call(".dictator", "lua", "register_service", SVR_NAME, skynet.self())
    skynet.error("share service booted")
end)

local skynet = require "skynet"


skynet.start(function()
    skynet.newservice("debug_console", 7001)
    skynet.newservice("dictator")
    skynet.newservice("share")
    skynet.newservice("pbc")
    skynet.newservice("gamedb")
    skynet.newservice("watchdog")

    skynet.error("main end")
end)

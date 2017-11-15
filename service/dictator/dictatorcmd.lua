------------------------------
--此模块主要用于实现后台指令
------------------------------
local global = require "global"
local skynet = require "skynet"

-- RPC访问服务接口
-- 例如：热更新服务 dictator, 输入 call_svr dictator reload
function call_svr(stdin, print_back, ...)
    print("call_svr", ...)
    global.oDictatorObj:CallSvr(...)
end

-------------------- 测试 ---------------------
function test(stdin, print_back)
    global.oDictatorObj:TestFunc()
end

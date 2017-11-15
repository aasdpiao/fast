## fast
基于skynet的游戏服务端框架。

## 目录结构

~/fast$ tree -d
.
├── 3rd          -- 第3方依赖项目，包括skynet

├── build        -- 编译后的结果目录。实际部署时需要

├── config       -- 启动配置项

├── daobiao      -- 游戏配置。由策划配置XLS, 工具生成对应的Lua文件

├── luaclib      -- 游戏相关，C语言实现的Lua库

├── lualib       -- 游戏相关的Lua库

├── proto        -- protobuf 描述文件，跟客户端交互

├── service      -- skynet服务代码

└── test         -- 测试代码, 包括客户端实现

## 命令行

编译项目

```
~/fast$ make
```

运行skynet进程

```
    ./build/bin/skynet config/gs_config
```

运行客户端

```
    ./build/bin/lua test/client.lua
```

## 当前支持的服务

* dictator, 游戏后台控制。现在支持发送热更新指令
* [share](https://github.com/cloudwu/skynet/wiki/ShareData), 这个服务用来更新游戏配置
* [pbc](https://github.com/cloudwu/pbc), 这个服务用来protobuf协议编解码。
* gamedb, 游戏存储代理。当前支持Redis。
* watchdog & gate & agent. 每个客户端在watchdog 安全验证通过后，会分配绑定唯一的agent.
  游戏业务代码主要在 agent 里。

## 热更新

游戏框架支持热更新。 当前支持的服务包括: share, pbc, agent, gamedb 等.

取例：用户在 client.proto 增加新的协议， agentobj.lua 里增加新的命令分发函数后。
只需要这样操作，服务端就会自动更新。

```
~/fast$ telnet 127.0.0.1 7002   # 远程连上 dictator
Trying 127.0.0.1...
Connected to 127.0.0.1.
Escape character is '^]'.
Welcome to skynet dictator

call_svr pbc reload    # 输入：热更新协议
OK                     # 输出结果
call_svr agent reload  # 输入：热更新逻辑代码

# 同样，call_svr share reload 就可以更新游戏配置了
```

热更新建议

* 因为对性能影响很大。请只用在测试环境中。
* 部署定时任务，通过检查 proto, Lua 文件是否改变，进行触发reload

## 模拟客户端
模拟客户端程序是  test/client.lua

```
~/fast$ ./build/bin/lua test/client.lua
connect 127.0.0.1   8888    success!

# 输入：第一条登陆协议
send|LoginReq|{sdkid="qq",username="samuel", token="xx"}
# 输出
            {
            ["account"] = 100,
            }

# 输入：第二条协议,获取用户数据。
send|GetUserReq|{account=100}
# 输出
        {
        ["head"] = {
        ["errmsg"] = "succ",
        },
        }
```

输入格式是 **send|[请求协议名称]|[协议内容(lua表)]**

## 如何写业务代码

* 定制登陆过程。 文件 watchdog/main.lua 里的 sock_handler["LoginReq"] 函数。
* 增加新协议的处理函数。例如针对 GetUserReq， 在 agent/agentobj.lua 里增加新函数  CAgent:OnGetUserReq 就可以了。

## todo

* 增加 agent 池。控制服务器资源，加快 agent启动。
* 服务 chat, 多个agent之间的消息转发。

## 参考资料

* https://github.com/WeichengCao/game_dev
* https://github.com/charleeli/quick/
* https://github.com/yuanfengyun/chess_server

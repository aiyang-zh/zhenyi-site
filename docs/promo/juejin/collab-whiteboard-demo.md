> 本文介绍 [zhenyi](https://github.com/aiyang-zh/zhenyi) 的协作白板示例，展示如何用 Actor 模型极简实现实时协作。

# 一个 main.go 搞定协作白板：你画一笔，全世界都看见

一个房间里，你画一笔，其他人瞬间看到。新人进来，立刻同步到当前完整画面。点清空，所有人同时清空。

听起来不难？自己实现一下试试——

WebSocket 连接管理、消息路由、房间状态维护、快照同步、异常断连重连……随便一个环节处理不好就是 bug。

**zhenyi 的方式：一个 `main.go`，334 行，4 个 Handler，搞定。**

***

## 跑起来就知道了

```bash
go run ./examples/collab_whiteboard_demo -conn ws -addr 127.0.0.1:8011
# 浏览器打开：http://127.0.0.1:8081/collab_whiteboard_demo/web/
```

多开两个标签页。在一个上面画几笔——另一个实时看到。关掉一个再重新打开——秒级恢复完整状态。

***

## 为什么这么简单

整个服务端就一个 `main.go`，334 行，4 个 Handler：

| Handler       | 做什么                    |
| ------------- | ---------------------- |
| `MsgJoinReq`  | 加入房间，推完整 strokes 快照给新人 |
| `MsgDrawReq`  | 收一笔画，广播给房间所有人          |
| `MsgClearReq` | 清空画布，广播清空事件            |
| `MsgCloseReq` | 断开连接，清理房间状态            |

zhenyi 的 Actor 天然就是个单线程状态机——每个房间一个 Actor，内部状态不需要锁，消息按顺序处理，不存在并发问题。核心逻辑就这么直白：

```go
func (s *WhiteboardServer) pushStroke(origin *zmsg.Message, sessionID uint64, req stroke) {
    room := s.userRoom[sessionID]
    r := s.state.ensureRoom(room)
    r.Strokes = append(r.Strokes, req) // 存到房间状态
    s.broadcastRoom(origin, room, data) // 广播给所有人
}
```

新人加入时，Actor 直接把当前 strokes 快照推过去——**状态权威在服务端**，客户端只管画，不用担心不一致。

网关（Gate）帮你处理了 WebSocket 接入、协议解析、连接生命周期、消息路由。你不用写一行网络层代码。

***

## 背后不止一个 Demo

`collab_whiteboard_demo` 是 zhenyi 实时协作模型的一个缩影。同样的模式可以直接迁移到：

*   **多人文档协作** — 操作流广播 + 文档快照同步
*   **在线课堂白板** — 房间隔离 + 权限控制
*   **游戏状态同步** — Actor 单线程 = 无锁游戏逻辑
*   **实时监控看板** — 数据推送 + 新连接状态恢复

***

## 不只是白板

zhenyi 是一个完整的实时应用运行时：

*   **Actor 运行时**：单线程状态机、MPSC 无锁邮箱、Tick/RPC、协程池
*   **统一网关**：TCP / WebSocket / KCP，支持 TLS 和国密 GM-TLS
*   **分布式**：Etcd 服务发现 + NATS 跨进程总线 + 一致性哈希路由
*   **可观测**：Prometheus 指标 + 链路追踪 + 持续剖析
*   **脚本引擎**：Lua / JavaScript / Starlark / Tengo，业务逻辑热更新

底层由 [zhenyi-base](https://github.com/aiyang-zh/zhenyi-base) 提供高性能网络与基础组件（MIT 协议）：无锁队列、对象池零分配、Ring Buffer 零拷贝、epoll/kqueue Reactor。TCP Echo 压测 770K+ msg/s。

***

## 快速上手

```bash
# 协作白板（多开浏览器标签页体验）
go run ./examples/collab_whiteboard_demo -conn ws -addr 127.0.0.1:8011

# IM 聊天室
go run ./examples/im_single_demo

# MMO 同步演示
go run ./examples/mmo_web_demo
```

**相关链接：**

*   GitHub：[aiyang-zh/zhenyi](https://github.com/aiyang-zh/zhenyi) ｜ [zhenyi-base](https://github.com/aiyang-zh/zhenyi-base)
*   官网：[zhenyi-site.pages.dev](https://zhenyi-site.pages.dev/)

**交流群：** QQ 群 `1098078562`

***

5 分钟跑完 Demo，再决定要不要看源码。觉得不错的话，给个 Star ⭐。

***

## 一起搞？

zhenyi 还在早期，正需要人。不管你擅长什么，都有能参与的地方：

*   **写 Demo** — 用 zhenyi 做一个小应用（五子棋、协作画图、弹幕墙），PR 直接合并
*   **补测试** — 部分包覆盖率还有提升空间，`good first issue` 已标注
*   **写客户端 SDK** — JS/Unity/Flutter 客户端库，目前缺这块
*   **翻译文档** — 英文文档已有一部分，需要润色和补充
*   **提 Issue** — 发现 bug、体验不爽、有想法，直接开 Issue，每条都会看

不用报备，不用等分配，Fork → 改 → PR。或者先加群聊两句：

**QQ 交流群：** `1098078562`

---
name: flutter-network-api
description: 青轻生活馆现有后端 API 对接规范。
---

# API

## 1. 原则

后端 API 已存在。

Codex：

- 不开发后端
- 不修改后端接口
- 不猜测 API 字段
- 不虚构 API 地址
- 不虚构接口返回值

如果 API 信息缺失：

先根据现有项目查找。

仍然不存在时再询问用户。

---

# 2. 网络层

统一使用 Dio。

结构：

Dio
↓
Interceptor
↓
ApiClient
↓
DataSource
↓
Repository

---

# 3. Interceptor

统一处理：

- Base URL
- Token
- Header
- Content-Type
- Timeout
- 日志
- 401
- 网络错误

---

# 4. API Model

API Model 与 Domain Entity 分离。

例如：

ProductModel
ProductEntity

不要让 JSON Model 直接污染 UI。

---

# 5. API 状态

统一处理：

成功
业务失败
HTTP 错误
网络错误
超时
Token 失效

---

# 6. 分页

统一支持：

page
pageSize

或者按照现有 API 的分页规范。

禁止每个页面自己实现分页算法。

---

# 7. 防重复请求

以下操作必须防重复：

- 提交订单
- 支付
- 兑换积分商品
- 取消订单
- 申请售后
- 预约服务
---
name: flutter-state-management
description: 青轻生活馆 Riverpod 状态管理规范。
---

# Riverpod

## 1. 推荐

使用 Riverpod。

优先：

Notifier
AsyncNotifier
Provider
FutureProvider
StreamProvider

---

# 2. 状态分类

UI State：

- loading
- error
- empty
- selected
- expanded

Business State：

- user
- member
- cart
- order
- points
- coupon

Server State：

- product
- category
- activity
- service

---

# 3. Repository

Provider 不直接调用 Dio。

正确：

Page
↓
Provider
↓
Repository
↓
API

---

# 4. 不允许

禁止：

- Provider 内堆积所有业务
- 全局 Singleton 保存页面状态
- Widget 内维护复杂业务逻辑
- setState 解决跨页面业务状态

setState 只用于非常局部的 UI 状态。

---

# 5. 购物车

购物车必须支持：

- 查询
- 新增
- 删除
- 修改数量
- SKU
- 勾选
- 全选
- 金额计算
- 运费
- 优惠
- 积分抵扣

购物车状态必须跨页面共享。
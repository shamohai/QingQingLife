---
name: flutter-navigation
description: 青轻生活馆路由、Tab 状态保持、嵌套路由规范。
---

# Navigation

## 1. 推荐

使用 GoRouter。

---

# 2. Bottom Navigation

每个 Tab 必须保持独立 Navigation Stack。

例如：

首页
→ 商品详情
→ 活动详情

切换到商城：

商城
→ 商品列表
→ 商品详情

再回首页：

必须仍然停留在活动详情。

---

# 3. 必须保持

Tab 切换时：

- Navigation Stack
- Scroll Position
- 页面状态
- 搜索状态
- 筛选状态
- 分页状态

不得因为 Tab 切换而重新初始化。

---

# 4. 路由命名

统一：

/home
/shop
/service
/points
/profile

/product/:id
/activity/:id
/topic/:id

/cart
/checkout
/payment-result

/orders
/orders/:id

/coupons
/points
/points/mall

/address
/address/edit

---

# 5. 参数

禁止通过全局变量传递页面参数。

优先：

Path Parameters
Query Parameters
Extra（仅适合非持久业务对象）

---

# 6. 登录拦截

需要登录的页面必须支持：

未登录
→ 登录
→ 登录成功
→ 返回原页面

不得简单跳回首页。
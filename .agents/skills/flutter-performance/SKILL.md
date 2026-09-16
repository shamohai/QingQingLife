---
name: flutter-performance
description: 青轻生活馆 Flutter 性能优化规范。
---

# 性能

## 1. 列表

商品、订单、服务等长列表：

必须使用 ListView.builder / GridView.builder 等懒加载方式。

禁止：

一次性构建大量 Widget。

---

# 2. 图片

优先：

CachedNetworkImage

图片必须：

- 缓存
- 限制尺寸
- 避免原图直接展示
- 合理使用 cacheWidth / cacheHeight

---

# 3. 页面

避免：

build 内进行：

- API 请求
- 大量计算
- JSON 解析
- 数据库操作

---

# 4. 状态

避免无意义 rebuild。

合理使用：

select
family
autoDispose

---

# 5. Banner

首页 Banner：

- 懒加载
- 图片缓存
- 控制数量
- 避免高分辨率原图

---

# 6. 滚动

商品瀑布流、订单、积分流水必须支持高效滚动。

禁止使用：

SingleChildScrollView + 巨量 Column

来替代长列表。
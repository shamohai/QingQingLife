---
name: flutter-architecture
description: 青轻生活馆 Flutter 中大型项目架构规范。
---

# Flutter 中大型架构

## 1. 架构原则

采用 Feature-first + 分层架构。

推荐：

lib/
├── app/
├── core/
├── features/
└── main.dart

---

# 2. Feature 结构

示例：

features/
└── product/
    ├── data/
    │   ├── datasources/
    │   ├── models/
    │   └── repositories/
    ├── domain/
    │   ├── entities/
    │   ├── repositories/
    │   └── usecases/
    └── presentation/
        ├── pages/
        ├── widgets/
        └── providers/

---

# 3. 主要 Feature

一期至少包含：

- auth
- home
- product
- category
- cart
- checkout
- order
- member
- coupon
- points
- points_mall
- service
- benefit
- activity
- topic
- user
- address
- customer_service

后续：

- live
- seckill
- promotion

---

# 4. 依赖方向

UI
↓
Provider / Controller
↓
UseCase
↓
Repository
↓
DataSource
↓
API

禁止：

UI → Dio
UI → HTTP
UI → 数据库

---

# 5. 公共层

core/

├── network
├── storage
├── router
├── theme
├── constants
├── utils
├── errors
├── widgets
└── extensions

core 不允许依赖具体业务 Feature。

---

# 6. 代码原则

禁止：

- 超大 Widget
- 一个文件超过合理规模
- Page 内直接请求 API
- 全局变量保存业务状态
- 重复 Model
- 重复网络请求代码
- 魔法数字
- 魔法字符串

优先：

- 小组件
- 单一职责
- 可测试
- 可复用
- 可扩展
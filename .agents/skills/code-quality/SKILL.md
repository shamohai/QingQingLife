---
name: code-quality
description: 青轻生活馆生产级 Flutter 代码质量规范。
---

# Code Quality

## 1. Dart

必须通过：

dart format
dart analyze

---

# 2. 命名

使用：

lowerCamelCase
UpperCamelCase
snake_case 文件名

---

# 3. 禁止

禁止：

- 大量 TODO
- debugPrint 散落业务代码
- 魔法数字
- 魔法字符串
- 重复代码
- 未使用 import
- ignored analyzer warnings
- 无意义注释
- 巨型 Widget
- 巨型 Provider
- 巨型 Repository

---

# 4. 注释

注释解释：

为什么这样做。

而不是：

“调用接口”
“获取数据”

---

# 5. 修改代码

修改前：

1. 查找已有实现
2. 判断是否可以复用
3. 判断是否影响其他 Feature
4. 修改
5. Analyze
6. Test

---

# 6. 新增组件

如果一个组件可能被两个以上 Feature 使用：

应该放到：

core/widgets

或者：

shared

而不是复制两份。

---

# 7. 重构原则

优先小步修改。

禁止一次性大范围重构已有稳定代码。

---

# 8. 完成标准

一个功能只有满足：

- UI 完成
- Loading 完成
- Empty 完成
- Error 完成
- API 对接完成
- 状态管理完成
- 路由完成
- 异常处理完成
- Analyze 通过
- 测试通过

才算完成。
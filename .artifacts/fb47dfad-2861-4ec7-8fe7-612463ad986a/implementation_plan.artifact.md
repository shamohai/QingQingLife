# 架构优化与 Bug 修复实施计划

本计划旨在解决当前项目中的路由索引不匹配问题，并根据中大型项目规范优化 Repository 的存放结构，同时引入现代化的 Riverpod 代码生成方式以提升开发体验。

## 待修复/优化项

### 1. 底部导航索引对齐 [BUG 修复]
当前 `app_router.dart` 中的分支顺序与 `MainShell` 的 Tab 顺序不一致。
- **目标顺序**：首页 -> 积分商城 -> 特色商城 -> 购物车 -> 我的。
- **影响范围**：`lib/app/router/app_router.dart`。

### 2. Repository 归属重构 [架构优化]
将 Feature 特有的 Repository 接口从 `core` 层下沉到对应的 `features` 模块中，保持 `core` 层的精简。
- **保留在 core**：`AuthRepository` (全局共享)。
- **下沉到 features**：`ProductRepository`, `CartRepository`, `OrderRepository`, `PointsRepository`, `MemberRepository`。

### 3. Riverpod Generator 引入 [开发体验优化]
将传统的 `Provider` 定义方式逐步迁移到基于注解的 `riverpod_generator` 风格，增强类型安全。
- **依赖变更**：在 `pubspec.yaml` 中添加 `riverpod_annotation`。
- **重构范围**：`lib/core/providers/repository_providers.dart` 及其引用的 Repository 定义。

---

## 拟议变更

### 路由与 UI [Component: App Router]

#### [MODIFY] [app_router.dart](file:///F:/codexproject/flttercode/QingQingLife/lib/app/router/app_router.dart)
- 重新排列 `StatefulShellRoute.indexedStack` 中的 `branches` 数组。
- 确保 `MainShell` 的 `_tabBarItems` 数组索引与 `branches` 完全一一对应。

---

### 领域层重构 [Component: Features Domain]

#### [NEW] [product_repository.dart](file:///F:/codexproject/flttercode/QingQingLife/lib/features/product/domain/repositories/product_repository.dart)
#### [NEW] [cart_repository.dart](file:///F:/codexproject/flttercode/QingQingLife/lib/features/cart/domain/repositories/cart_repository.dart)
#### [NEW] [order_repository.dart](file:///F:/codexproject/flttercode/QingQingLife/lib/features/order/domain/repositories/order_repository.dart)
#### [NEW] [points_repository.dart](file:///F:/codexproject/flttercode/QingQingLife/lib/features/points/domain/repositories/points_repository.dart)
#### [NEW] [member_repository.dart](file:///F:/codexproject/flttercode/QingQingLife/lib/features/member/domain/repositories/member_repository.dart)

> [!NOTE]
> 移动文件后，将更新 `lib/core/providers/repository_providers.dart` 中的所有 import 引用。原 `lib/core/domain/repositories/` 下对应的文件将被内容清空或弃用。

---

### 状态管理优化 [Component: Providers]

#### [MODIFY] [pubspec.yaml](file:///F:/codexproject/flttercode/QingQingLife/pubspec.yaml)
- 添加 `riverpod_annotation: ^2.3.5` (匹配当前环境) 到 `dependencies`。
- 确认 `riverpod_generator` 已在 `dev_dependencies` 中。

#### [MODIFY] [repository_providers.dart](file:///F:/codexproject/flttercode/QingQingLife/lib/core/providers/repository_providers.dart)
- 使用 `@riverpod` 注解重写 Repository Providers。
- 引入生成的 `.g.dart` 文件。

---

## 验证计划

### 自动化验证
- 检查代码编译是否通过（无 Import 错误）。
- 提示用户运行 `flutter pub run build_runner build` 验证代码生成。

### 手动验证
- **Tab 切换测试**：点击底部五个 Tab，确认进入的页面与图标文字描述一致。
- **状态保持测试**：在“首页”滚动一定距离 -> 切换到“购物车” -> 切回“首页”，确认滚动位置和导航栈未丢失。

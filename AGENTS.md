# 青轻生活馆开发规则

这是一个生产级 Flutter 中型电商 App。

---

# 1. 开发前规则

开发任何任务前：

1. 必须阅读：

```text
.agents/skills/qingqing-product/SKILL.md
```

2. 根据当前任务类型，按需加载对应 Skill。
3. 不要一次性加载所有 Skill 和参考资料。
4. 只加载当前任务真正需要的规则和参考文件。
5. 修改已有代码前，先理解相关代码、状态、数据和路由，不得直接重写。

---

# 2. 核心技术与架构

项目核心技术栈：

- Flutter
- Dart
- Riverpod
- GoRouter
- Dio
- Repository Pattern
- Feature-first Architecture

后端 API 已存在。

项目必须遵循：

```text
.agents/skills/flutter-architecture/SKILL.md
.agents/skills/flutter-state-management/SKILL.md
.agents/skills/flutter-navigation/SKILL.md
.agents/skills/flutter-network-api/SKILL.md
```

根据任务类型按需加载，不要全部加载。

---

# 3. 后端 API 规则

AI Agent 只开发 Flutter App，禁止开发或修改后端。

禁止：

- 开发后端
- 创建后端项目
- 修改后端 API
- 虚构 API
- 虚构字段
- 虚构请求参数
- 虚构响应结构
- 为了页面展示自行创建不存在的接口

如果真实 API 信息不足：

1. 优先检查项目已有：
   - API 定义
   - Model
   - Repository
   - Service

2. 仍无法确认时，明确指出缺失信息。
3. 不得自行假设一个“看起来合理”的 API。

如果任务只要求 UI：

可以使用明确标记的 Mock 数据，但必须保持与真实 API 层可替换。

---

# 4. 产品范围

一期功能以：

```text
.agents/skills/qingqing-product/SKILL.md
```

中的产品规范为准。

一期架构必须能够继续扩展：

- 直播
- 秒杀
- 促销引擎
- 直播购物车
- 活动规则
- 会员体系
- 积分体系

禁止为了快速完成一期功能而采用无法扩展的临时架构。

---

# 5. Design-to-Code

任务涉及以下内容时，必须首先加载：

```text
.agents/skills/flutter-design-to-code/SKILL.md
```

适用范围：

- Axure 原型截图
- 蓝湖设计稿
- Figma 设计稿
- UI Screenshot
- 页面视觉还原
- Screenshot-to-Flutter
- Design-to-Code
- 根据设计稿实现 Flutter 页面

该 Skill 负责：

- 设计稿理解
- 页面结构识别
- 尺寸与间距分析
- 图片 / SVG / Icon 识别
- Design Token 提取
- Flutter UI 视觉还原
- 视觉一致性检查

目标：

```text
视觉高保真
+
Flutter 原生实现
+
符合现有项目架构
+
可维护
+
可扩展
```

不要机械地把：

```text
HTML
CSS
Figma Layer
Lanhu Design Spec
```

逐层翻译成 Flutter Widget。

必须转换为符合项目架构的：

- Feature
- Widget
- Theme
- Design Token
- 公共组件
- Repository
- Provider
- Model
- Router

---

# 6. 设计稿来源优先级

项目可能使用：

```text
Axure RP
Figma
Lanhu
Screenshot
```

如果存在结构化设计信息：

```text
结构化设计数据
        ↓
设计稿预览
        ↓
视觉确认
```

优先使用结构化信息，不要仅依赖截图猜测。

如果只有截图：

使用：

```text
flutter-design-to-code
```

进行视觉分析和布局推断。

如果蓝湖提供 Lanhu Context MCP 或其他结构化信息，优先获取：

- 页面结构
- Frame
- Component
- 尺寸
- 间距
- 字体
- 字号
- 字重
- 行高
- 颜色
- 圆角
- 边框
- 阴影
- 图片
- SVG
- Design Token
- 设计稿预览
- 切图资源

如果蓝湖与 Figma 同时存在：

优先使用结构化信息更完整的来源，并以最终设计稿视觉效果进行验证。

---

# 7. Design Token 与资源

## Design Token

设计稿中的：

- 主色
- 辅助色
- 背景色
- 文字色
- 分割线
- 圆角
- 字体
- 字号
- 间距

必须优先与项目现有 Theme / Design Token 对齐。

如果项目已有对应 Token：

**必须复用。**

如果设计稿产生新的全局设计规范，应考虑加入统一 Token，禁止在页面中大量散落硬编码。

## 图片与资源

设计稿中的：

- Banner
- 背景图
- 商品图
- Logo
- SVG
- Icon

必须优先使用真实设计资源。

禁止：

- 使用占位图片作为最终资源
- 使用随机网络图片
- 使用 AI 自行生成不同于设计稿的图片
- 使用错误尺寸导致明显模糊
- 擅自修改设计资源

资源统一进入项目 assets 管理体系。

命名应具有业务语义，例如：

```text
home_banner_main.webp
product_default.webp
order_empty.webp
icon_customer_service.svg
member_level_bg.webp
```

避免：

```text
image1.png
image2.png
icon1.png
test.png
```

---

# 8. 设计尺寸与 Flutter 布局

设计稿图片像素尺寸不等于 Flutter Widget 尺寸。

例如：

```text
设计稿：
1125 × 2436 px
```

不能直接使用：

```dart
width: 1125,
height: 2436
```

必须区分：

- 设计稿逻辑尺寸
- 图片实际像素尺寸
- Flutter Widget 布局尺寸
- 图片显示尺寸

高清图片应尽量保留原始资源质量。

禁止因为设计稿是固定尺寸而：

- 固定整个页面高度
- 固定整个页面宽度
- 大量使用绝对定位
- 大量使用屏幕坐标计算

优先使用 Flutter 正常布局：

- Row
- Column
- Stack
- Expanded
- Flexible
- SizedBox
- Padding
- Align
- ConstrainedBox
- LayoutBuilder
- MediaQuery
- Sliver

长列表必须支持自然滚动。

---

# 9. 系统安全区

全屏或底部贴边页面必须正确处理系统安全区。

适用：

- 登录页
- 绑定手机号
- 全屏背景图
- 底部协议
- 底部主按钮
- 底部固定文案

规则：

- 内容层使用 `SafeArea`
- 背景图需要全屏时，不要让 `SafeArea` 限制背景图
- `SafeArea` 应正确处理顶部状态栏和底部 Android 导航栏 / iOS Home Indicator

例如全屏背景页面：

```text
Stack
├── Background
└── SafeArea
    └── Content
```

禁止把内容直接压在屏幕物理最底部。

必须验证：

- Android 三键导航
- Android 手势导航
- iOS Home Indicator

确保底部内容不会被系统区域遮挡。

---

# 10. 公共组件与代码复用

实现功能前必须检查项目已有组件和公共能力。

优先复用：

```text
.agents/skills/ecommerce-components/SKILL.md
```

以及项目已有：

- Widget
- Repository
- Service
- Provider
- Model
- Router
- Theme
- Design Token
- 工具类

如果已有：

```text
ProductCard
CouponCard
OrderCard
Price
Button
BottomNavigation
EmptyState
Loading
```

等组件：

**禁止重复创建功能相同的组件。**

如果确实需要新的公共组件，应判断其是否具有跨页面复用价值。

---

# 11. 电商 UI

涉及以下业务：

- 商品
- 商品详情
- 购物车
- 订单
- 优惠券
- 会员
- 积分
- 活动
- 营销

必须按需加载：

```text
.agents/skills/ecommerce-components/SKILL.md
.agents/skills/ecommerce-ux/SKILL.md
```

---

# 12. Navigation

涉及：

- 页面跳转
- BottomNavigation
- Tab
- 嵌套路由
- Navigation Stack

必须加载：

```text
.agents/skills/flutter-navigation/SKILL.md
```

BottomNavigation 的每个 Tab 必须保持独立：

- Navigation Stack
- 页面状态
- 滚动位置
- 页面上下文

切换 Tab 时不得无故：

- 重建整个 Tab
- 清空 Navigation Stack
- 返回 Tab 首页
- 丢失页面状态
- 丢失滚动位置

禁止为了实现某个页面而破坏已有导航结构。

---

# 13. State Management

项目统一使用 Riverpod。

涉及状态管理时加载：

```text
.agents/skills/flutter-state-management/SKILL.md
```

禁止：

- 为单个页面引入其他状态管理方案
- 在 Widget 中堆积复杂业务状态
- 绕过现有 Provider 架构

优先复用已有 Provider。

---

# 14. 修改已有代码

修改已有页面或功能前必须：

1. 阅读当前页面实现。
2. 阅读相关 Provider。
3. 阅读相关 Repository / Service。
4. 阅读相关 Model。
5. 阅读相关 Router。
6. 检查已有公共组件。
7. 确认现有架构后再修改。

原则：

**最小范围修改。**

禁止：

- 不理解代码直接重写整个页面
- 删除无关业务逻辑
- 修改无关 API
- 修改无关路由
- 修改无关公共组件
- 为实现当前需求破坏已有功能

---

# 15. UI 视觉实现原则

根据设计稿实现页面时，必须尽量保持：

- 布局
- 间距
- 字体
- 字号
- 字重
- 颜色
- 图片
- 图片裁剪
- 圆角
- 阴影
- 分割线
- 对齐方式
- 层级关系

禁止 AI 因个人判断擅自：

- 增加 UI
- 删除 UI
- 修改文字
- 修改颜色
- 修改布局
- 增加设计稿没有的动画
- 增加设计稿没有的阴影
- 增加设计稿没有的渐变

---

# 16. Design-to-Code 视觉验收

Design-to-Code 任务完成后必须进行视觉检查。

至少检查：

- 页面整体比例
- 顶部区域
- Banner
- 图片尺寸
- 图片裁剪
- 字体大小
- 字体粗细
- 文字颜色
- 行高
- 元素间距
- 卡片圆角
- 阴影
- 分割线
- BottomNavigation
- Floating Button
- 滚动区域
- 不同屏幕尺寸适配
- Android / iOS 安全区

如果与设计稿存在明显差异，应继续修正。

**代码能够运行不等于 Design-to-Code 任务完成。**

---

# 17. 测试与代码质量

完成修改后，根据项目已有配置执行：

- `dart format`
- `flutter analyze`
- 单元测试
- Widget Test
- 集成测试

具体规则遵循：

```text
.agents/skills/code-quality/SKILL.md
```

涉及性能问题时按需加载：

```text
.agents/skills/flutter-performance/SKILL.md
```

涉及网络/API 时按需加载：

```text
.agents/skills/flutter-network-api/SKILL.md
```

不要为了通过检查而：

- 关闭 lint
- 删除测试
- 忽略 analyzer 错误
- 绕过项目既有质量规则

---

# 18. Skill 加载规则

根据任务按需加载。

| 任务                                | Skill                      |
| ----------------------------------- | -------------------------- |
| 所有产品开发任务                    | `qingqing-product`         |
| Design-to-Code / 设计稿             | `flutter-design-to-code`   |
| 架构 / Feature / Repository / Model | `flutter-architecture`     |
| Widget / 电商组件                   | `ecommerce-components`     |
| 电商交互 / UX                       | `ecommerce-ux`             |
| 路由 / Tab / Navigation             | `flutter-navigation`       |
| Riverpod / 状态                     | `flutter-state-management` |
| API / Dio / 网络                    | `flutter-network-api`      |
| 性能                                | `flutter-performance`      |
| 测试 / Lint / Code Quality          | `code-quality`             |

**不要因为 Skill 存在就全部加载。**

只加载当前任务真正需要的 Skill。

---

# 19. 最终原则

本项目的目标不是：

> 让 AI 尽快生成能够运行的 Flutter 页面。

而是：

> **让 AI 根据产品规范和设计稿，生成能够进入生产项目的 Flutter 代码。**

最终代码必须满足：

```text
产品正确
+
视觉高保真
+
Flutter 最佳实践
+
现有架构一致
+
组件复用
+
状态正确
+
导航正确
+
API 不虚构
+
可维护
+
可扩展
```

其中：

```text
flutter-design-to-code
```

负责：

**设计理解 + 视觉还原**

而：

```text
flutter-architecture
flutter-navigation
flutter-state-management
ecommerce-components
ecommerce-ux
flutter-network-api
flutter-performance
code-quality
```

负责：

**工程实现 + 架构 + 业务代码质量。**

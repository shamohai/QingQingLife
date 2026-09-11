# 青轻生活馆开发规则

这是一个生产级 Flutter 中型电商 App。

## 1. 开发前必须阅读

开发任何任务前：

1. 阅读：

```text
.agents/skills/qingqing-product/SKILL.md
```

2. 根据任务类型加载对应 Skill。
3. 不要一次性加载所有 Skill 和参考资料。
4. 只加载当前任务真正需要的规则和参考文件。

---

# 2. 核心技术原则

项目核心技术栈：

- Flutter
- Dart
- Riverpod
- GoRouter
- Dio
- Repository Pattern
- Feature-first Architecture

后端 API 已存在。

禁止：

- 开发后端
- 修改后端 API
- 虚构 API
- 为了页面展示自行创建不存在的接口
- 破坏已有架构
- 重复创建已有组件
- 重复实现已有公共能力

实现功能时必须优先复用项目已有：

- Widget
- Repository
- Service
- Provider
- Model
- Router
- Theme
- Design Token
- 工具类

---

# 3. BottomNavigation 导航规则

必须保持 BottomNavigation 各 Tab 独立的：

- Navigation Stack
- 页面状态
- 滚动位置
- 页面上下文

切换 Tab 时，不得无故：

- 重建整个 Tab
- 清空 Navigation Stack
- 返回 Tab 首页
- 丢失页面状态
- 丢失滚动位置

涉及导航的任务必须遵循：

```text
.agents/skills/flutter-navigation/SKILL.md
```

---

# 4. 产品范围

一期功能以：

```text
.agents/skills/qingqing-product/SKILL.md
```

中的产品规范为准。

当前项目虽然以一期功能为主要开发目标，但架构必须能够继续扩展：

- 直播
- 秒杀
- 促销引擎
- 直播购物车
- 活动规则
- 会员体系
- 积分体系

不要为了实现一期功能而采用无法扩展到上述业务的临时架构。

---

# 5. 后端 API

后端 API 已存在。

AI Agent：

- 不开发后端
- 不创建后端项目
- 不修改后端接口
- 不虚构 API
- 不虚构字段
- 不虚构请求参数
- 不虚构响应结构

如果真实 API 信息不足：

1. 优先检查项目已有 API 定义、Model、Repository、Service。
2. 如果仍然无法确认，应明确指出缺失信息。
3. 不得自行假设一个“看起来合理”的 API。

如果任务只要求完成 UI，可以使用明确标记的 Mock 数据，但 Mock 必须与真实 API 层保持可替换结构。

---

# 6. Design-to-Code Routing

当任务涉及以下内容：

- Axure 原型截图
- 蓝湖设计稿
- Figma 设计稿
- UI Screenshot
- 页面视觉还原
- 高保真 UI 实现
- Screenshot-to-Flutter
- Design-to-Code
- 根据设计稿实现 Flutter 页面

必须首先读取：

```text
.agents/skills/flutter-design-to-code/SKILL.md
```

该 Skill 负责：

- 设计稿理解
- 视觉信息提取
- 页面结构识别
- 尺寸分析
- 图片/图标识别
- Design Token 提取
- Flutter UI 视觉还原
- 视觉一致性检查

---

# 7. 蓝湖设计稿

当任务提供蓝湖设计稿或 Lanhu Context MCP 时：

优先使用蓝湖提供的结构化设计信息，而不是仅通过截图猜测。

优先获取：

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

如果蓝湖能够提供结构化设计数据：

**不得退化为单纯的截图视觉猜测。**

设计稿截图用于：

- 视觉确认
- 最终验收
- 结构化数据无法表达的视觉细节判断

---

# 8. Lanhu / Figma / Axure 的优先级

本项目可能存在多种设计来源：

```text
Axure RP
Figma
Lanhu
Screenshot
```

它们都属于 Design-to-Code 输入。

原则：

### 如果存在结构化设计信息

优先：

```text
结构化设计数据
        ↓
设计稿预览
        ↓
视觉确认
```

而不是：

```text
截图
 ↓
AI 猜测
```

### 如果只有截图

使用：

```text
flutter-design-to-code
```

进行视觉分析和布局推断。

### 如果蓝湖与 Figma 同时提供同一页面

优先使用能够提供更完整结构化信息的来源，并以最终设计稿视觉效果进行验证。

---

# 9. 设计稿不是最终 Flutter 代码

不要机械地把：

```text
HTML
CSS
Figma Layer
Lanhu Design Spec
```

直接翻译成 Flutter Widget。

必须转换为符合本项目架构的：

- Flutter Widget
- Feature
- Theme
- Design Token
- 公共组件
- 页面组件
- Repository
- Provider
- Model
- Router

目标是：

**视觉高保真 + Flutter 原生实现 + 符合现有项目架构 + 可长期维护。**

---

# 10. 设计尺寸与 Flutter 逻辑像素

设计稿中的图片像素尺寸不等于 Flutter Widget 尺寸。

例如：

```text
设计稿图片：
1125 × 2436 px
```

不能直接转换成：

```dart
width: 1125,
height: 2436
```

必须区分：

- 设计稿逻辑尺寸
- 图片资源实际像素尺寸
- Flutter Widget 布局尺寸
- 图片显示尺寸

高清图片应尽量保留原始资源质量。

---

# 11. 图片与资源

设计稿中的：

- Banner
- 背景图
- 商品图
- Logo
- SVG
- Icon

必须优先使用真实设计资源。

禁止：

- 使用占位图片代替最终资源
- 使用网络随机图片
- 使用 AI 自行生成与设计稿不同的图片
- 使用错误尺寸导致明显模糊
- 擅自修改设计资源

资源必须进入项目统一的 assets 管理体系。

资源命名应具有业务语义，例如：

```text
home_banner_main.webp
product_default.webp
order_empty.webp
icon_customer_service.svg
member_level_bg.webp
```

不要使用：

```text
image1.png
image2.png
icon1.png
test.png
```

---

# 12. Design Token

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

应优先与项目现有 Theme / Design Token 对齐。

如果项目已有对应 Token：

**必须优先复用。**

如果设计稿产生新的全局设计规范：

应考虑加入统一 Token，而不是在页面中散落大量硬编码。

---

# 13. 组件复用

实现设计稿前必须检查项目已有组件。

优先复用：

```text
ecommerce-components
```

中的组件。

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

**禁止重新创建功能重复的组件。**

如果当前设计稿确实需要新的公共组件，应先判断该组件是否具有跨页面复用价值。

---

# 14. UI 实现

设计稿实现必须尽量保持：

- 布局
- 间距
- 字体
- 颜色
- 图片
- 圆角
- 阴影
- 对齐方式
- 层级关系

禁止 AI 因为个人判断：

- 随意增加 UI
- 删除 UI
- 修改文字
- 修改颜色
- 修改布局
- 增加设计稿没有的动画
- 增加设计稿没有的阴影
- 增加设计稿没有的渐变

---

# 15. 响应式与适配

不要机械复制设计稿画布尺寸。

禁止因为设计稿是固定尺寸而：

- 固定整个页面高度
- 固定整个页面宽度
- 使用大量绝对定位
- 使用大量屏幕坐标计算

优先使用 Flutter 正常布局体系：

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

对于商品列表、订单列表等长内容页面，必须支持自然滚动。

### 全屏 / 底部贴边页面必须预留底部系统区

登录、绑定手机号、全屏背景图等「贴底」内容，必须为底部系统区预留高度，避免文案/按钮被 Android 虚拟导航栏或 iOS Home Indicator 遮挡：

- 外层 Stack / 主内容区用 `SafeArea(top: true, bottom: true)` 包裹，让系统自动预留顶部状态栏和底部虚拟导航栏高度。
- 若页面需全屏铺满背景（如登录页），`SafeArea` 仅包裹内容层，不包裹背景图；背景图仍从 `top: 0` / `bottom: 0` 开始。


禁止把协议、主按钮、底部文案直接压在屏幕物理最底部而不考虑系统区。验收：Android 开启三键 / 手势导航栏时，贴底内容不被遮挡。

---

# 16. Architecture

涉及项目结构、Feature、Repository、Provider、Model 等实现时：

遵循：

```text
.agents/skills/flutter-architecture/SKILL.md
```

不要为了快速生成 UI 而绕过项目架构。

---

# 17. State Management

涉及状态管理时：

遵循：

```text
.agents/skills/flutter-state-management/SKILL.md
```

项目统一使用 Riverpod。

禁止为了某个页面临时引入其他状态管理方案。

---

# 18. Navigation

涉及页面跳转、BottomNavigation、嵌套路由、Tab Stack 时：

遵循：

```text
.agents/skills/flutter-navigation/SKILL.md
```

不得破坏已有导航状态。

---

# 19. 电商 UI

涉及：

- 商品
- 购物车
- 订单
- 优惠券
- 会员
- 积分
- 活动
- 营销
- 商品详情

等电商 UI 时：

遵循：

```text
.agents/skills/ecommerce-components/SKILL.md
.agents/skills/ecommerce-ux/SKILL.md
```

---

# 20. 修改已有页面

修改已有代码前：

1. 阅读当前页面实现。
2. 阅读相关 Provider。
3. 阅读相关 Repository / Service。
4. 阅读相关 Model。
5. 阅读相关 Router。
6. 检查是否已有公共组件。
7. 再进行修改。

禁止：

- 不理解代码直接重写整个页面
- 删除无关业务逻辑
- 修改无关 API
- 修改无关路由
- 修改无关公共组件

优先进行最小范围修改。

---

# 21. 视觉验收

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

如果与设计稿存在明显差异，应继续修正。

**“代码能够运行”不等于 Design-to-Code 任务完成。**

---

# 22. 测试与代码质量

完成修改后，根据项目已有配置执行：

- dart format
- flutter analyze
- 单元测试
- Widget Test
- 集成测试

具体要求遵循：

```text
.agents/skills/code-quality/SKILL.md
```

不要为了通过检查而关闭 lint 或删除已有测试。

---

# 23. Skill 加载原则

根据任务按需加载 Skill。

基础：

```text
qingqing-product
```

Design-to-Code：

```text
flutter-design-to-code
```

架构：

```text
flutter-architecture
```

组件：

```text
ecommerce-components
ecommerce-ux
```

导航：

```text
flutter-navigation
```

状态：

```text
flutter-state-management
```

网络：

```text
flutter-network-api
```

性能：

```text
flutter-performance
```

代码质量：

```text
code-quality
```

**不要因为存在这些 Skill 就全部加载。**

只加载当前任务需要的 Skill。

---

# 24. 最终原则

本项目的 AI 开发目标不是：

> “让 AI 尽快生成能够运行的 Flutter 页面。”

而是：

> **让 AI 根据产品规范和设计稿，生成能够进入生产项目的 Flutter 代码。**

最终代码必须同时满足：

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

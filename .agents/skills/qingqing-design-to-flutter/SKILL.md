# QingQingLife Design to Flutter Skill

## 1. Skill 目标

本 Skill 用于：

* 蓝湖 MCP 设计稿 → Flutter 页面
* Figma/Sketch/设计稿 → Flutter 页面
* 设计稿截图 → Flutter 页面
* 设计稿节点结构 → Flutter Widget 结构
* Flutter 页面截图 → 设计稿视觉验收

核心目标：

> **先正确理解设计稿结构，再生成 Flutter 代码。**

禁止：

```text
设计稿
↓
直接生成大量 Flutter 代码
```

必须：

```text
设计稿 / 蓝湖 MCP
        ↓
设计分析
        ↓
Flutter Widget Tree
        ↓
结构自检
        ↓
代码实现
        ↓
运行截图
        ↓
视觉对比
        ↓
修正
```

---

# 2. 强制执行模式

涉及以下任务时必须启用本 Skill：

* 根据蓝湖 MCP 设计稿开发页面
* 根据设计稿截图开发页面
* 根据 Figma / Sketch 设计稿开发页面
* 修改已有页面以匹配设计稿
* 根据设计稿还原 Flutter UI
* 检查 AI 生成的 Flutter UI 是否符合设计稿

---

# 3. 第一阶段：设计稿分析

## 3.1 禁止直接写代码

第一次读取设计稿后：

**禁止立即生成 Flutter 页面代码。**

必须先分析：

### 页面结构

* 页面整体布局
* 顶部区域
* 内容区域
* 底部区域
* 固定区域
* 滚动区域
* Row
* Column
* Stack
* ListView
* GridView
* Expanded
* Flexible
* Spacer
* Padding
* Align
* Center

### 视觉信息

* 背景颜色
* 文字颜色
* 字号
* 字重
* 行高
* 图片尺寸
* Icon 尺寸
* 圆角
* 边框
* 阴影
* Padding
* 间距
* 对齐方式

---

# 4. 蓝湖 MCP 特别规则

蓝湖 MCP 返回的设计节点：

```text
不是 Flutter Widget Tree
```

不得机械地将：

```text
Frame
Group
Rectangle
Text
Vector
```

直接转换成：

```text
Container
Container
Container
Text
Icon
```

必须重新判断视觉和布局关系。

例如设计稿：

```text
Frame
├── Group
│   ├── Image
│   └── Text
├── Group
└── Icon
```

不能机械生成：

```text
Container
├── Container
│   ├── Image
│   └── Text
├── Container
└── Icon
```

应该分析实际关系是否为：

```text
Row
├── Image
├── Column
│   ├── Text
│   └── Text
├── Spacer
└── IconButton
```

---

# 5. 第二阶段：生成 Widget Tree

设计稿分析完成后，必须首先输出：

```text
Flutter Widget 结构树
```

格式：

```text
Scaffold
└── SafeArea
    └── Column
        ├── Row (顶部用户信息)
        │   ├── CircleAvatar (头像)
        │   ├── SizedBox(width: 12)
        │   ├── Column (用户信息)
        │   │   ├── Text (昵称)
        │   │   └── Text (个性签名)
        │   ├── Spacer
        │   └── IconButton (设置)
        │
        ├── SizedBox(height: 16)
        │
        ├── Row (数据统计)
        │   ├── Column
        │   │   ├── Text (数字)
        │   │   └── Text (标签)
        │   ├── Column
        │   │   ├── Text (数字)
        │   │   └── Text (标签)
        │   └── Column
        │       ├── Text (数字)
        │       └── Text (标签)
        │
        └── Expanded
            └── ListView
```

结构树必须表达：

1. 父子关系
2. 布局方向
3. 主要 Widget
4. Widget 用途
5. 关键间距
6. 关键尺寸
7. 对齐方式

---

# 6. Widget 选择规则

## 6.1 Row

横向排列优先使用：

```dart
Row
```

例如：

```text
头像 | 用户信息 | 空白 | 设置按钮
```

优先：

```dart
Row(
  children: [
    avatar,
    userInfo,
    const Spacer(),
    settingsButton,
  ],
)
```

---

## 6.2 Column

纵向排列优先使用：

```dart
Column
```

例如：

```text
昵称
签名
```

使用：

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    nickname,
    signature,
  ],
)
```

---

## 6.3 Spacer

当两个区域需要占据两端：

```text
左侧内容                         右侧按钮
```

优先：

```dart
Spacer()
```

禁止使用大量：

```dart
SizedBox(width: 100)
```

模拟空白。

---

## 6.4 Expanded

当某个区域应该占据剩余空间：

```dart
Expanded(
  child: ...
)
```

常见场景：

```text
固定 Header
+
剩余区域 ListView
```

使用：

```dart
Column(
  children: [
    header,
    Expanded(
      child: ListView(...),
    ),
  ],
)
```

---

## 6.5 Flexible

当内容需要弹性缩放，但不应该强制占满剩余空间时：

```dart
Flexible(
  child: ...
)
```

---

## 6.6 Stack

只有存在真实层叠关系时使用：

* 图片覆盖文字
* Badge
* 角标
* 头像状态
* 悬浮按钮
* Banner 覆盖元素
* 装饰元素

禁止使用 Stack 解决普通：

```text
左右排列
上下排列
两端对齐
```

---

# 7. 对齐规则

优先使用：

```dart
mainAxisAlignment
crossAxisAlignment
```

例如：

```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  crossAxisAlignment: CrossAxisAlignment.center,
)
```

以及：

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
)
```

不要通过大量 Padding 调整普通对齐关系。

---

# 8. Hardcode 规则

## 可以固定

设计稿明确要求的：

* Icon 尺寸
* 头像尺寸
* 按钮高度
* 图片比例
* 特殊组件尺寸
* 标准圆角
* 明确设计间距

例如：

```dart
const SizedBox(width: 12)
```

是合理的。

---

## 禁止滥用

以下代码必须谨慎：

```dart
SizedBox(width: 173)
SizedBox(width: 247)
SizedBox(height: 83)
Padding(left: 91)
Container(width: 326)
Positioned(left: 137)
```

如果这些值只是为了把元素“推到设计稿位置”，必须重新检查：

```text
Row
Column
Spacer
Expanded
Flexible
Align
mainAxisAlignment
crossAxisAlignment
```

是否使用错误。

---

# 9. 设计稿尺寸处理

设计稿中的像素尺寸：

**不能全部一比一硬编码到 Flutter。**

必须区分：

```text
设计规范尺寸
```

和：

```text
布局定位尺寸
```

例如：

```text
头像 56 × 56
```

通常可以保留。

但是：

```text
为了让右侧按钮距离左边 287px
```

不应该直接：

```dart
SizedBox(width: 287)
```

应该分析父级布局关系。

---

# 10. 第三阶段：结构自检

生成 Widget Tree 后必须进行自检。

## 布局检查

```text
[ ] Row / Column 层级合理
[ ] 没有错误使用 Stack
[ ] Spacer 使用合理
[ ] Expanded 使用合理
[ ] Flexible 使用合理
[ ] mainAxisAlignment 合理
[ ] crossAxisAlignment 合理
[ ] 没有不必要的固定宽高
[ ] 没有大量用于定位的 SizedBox
[ ] 没有大量用于定位的 Padding
[ ] 滚动区域正确
[ ] 固定区域正确
```

## 视觉检查

```text
[ ] 背景颜色
[ ] 文字颜色
[ ] 字号
[ ] 字重
[ ] 行高
[ ] Icon 大小
[ ] 图片尺寸
[ ] 圆角
[ ] 边框
[ ] 阴影
[ ] Padding
[ ] 元素间距
[ ] 对齐方式
```

---

# 11. 结构树输出完成后停止

默认情况下：

**完成 Widget Tree 后停止生成代码。**

输出：

```text
## 页面结构

...

## 布局说明

...

## 视觉参数

...

## 结构自检

...

## 待确认问题

...
```

然后等待用户确认。

如果用户明确要求：

```text
直接实现
```

或者：

```text
结构没有问题，继续写代码
```

才进入代码阶段。

---

# 12. 第四阶段：Flutter 实现

结构确认后再生成 Flutter。

代码结构必须尽可能与 Widget Tree 一致。

例如 Widget Tree：

```text
Row
├── CircleAvatar
├── SizedBox
├── Column
│   ├── Text
│   └── Text
├── Spacer
└── IconButton
```

代码应该保持：

```dart
Row(
  children: [
    const CircleAvatar(...),
    const SizedBox(width: 12),
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(...),
        Text(...),
      ],
    ),
    const Spacer(),
    IconButton(...),
  ],
)
```

禁止：

```text
结构树使用 Row
↓
代码实现改成 Stack + Positioned + 大量固定尺寸
```

除非实现过程中发现结构分析错误，并重新修正 Widget Tree。

---

# 13. TextStyle 规则

设计稿中的文字必须尽可能完整表达：

```dart
TextStyle(
  fontSize: ...,
  fontWeight: ...,
  color: ...,
  height: ...,
  letterSpacing: ...,
)
```

不要只写：

```dart
Text(
  'xxx',
  style: TextStyle(
    fontSize: 16,
  ),
)
```

如果设计稿提供了对应视觉信息，应完整表达。

---

# 14. 颜色规则

设计稿中明确存在颜色时：

优先使用项目已有的：

```text
Theme
ColorScheme
Design Tokens
AppColors
```

如果项目已经定义了对应颜色：

**禁止重复创建颜色常量。**

只有项目没有对应设计 Token 时，才根据设计稿补充。

---

# 15. 组件复用规则

如果设计稿中出现重复结构：

```text
商品卡片
订单卡片
优惠券卡片
统计项
菜单项
```

不要重复复制大量 Widget。

应识别为：

```text
Reusable Component
```

例如：

```text
StatisticsItem
ProductCard
OrderCard
CouponCard
MenuItem
```

但是：

**不要为了复用而过度抽象。**

只有结构和视觉确实稳定重复时才抽取组件。

---

# 16. 页面拆分规则

复杂页面必须按视觉区域拆分。

例如：

```text
ProfilePage
├── ProfileHeader
├── StatisticsSection
├── MemberSection
├── CouponSection
├── OrderSection
└── RecommendationSection
```

而不是生成一个几百行的：

```text
ProfilePage
```

---

# 17. 单组件开发规则

如果设计稿复杂：

**优先化整为零。**

推荐：

```text
完整页面
↓
区域
↓
Card
↓
Component
```

例如：

```text
ProfilePage
    ↓
UserHeader
    ↓
StatisticsSection
    ↓
StatisticsItem
```

每个组件分别：

```text
设计稿
↓
结构识别
↓
Widget Tree
↓
Flutter
↓
截图验证
```

---

# 18. 截图验证

代码完成后：

1. 运行 Flutter 页面
2. 获取实际页面截图
3. 与设计稿进行视觉对比
4. 找出差异
5. 优先修改布局结构
6. 再修改视觉参数
7. 再次截图验证

检查顺序：

```text
第一层：整体布局
第二层：区域位置
第三层：元素尺寸
第四层：间距
第五层：文字
第六层：颜色
第七层：圆角 / 阴影 / 边框
```

不要一开始就纠结 1px 的颜色或间距问题。

---

# 19. 截图差异修正规则

发现页面与设计稿不一致时：

## 优先检查结构

例如：

```text
设计稿：
头像 + 用户信息 + 右侧按钮

实际：
头像 + 用户信息
右侧按钮位置错误
```

首先检查：

```text
Row
Spacer
Expanded
mainAxisAlignment
crossAxisAlignment
```

不要立即增加：

```dart
Padding(left: ...)
```

---

## 其次检查尺寸

例如：

```text
头像过大
```

修改：

```dart
width / height / radius
```

而不是移动其他元素。

---

## 最后检查视觉

例如：

```text
字体偏粗
颜色偏深
```

修改：

```dart
TextStyle
```

---

# 20. 防止 AI 自我扩大修改范围

修改设计稿对应页面时：

**只修改必要范围。**

禁止因为一个组件的位置错误而：

* 重构整个页面
* 修改项目架构
* 修改无关页面
* 修改 API
* 修改 Repository
* 修改状态管理
* 修改路由
* 修改全局 Theme

除非用户明确要求。

---

# 21. 后端规则

本 Skill 只负责 Flutter 前端。

后端 API 已经存在。

禁止：

```text
自行设计 API
自行修改 API
自行创建后端接口
自行猜测 API 字段
```

如果页面需要 API：

```text
读取项目已有 API 定义
```

如果不存在：

```text
明确指出缺少 API 信息
```

不得虚构。

---

# 22. 与项目其他 Skill 的关系

本 Skill 只负责：

```text
设计稿
↓
UI 结构
↓
Flutter UI
↓
视觉验证
```

以下内容交由其他 Skill：

```text
Flutter Architecture
State Management
Navigation
Network / API
Performance
Code Quality
Product Rules
```

开发时只加载当前任务需要的 Skill。

不要一次性加载全部 Skill。

---

# 23. 推荐工作模式

### 模式 A：只分析

用户：

```text
根据蓝湖设计稿分析这个页面
```

执行：

```text
读取设计稿
↓
分析
↓
Widget Tree
↓
自检
↓
停止
```

不写代码。

---

### 模式 B：分析 + 实现

用户：

```text
根据蓝湖设计稿实现这个页面
```

执行：

```text
读取设计稿
↓
Widget Tree
↓
结构自检
↓
如果任务明确允许直接实现
↓
Flutter
↓
运行
↓
截图
↓
视觉验证
↓
修正
```

---

### 模式 C：已有代码对照设计稿

用户：

```text
这个页面和蓝湖设计稿不一致
```

执行：

```text
读取设计稿
↓
读取现有代码
↓
Widget Tree 对照
↓
找出结构差异
↓
找出视觉差异
↓
最小范围修改
↓
截图
↓
再次验证
```

---

# 24. 最终执行原则

始终遵循：

```text
先结构
再代码

先布局
再视觉

先组件
再页面

先最小修改
再考虑重构

先验证
再结束
```

最重要的原则：

> **设计稿图层结构不是 Flutter Widget 结构。**

> **不要机械转换设计稿节点。**

> **先理解设计意图，再建立合理的 Flutter Widget Tree。**

> **Widget Tree 未确认时，不要盲目生成复杂 Flutter 代码。**

> **视觉还原优先通过正确的布局模型解决，而不是通过大量 Hardcode 修位置。**

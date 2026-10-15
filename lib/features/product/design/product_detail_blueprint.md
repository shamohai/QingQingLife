# 商品详情实现蓝图

## 当前实现状态（2026-10-13）

第一版已实现并在浏览器运行，成熟度 L3；以下原始蓝图是设计目标，不代表已完成逐像素验收。
实际检查：新增 Dart 文件与路由的 flutter analyze 无问题；Web 编译成功；440/390/320 宽截图、滚动和底栏检查完成，无捕获到的运行时异常。320 宽购买按钮保持单行。全项目 analyze 仍有其他模块既有问题（service 模块缺失引用等）；项目没有现有 test 目录，未运行测试。
当前差异：评价照片保留真实导出条带，尚未拆图或实现图片查看；排行图标暂用 Material workspace_premium；立即购买按钮暂用纯蓝色；平台字体与设计字体可能不同；主图只有一张。客服、券入口、全部评价、加购和购买均明确提示本地预览待接入。未接真实 API。
OpenSpec CLI 在当前环境不可用，实施依照本文件的布局蓝图完成，未执行 OpenSpec CLI 流程或标记任务完成。
预览：http://localhost:8080/#/product/1。

来源：蓝湖 image_id `9edfe3e0-580b-45bf-977c-051f2ee9979d`，已读取完整 HTML/CSS、切图映射与预览。
入口：`/product/:id`。本次以 `/product/1` 展示设计商品；其他正整数 id 复用明确的本地设计样例，非法 id 返回空状态。
Implementation Ready: YES。全程 Local Mock，无真实商品、优惠、购物车、订单 API。

## 布局与 Visual IR

基准宽 440；桌面容器最大 440，手机填满可用宽度。主图 1:1，正文自然增高，禁止固定整页高度。
首屏 440×900：主图、价格权益卡和评价卡开头，底部固定购买栏；设备状态栏与 Home Indicator 不实现。

| section / Key | 来源 bbox | 布局及内部角色 | token / 素材 | 截图通过条件 |
|---|---|---|---|---|
| product-hero | 0,0,439,439 | 方形商品照片；左上返回+商品详情；底部三点 | 返回栏 106×40，radius6，黑色30%；标题18 medium；圆点10 gap10；真实 detail-hero.png 完整显示 | 照片无拉伸；返回可点击；无假系统状态栏 |
| product-price-benefits | 14,453,414,374 | 橙色价格区+白色权益区；白色圆角覆盖橙色底；标题、规格标签、价格、会员价、原价、销量、工艺描述、分割线、券入口、排行、提示 | radius14；左右10；橙色 #FF3C0C→#FF9564；标题20 medium，价格32 semibold，币种/小数18；标签12 radius8 height20；会员价14 height25；原价/销量16；描述14×1.5；券14 height25；榜单 #FFEDD9/#D39858 height44 radius8；提示12 #8E8E93 | 全部文字角色保留；权益紧接价格；分隔线1；窄屏文字自然换行，无裁切 |
| product-reviews | 14,837,414,475 | 标题+数量+查看全部；两条评价：头像/昵称/3红2灰星/时间、正文、第一条3张照片/第二条2张 | 白色 radius14 padding10；标题18 semibold，数量12；underline94×7 #0088FF→透明；头像26；昵称/时间16；正文16×1.4；照片70×70 gap11 | 评价内容与设计一致；无强制换行定位；照片独立文件、可查看；时间右对齐 |
| product-description | 14,1322,414,668 | 标题+渐变下划线，商品真实长图 | 白色 radius14 padding10；标题18；长图比例395:600，BoxFit.contain，底部18 | 长图保持比例；底部可滚动到达；不使用整页截图代替UI |
| product-purchase-bar | 0,1900,440,80 | 首页/客服/购物车：裸图标上+文字下；加入购物车/立即购买：左右拼接胶囊 | 白色；shadow黑10% blur4 offset(0,-2)；图标24、文字14；CTA height47，文字18 medium；浅蓝与 #213775→#3152AF | 固定在视口底部；真实SafeArea；五个操作完整；320宽无横向溢出 |

字体采用现有 AppTextStyles.copyWith；没有项目内 PingFang HK，保留平台字体差异。正文14/16；次要标签12，仅为稀疏规格/计数/提示。Flutter 使用逻辑像素，非750rpx项目，不混用单位。系统文本缩放保留，卡片不固定高度。

## Widget Tree

Center → ConstrainedBox(maxWidth440) → Scaffold
- body: SafeArea(bottom:false) → AsyncValue(Loading/Error/Empty/Content)
- Content: RefreshIndicator → CustomScrollView → SliverToBoxAdapter(hero) + SliverPadding(horizontal14, top14) → SliverList(price-benefits, gap10, reviews, gap10, description)
- bottomNavigationBar: ProductPurchaseBar → SafeArea(top:false) → Row(icon actions + Expanded(joined CTA))

价格和权益使用白色底的组合卡与橙色底的局部圆角覆盖，只在交界处使用真实叠层；普通内容使用 Row/Column，不依赖导出稿绝对坐标。返回直接打开时回首页，有栈时pop。

## 素材 / 图标

独立主图、长图、头像、购物车图标来自MCP资源。评价条带按实际像素裁成独立照片，不在UI里裁条带。其余图标复用已安装 Cupertino/Material 图标：返回chevron24白、首页outline24黑、客服headphone24黑、排行crown23金。星级使用3红2灰星16，间隔4；三点复现设计装饰，当前只有一张主图，不制造另外两张。
资源位于已有assets/images/product，不修改pubspec；不生成随机图片，不引入依赖。

## 数据、职责与操作边界

复用现有 ProductDetail / ProductSku / ProductSpec / Money / AppNetworkImage / AppLoading / AppError / AppEmpty 和对应 AppColors。
新增 ProductDetailContent 聚合模型（商品+评价+会员价+销量+长图+排行），ProductDetailContentRepository 窄接口，本地 ProductDetailMockRepository，以及按id加载的 autoDispose FutureProvider。
现有通用商品Mock不修改；页面不使用全局商品仓库，确保不会调用真实API。页面只组装组件、处理导航和预览提示。
首页和购物车使用已存在GoRouter路由；客服、优惠券、加购、购买用明确的本地预览提示，不谎报成功，不生成订单；查看全部仅展示已有本地评价；图片点击查看真实素材。

## 修改范围与验收

修改现有 product_detail_page.dart；新增文件全部位于本feature，二进制图片沿用现有assets管理。无删除文件，无全局Theme、其他业务页面或导航修改。
检查：dart format；flutter analyze；页面Widget测试（窄屏、正常/空/错误、固定栏、安全区、返回）；Web启动、440/390/320与桌面截图、主滚动/底栏/素材检查。
差异：只有一张主图；42度标题与52%vol标签保持设计；无PingFang HK；导出行高150px等转换成1.5；客户端真实安全区代替设计系统占位。未提供的交互页不声称完成。

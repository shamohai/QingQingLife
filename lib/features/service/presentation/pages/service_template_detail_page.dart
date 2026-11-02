import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/config/app_config.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/app_loading.dart';
import '../providers/share_cart_template_detail_provider.dart';

/// 购酒享服务模板详情页面
///
/// 路由: /service/template/:id
/// 进入方式: 从服务中心「购酒享服务」列表页点击跳转（传递 templateId）
///
/// 数据来源：接口 POST /api/groupMall/shareCart/gettemplatedetail
///
/// 页面结构（蓝湖设计稿还原 + 接口数据）：
///   - AppBar：返回图标 + 动态标题（取自模板名称）
///   - Banner：headImg 网络图片，高度自适应，底部圆角
///   - 白色信息卡片：大标题「服务简介」+ 蓝色渐变指示条 + 接口 requirements 文案
///   - 详情富文本：HtmlWidget 渲染 descriptionHtml
///   - 客服信息区：二维码 + 电话
///   - 底部固定栏：渐变胶囊按钮「立即加购」→ 跳转 /service/cart?templateId=xxx
class ServiceTemplateDetailPage extends ConsumerStatefulWidget {
  final int templateId;

  /// 会员权益商城权益对应的用户权益 id。
  ///
  /// 从「我的权益」进入时由路由带入；普通模板详情入口为 null。
  final int? userServiceId;

  const ServiceTemplateDetailPage({super.key, required this.templateId, this.userServiceId});

  @override
  ConsumerState<ServiceTemplateDetailPage> createState() => _ServiceTemplateDetailPageState();
}

class _ServiceTemplateDetailPageState extends ConsumerState<ServiceTemplateDetailPage> {
  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(shareCartTemplateDetailProvider(widget.templateId));
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.servicePageBackground,
      appBar: _buildAppBar(context, detailAsync),
      body: detailAsync.when(
        loading: () => const Center(child: AppLoading()),
        error: (_, _) => Center(
          child: AppError(message: '加载失败，请稍后重试', onRetry: () => ref.invalidate(shareCartTemplateDetailProvider(widget.templateId))),
        ),
        data: (detail) => _buildBody(detail, bottomInset),
      ),
      bottomNavigationBar: detailAsync.maybeWhen(data: (detail) => _buildBottomBar(context, detail), orElse: () => null),
    );
  }

  /// AppBar：动态标题取自模板名称
  PreferredSizeWidget _buildAppBar(BuildContext context, AsyncValue<dynamic> asyncValue) {
    String title = '服务详情';
    /*final String? foundName = asyncValue.maybeWhen(
      data: (detail) {
        final name = (detail as dynamic).templateName as String?;
        return (name != null && name.isNotEmpty) ? name : null;
      },
      orElse: () => null,
    );
    if (foundName != null) {
      title = foundName.length > 12 ? '${foundName.substring(0, 12)}…' : foundName;
    }*/
    return AppBar(
      backgroundColor: AppColors.servicePageBackground,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black),
      ),
      centerTitle: false,
    );
  }

  /// 主体内容：Banner + 白色信息卡片 + 详情富文本 + 客服信息区
  Widget _buildBody(dynamic detail, double bottomInset) {
    final headImg = detail.headImg as String;
    final requirements = detail.requirements as String;
    final descriptionHtml = detail.descriptionHtml as String;
    final serviceQrImg = detail.serviceQrImg as String;
    final contactRemark = detail.contactRemark as String;
    final contacttPhone = detail.contacttPhone as String;

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // ── Section A: Banner（高度自适应，根据图片宽高比计算）──
        SliverToBoxAdapter(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bannerHeight = (constraints.maxWidth - 28) * (230 / 414);
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.md)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: AppNetworkImage(
                    url: headImg.isNotEmpty ? headImg : 'assets/images/service/service_goujiu.webp',
                    height: bannerHeight,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
        // ── Section B: 白色信息卡片 ──
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 0),
          sliver: SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.sm)),
              padding: const EdgeInsets.fromLTRB(19, 10, 19, AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 43,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          left: 0,
                          top: 25,
                          child: Container(
                            width: 94,
                            height: 7,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppRadius.round),
                              gradient: const LinearGradient(colors: [AppColors.serviceProjectBlue, Color(0x00F3F5F7)]),
                            ),
                          ),
                        ),
                        Text(
                          '服务简介',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (requirements.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        requirements,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black, height: 1.5),
                      ),
                    ),
                  // 详情富文本：HtmlWidget 渲染 descriptionHtml
                  if (descriptionHtml.isNotEmpty) ...[const SizedBox(height: 18), _buildHtmlWidget(descriptionHtml)],
                ],
              ),
            ),
          ),
        ),
        // ── Section C: 客服信息区 ──
        if (serviceQrImg.isNotEmpty || contacttPhone.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 0),
            sliver: SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.sm)),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    // 二维码图片
                    if (serviceQrImg.isNotEmpty) AppNetworkImage(url: serviceQrImg, width: 100, height: 100, fit: BoxFit.contain),
                    const SizedBox(width: AppSpacing.lg),
                    // 电话文案
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (contactRemark.isNotEmpty) Text(contactRemark, style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.4)),
                          if (contacttPhone.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              contacttPhone,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        // 底部留白，确保最后一项内容不被底部栏遮挡
        SliverToBoxAdapter(child: SizedBox(height: 88 + bottomInset)),
      ],
    );
  }

  /// HtmlWidget 渲染详情富文本 HTML，高度随内容自动适应
  Widget _buildHtmlWidget(String html) {
    return HtmlWidget(html, baseUrl: Uri.parse(AppConfig.baseUrl));
  }

  /// 底部固定操作栏：白色背景 + 向上阴影 + 渐变胶囊按钮
  Widget _buildBottomBar(BuildContext context, dynamic detail) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final btnWidth = screenWidth - 60;
    final headImg = detail.headImg as String;
    final cartId = detail.cartInfo?.cartId ?? 0;

    return SafeArea(
      top: false,
      bottom: true,
      child: Container(
        height: 80,
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, -2))],
        ),
        child: Center(
          child: GestureDetector(
            onTap: () {
              // 跳转到购物车页面，携带 templateId、headImg、cartId 参数
              final encodedHeadImg = Uri.encodeComponent(headImg);
              final uri = '/service/cart?templateId=${widget.templateId}&headImg=$encodedHeadImg&cartId=$cartId';
              context.push(uri);
            },
            child: Container(
              width: btnWidth,
              height: 51,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.round),
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [AppColors.serviceTabActive, AppColors.serviceCtaGradStart],
                ),
              ),
              child: const Center(
                child: Text(
                  '立即加购',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

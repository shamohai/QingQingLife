import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/config/app_config.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../domain/models/share_cart_template_detail_model.dart';
import '../providers/share_cart_template_detail_provider.dart';

/// 购酒享服务「付款提示 / 联系客服」页面
///
/// 路由: /customer-service?templateId=模板ID（可选）&title=页面标题
///
/// 蓝湖设计稿：服务中心-购酒享服务-确认订单（付款提示）
/// 结构（MCP Visual IR，440 基准 1:1）：
///   - NavRow：返回 24x24 + 动态标题 18px Medium（缺省"联系客服"）
///   - QrCodeCard：白卡 r10，二维码 210x210 + 说明 16px
///   - PhoneCard：白卡 r10，"客服电话"(16 黑) + 时间(14 灰)；号码(16 蓝) + 30px 蓝圆 call 钮
///   - RulesCard：白卡 r10，蓝色品牌标语 16 + "活动规则" 16 + 规则正文 14/1.5
/// 卡间距 10、左右边距 14；整页背景 #F3F5F7；卡片无阴影无描边。
///
/// 未传模板 ID 时保留其他客服入口原有的静态展示；购酒享服务结算流程使用真实模板数据。
class ServiceCustomerContactPage extends ConsumerWidget {
  /// 上一页点击的 id（透传，一期不做数据查询）
  final String? id;

  /// 页面标题，缺省"联系客服"（与蓝湖设计稿一致）
  final String? title;

  /// 购酒享服务模板 ID；存在时加载该模板的客服信息和详情 HTML。
  final int? templateId;

  const ServiceCustomerContactPage({super.key, this.id, this.title, this.templateId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (templateId == null) {
      return _buildMissingTemplatePage(context);
    }

    final detailAsync = ref.watch(shareCartTemplateDetailProvider(templateId!));
    return detailAsync.when(
      loading: () => Scaffold(
        backgroundColor: AppColors.servicePageBackground,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: _NavRow(title: title, onBack: () => context.pop()),
              ),
              const Expanded(child: Center(child: AppLoading())),
            ],
          ),
        ),
      ),
      error: (_, _) => Scaffold(
        backgroundColor: AppColors.servicePageBackground,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: _NavRow(title: title, onBack: () => context.pop()),
              ),
              Expanded(
                child: AppError(message: '加载失败，请稍后重试', onRetry: () => ref.invalidate(shareCartTemplateDetailProvider(templateId!))),
              ),
            ],
          ),
        ),
      ),
      data: (detail) => _buildPage(context, ServiceCustomerInfo.fromTemplate(detail)),
    );
  }

  Widget _buildMissingTemplatePage(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.servicePageBackground,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: _NavRow(title: title, onBack: () => context.pop()),
            ),
            const Expanded(child: AppEmpty(message: '缺少模板信息')),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(BuildContext context, ServiceCustomerInfo info) {
    final hasContent =
        info.qrCodeUrl.isNotEmpty ||
        info.phoneNumber.isNotEmpty ||
        info.phoneLabel.isNotEmpty ||
        info.phoneSubtitle.isNotEmpty ||
        info.descriptionHtml.isNotEmpty ||
        info.rules.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.servicePageBackground,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              sliver: SliverToBoxAdapter(
                child: _NavRow(title: title, onBack: () => context.pop()),
              ),
            ),
            if (!hasContent) const SliverFillRemaining(hasScrollBody: false, child: AppEmpty(message: '暂无客服信息')),
            if (info.qrCodeUrl.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                sliver: SliverToBoxAdapter(
                  child: Padding(padding: const EdgeInsets.only(top: 10), child: _QrCodeCard(info)),
                ),
              ),
            if (info.phoneNumber.isNotEmpty || info.phoneLabel.isNotEmpty || info.phoneSubtitle.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                sliver: SliverToBoxAdapter(
                  child: Padding(padding: const EdgeInsets.only(top: 10), child: _PhoneCard(info)),
                ),
              ),
            if (info.descriptionHtml.isNotEmpty || info.rules.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                sliver: SliverToBoxAdapter(
                  child: Padding(padding: const EdgeInsets.only(top: 10), child: _RulesCard(info)),
                ),
              ),
            // 底部收尾留白（设计 home indicator 区不实现，由系统安全区渲染）
            const SliverToBoxAdapter(child: SizedBox(height: 60)),
          ],
        ),
      ),
    );
  }
}

/// 顶部导航行：返回切图 24x24 + 标题 18px Medium
///
/// 设计 box_4：96x27，左 14，上 6 下 10；返回热区取 44pt 保证可点。
class _NavRow extends StatelessWidget {
  final String? title;
  final VoidCallback onBack;

  const _NavRow({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 6, 0, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: onBack,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 44,
              height: 44,
              // 返回箭头切图与 activity_detail_back.png 同源（MD5 一致），复用现有资源
              child: Image.asset('assets/images/service/activity_detail_back.png', width: 24, height: 24),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              title?.isNotEmpty == true ? title! : '联系客服',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black, height: 1.33),
            ),
          ),
        ],
      ),
    );
  }
}

/// 在线客服二维码卡片：白底 r10，二维码 210x210 居中 + 说明文字
///
/// 设计 box_5：414x313，padding 上29 下28 左右10；内容上下两端对齐。
class _QrCodeCard extends StatelessWidget {
  final ServiceCustomerInfo info;
  const _QrCodeCard(this.info);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.md)),
      padding: const EdgeInsets.only(left: 10, right: 10, top: 29, bottom: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 二维码：一期用切图占位，URL 非网络地址时同样走 AppNetworkImage 本地路径分支
          AppNetworkImage(url: info.qrCodeUrl, width: 210, height: 210, fit: BoxFit.contain),
          const SizedBox(height: 12),
          Text(
            info.qrCaption,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black, height: 1.4),
          ),
        ],
      ),
    );
  }
}

/// 客服电话卡片：白底 r10，标题行两端对齐 + 电话行（蓝色号码 + 30px 蓝圆 call 钮）
///
/// 设计 box_6：414x88，padding 上8 下14 左右10，行距 14。
class _PhoneCard extends StatelessWidget {
  final ServiceCustomerInfo info;
  const _PhoneCard(this.info);

  Future<void> _callPhone() async {
    final uri = Uri(scheme: 'tel', path: info.phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.md)),
      padding: const EdgeInsets.only(left: 10, right: 10, top: 8, bottom: 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  info.phoneLabel.isEmpty ? '客服电话' : info.phoneLabel,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black, height: 1.4),
                ),
              ),
              if (info.phoneSubtitle.isNotEmpty)
                Text(
                  info.phoneSubtitle,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF8E8E8F), height: 1.4),
                ),
            ],
          ),
          if (info.phoneNumber.isNotEmpty) ...[
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _callPhone,
                  behavior: HitTestBehavior.opaque,
                  child: Text(
                    info.phoneNumber,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.serviceTabActive, height: 1.4),
                  ),
                ),
                GestureDetector(
                  onTap: _callPhone,
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    width: 30,
                    height: 30,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(color: AppColors.serviceProjectBlue, shape: BoxShape.circle),
                      child: const Icon(Icons.call, size: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// 活动规则卡片：白底 r10，蓝色品牌标语 + "活动规则" 标题 + 规则正文段落
///
/// 设计 text-wrapper_9：414x356，padding 上8 下24 左右10；标题上边距 8，正文上边距 10。
class _RulesCard extends StatelessWidget {
  final ServiceCustomerInfo info;
  const _RulesCard(this.info);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.md)),
      padding: const EdgeInsets.only(left: 10, right: 10, top: 8, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (info.brandLine.isNotEmpty) ...[
            Text(
              info.brandLine,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.serviceTabActive, height: 1.4),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            '活动规则',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black, height: 1.4),
          ),
          const SizedBox(height: 10),
          if (info.descriptionHtml.isNotEmpty)
            HtmlWidget(info.descriptionHtml, baseUrl: Uri.parse(AppConfig.baseUrl))
          else
            for (final rule in info.rules)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  rule,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black, height: 1.5),
                ),
              ),
        ],
      ),
    );
  }
}

class ServiceCustomerInfo {
  final String qrCodeUrl;
  final String qrCaption;
  final String phoneLabel;
  final String phoneSubtitle;
  final String phoneNumber;
  final String brandLine;
  final List<String> rules;
  final String descriptionHtml;

  const ServiceCustomerInfo({
    required this.qrCodeUrl,
    required this.qrCaption,
    required this.phoneLabel,
    required this.phoneSubtitle,
    required this.phoneNumber,
    required this.brandLine,
    required this.rules,
    this.descriptionHtml = '',
  });

  factory ServiceCustomerInfo.fromTemplate(ShareCartTemplateDetail detail) {
    return ServiceCustomerInfo(
      qrCodeUrl: detail.serviceQrImg,
      qrCaption: '长按识别二维码，联系在线客服',
      phoneLabel: detail.contactRemark,
      phoneSubtitle: '',
      phoneNumber: detail.contacttPhone,
      brandLine: '',
      rules: const [],
      descriptionHtml: detail.descriptionHtml,
    );
  }
}

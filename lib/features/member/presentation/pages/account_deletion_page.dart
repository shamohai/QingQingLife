import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 注销协议页（/member/account-deletion）
///
/// 入口：账号安全页底部「注销账号」按钮。
/// 结构（设计稿）：白色页面 + 深色返回栏「注销协议」→ 可滚动协议正文
/// （标题 / 适用说明 / 特别重要提示 / 第一条 / 第二条）→ 勾选确认行
/// → 底部固定操作栏（放弃注销(渐变实底) / 我已知晓，继续注销(描边)）。
/// 「继续注销」需先勾选同意协议；后续注销流程依赖后端注销/核验接口（暂未提供），
/// 点击暂为占位反馈（TODO）。
/// 协议文案当前内置于页面（TODO(API): 若后续由后端下发协议文本，改为接口获取）。
class AccountDeletionPage extends ConsumerStatefulWidget {
  const AccountDeletionPage({super.key});

  @override
  ConsumerState<AccountDeletionPage> createState() => _AccountDeletionPageState();
}

class _AccountDeletionPageState extends ConsumerState<AccountDeletionPage> {
  /// 底部操作栏内容高度（上 11 + 按钮 44 + 间距 8 + 按钮 44 + 下 23，不含系统安全区）
  static const double _barHeight = 130;

  /// 是否已勾选同意注销协议（未勾选时「继续注销」不可点）
  bool _agreed = false;

  // ── 协议文案（对齐设计稿）───────────────────────────────────────────
  static const String _agreementTitle = '《青轻生活馆 APP 账号注销协议》';
  static const List<String> _introParagraphs = [
    '适用：APP 内注销弹窗 / 注销页面勿切，合规装配《个人信息保护法》《网络安全法》，可直接嵌入 APP 页面；【用户勾选同意】后进入注销流程',
    '特别重要提示',
    '本账号注销操作不可逆，一经完成无法恢复。请您仔细阅读本注销条款，确认完全理解并同意后，再提交注销申请。',
  ];
  static const List<String> _sections = [
    '第一条 协议主体',
    '本协议由青轻生活馆 APP 运营方（以下简称"平台"）与申请账号注销的用户（以下简称"您"）订立。您发起账号注销申请前，勾选同意本协议，即代表您愿意接受本协议全部约定。',
    '第二条 注销前前置条件（须全部满足方可提交申请）',
    '申请注销前，请确认账号同时满足以下全部条件：',
    '1. 账号状态正常，无冻结、封禁、风控限制，无被盗风险；',
    '2. 账号无未完成订单、售后、退款、投诉纠纷，不存在待履约服务；',
    '3. 账户内余额、储值资金已全部结清，无欠款、待结算款项；',
    '4. 已自费使用 / 放弃账户内全部虚拟权益：积分、优惠券、会员资格、礼品卡、商品兑换资格等；',
    '5. 已解绑第三方授权登录、绑定的银行卡、微信、支付宝、手机号之外的关键联账号；',
  ];
  static const String _confirmText = '我已仔细阅读、充分理解以上全部注销条款，清楚知晓注销不可逆、数据无法找回、虚拟权益自动放弃，自愿申请注销青轻生活馆账号。';

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // ── 协议正文（可滚动）────────────────────────────────────
            SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(bottom: _barHeight + MediaQuery.paddingOf(context).bottom + 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNavBar(context),
                    const SizedBox(height: 14),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        _agreementTitle,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1D1C), height: 1.4),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // 适用说明 + 特别重要提示
                    for (final paragraph in _introParagraphs)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          paragraph,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: _isSectionTitle(paragraph) ? FontWeight.w600 : FontWeight.w400,
                            color: const Color(0xFF1A1D1C),
                            height: 1.6,
                          ),
                        ),
                      ),
                    const SizedBox(height: 6),
                    // 第一条 / 第二条协议正文
                    for (final paragraph in _sections) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          paragraph,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: _isSectionTitle(paragraph) ? FontWeight.w600 : FontWeight.w400,
                            color: const Color(0xFF1A1D1C),
                            height: 1.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    const SizedBox(height: 10),
                    // ── 勾选确认行 ─────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => setState(() => _agreed = !_agreed),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Icon(
                                _agreed ? Icons.check_circle : Icons.radio_button_unchecked,
                                size: 20,
                                color: _agreed ? const Color(0xFF22418A) : const Color(0xFFC4C9D4),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                _confirmText,
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Color(0xFF1A1D1C), height: 1.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── 底部固定操作栏 ─────────────────────────────────────────
            Positioned(left: 0, right: 0, bottom: 0, child: _buildBottomBar(context)),
          ],
        ),
      ),
    );
  }

  /// 判断段落是否为条款小标题（加粗展示）
  bool _isSectionTitle(String text) {
    return text == '特别重要提示' || text.startsWith('第一条') || text.startsWith('第二条');
  }

  /// 返回栏（黑字标题，页面为浅色底，与 about_us_page 写法一致）
  Widget _buildNavBar(BuildContext context) {
    return SizedBox(
      height: 30,
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => context.pop(),
            child: const Padding(
              padding: EdgeInsets.only(left: 9),
              child: Icon(Icons.arrow_back_ios_new, size: 20, color: Color(0xFF000000)),
            ),
          ),
          const Text(
            '注销协议',
            style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w400, color: Color(0xFF000000), height: 1.2),
          ),
        ],
      ),
    );
  }

  /// 底部操作栏：放弃注销（渐变实底） / 我已知晓，继续注销（描边）
  Widget _buildBottomBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Color(0x1F000000), blurRadius: 6, offset: Offset(0, -1))],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(13, 11, 13, 23),
          child: Column(mainAxisSize: MainAxisSize.min, children: [_buildCancelButton(context), const SizedBox(height: 8), _buildContinueButton()]),
        ),
      ),
    );
  }

  /// 「放弃注销」→ 返回上一页
  Widget _buildCancelButton(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.pop(),
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Color(0xFF22418A), Color(0xFF2F57BA)]),
        ),
        child: const Text(
          '放弃注销',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white, height: 1.2),
        ),
      ),
    );
  }

  /// 「我已知晓，继续注销」→ 需先勾选协议；注销流程后端接口暂未提供（TODO）
  Widget _buildContinueButton() {
    final enabled = _agreed;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled
          ? () {
              // TODO(交互): 后续注销流程依赖后端注销/核验接口，后端暂未提供，待接入后补充。
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('注销流程功能开发中，敬请期待'), duration: Duration(seconds: 1)));
            }
          : null,
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: enabled ? const Color(0xFFA8B9DD) : const Color(0xFFE3E7EF)),
          color: enabled ? Colors.transparent : const Color(0xFFF5F6F8),
        ),
        child: Text(
          '我已知晓，继续注销',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: enabled ? const Color(0xFF2B4990) : const Color(0xFFB8BEC9), height: 1.2),
        ),
      ),
    );
  }
}

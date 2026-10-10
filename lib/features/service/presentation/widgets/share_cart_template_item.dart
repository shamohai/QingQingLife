import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../domain/models/share_cart_template_model.dart';

/// 购酒享服务模板列表单项卡片
///
/// 布局与 [ServiceListItem] 相同（左图 + 文字 + 右侧按钮），
/// 但直接使用 [ShareCartTemplate] 字段，图片走网络 URL。
class ShareCartTemplateItem extends StatelessWidget {
  final ShareCartTemplate template;
  final VoidCallback onTap;

  const ShareCartTemplateItem({super.key, required this.template, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 左侧网络图片 100x100
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: _NetworkImage(template.headImg, size: 100),
        ),
        const SizedBox(width: AppSpacing.sm),
        // 中间文字
        Expanded(
          child: SizedBox(
            height: 112,
            child: Padding(
              padding: EdgeInsets.only(top: AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    template.templateName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black, height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    template.requirements.isNotEmpty ? template.requirements : '顶顶顶顶',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF3495E0), height: 1.4),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      height: 31,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minWidth: 78),
                        child: OutlinedButton(
                          onPressed: onTap,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.serviceButtonRed),
                            backgroundColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.round)),
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            '立即购买',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.serviceButtonRed),
                            softWrap: false,
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NetworkImage extends StatelessWidget {
  final String url;
  final double size;

  const _NetworkImage(this.url, {required this.size});

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return _placeholder;
    return Image.network(
      url,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (e, s, t) => _placeholder,
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return Container(
          width: size,
          height: size,
          color: AppColors.surfaceVariant,
          child: const Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
        );
      },
    );
  }

  Widget get _placeholder => Container(
        width: size,
        height: size,
        color: AppColors.surfaceVariant,
        child: const Icon(Icons.image_outlined, size: 36, color: AppColors.outline),
      );
}

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
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
    return SizedBox(
      height: 100,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(AppRadius.sm), child: _NetworkImage(template.headImg, size: 100)),
          const SizedBox(width: 14),
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 92, top: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        template.templateName,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black, height: 1.5),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Text(
                        template.requirements,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.serviceProjectBlue, height: 1.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: SizedBox(
                    width: 78,
                    height: 31,
                    child: OutlinedButton(
                      onPressed: onTap,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.serviceButtonRed),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.round)),
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        '立即购买',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.serviceButtonRed),
                        softWrap: false,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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

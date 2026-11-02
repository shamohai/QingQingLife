import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/network/providers.dart';

/// 管家服务小程序入口配置。
/// 接口：POST /api/sys/app/getcustomermanagerinfo
class ButlerMiniProgramInfo {
  final String workwxmppath;

  const ButlerMiniProgramInfo({required this.workwxmppath});

  factory ButlerMiniProgramInfo.fromJson(Map<String, dynamic> json) {
    final info = json['info'];
    final infoJson = info is Map ? Map<String, dynamic>.from(info) : json;
    return ButlerMiniProgramInfo(workwxmppath: infoJson['workwxmppath'] as String? ?? '');
  }
}

final butlerMiniProgramInfoProvider = FutureProvider<ButlerMiniProgramInfo?>((ref) async {
  final response = await ref
      .read(apiClientProvider)
      .post<ButlerMiniProgramInfo>(
        '/api/sys/app/getcustomermanagerinfo',
        data: const <String, dynamic>{},
        fromJson: (dynamic json) => ButlerMiniProgramInfo.fromJson(Map<String, dynamic>.from(json as Map)),
      );
  if (!response.success) return null;
  return response.data;
});

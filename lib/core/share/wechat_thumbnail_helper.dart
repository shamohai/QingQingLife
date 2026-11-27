import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';

/// 微信分享卡片缩略图处理工具
///
/// 微信 SDK 分享网页卡片时，要求缩略图数据 [thumbData] 必须是二进制字节，
/// 且大小不能超过 32KB（32768 字节）。超过该大小将直接导致微信分享校验失败。
class WeChatThumbnailHelper {
  /// 设为 30KB，严格限制在微信 32KB 的安全范围内留出裕量。
  static const int maxThumbBytes = 30 * 1024;

  /// 逐步缩小的目标分辨率梯级。微信卡片右侧缩略图在屏幕上的显示尺寸极小，
  /// 150/120/90 物理像素在高清屏下均清晰可见。
  static const List<int> defaultTargetSizes = [150, 120, 90, 60];

  final Dio _dio;

  WeChatThumbnailHelper({Dio? dio}) : _dio = dio ?? Dio(BaseOptions(connectTimeout: const Duration(seconds: 60), receiveTimeout: const Duration(seconds: 60)));

  /// 从网络 URL 获取图片并自适应缩放到 ≤ 30KB。
  ///
  /// 若下载失败、超时、格式不支持或压缩后仍超标，返回 null，保证分享主流程不被阻断。
  Future<Uint8List?> fetchAndCompressThumbnail(String? imageUrl) async {
    final url = imageUrl?.trim();
    if (url == null || url.isEmpty) return null;
    if (!url.startsWith('http://') && !url.startsWith('https://')) return null;

    try {
      final response = await _dio.get<List<int>>(url, options: Options(responseType: ResponseType.bytes));

      final rawList = response.data;
      if (rawList == null || rawList.isEmpty) return null;

      final rawBytes = rawList is Uint8List ? rawList : Uint8List.fromList(rawList);
      return await compressThumbnail(rawBytes);
    } catch (_) {
      return null;
    }
  }

  /// 将原始图片字节缩放压缩至 ≤ 30KB。
  Future<Uint8List?> compressThumbnail(Uint8List rawBytes, {List<int> targetSizes = defaultTargetSizes}) async {
    if (rawBytes.isEmpty) return null;

    for (final size in targetSizes) {
      final resized = await _resizeImage(rawBytes, size);
      if (resized != null && resized.lengthInBytes <= maxThumbBytes) {
        return resized;
      }
    }
    return null;
  }

  static Future<Uint8List?> _resizeImage(Uint8List bytes, int targetSize) async {
    try {
      final codec = await ui.instantiateImageCodec(bytes, targetWidth: targetSize, targetHeight: targetSize);
      final frame = await codec.getNextFrame();
      final byteData = await frame.image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }
}

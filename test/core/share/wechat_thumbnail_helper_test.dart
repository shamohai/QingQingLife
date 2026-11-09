import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:qingqinglife/core/share/wechat_thumbnail_helper.dart';

Future<Uint8List> _createTestImageBytes({int width = 300, int height = 300}) async {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  final paint = ui.Paint()..color = const ui.Color(0xFF213775);
  canvas.drawRect(ui.Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()), paint);
  final picture = recorder.endRecording();
  final image = await picture.toImage(width, height);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}

void main() {
  group('WeChatThumbnailHelper', () {
    test('returns null for empty or non-http URLs', () async {
      final helper = WeChatThumbnailHelper();

      expect(await helper.fetchAndCompressThumbnail(null), isNull);
      expect(await helper.fetchAndCompressThumbnail(''), isNull);
      expect(await helper.fetchAndCompressThumbnail('   '), isNull);
      expect(await helper.fetchAndCompressThumbnail('ftp://example.com/a.jpg'), isNull);
    });

    test('compressThumbnail scales down image and keeps size <= 30KB', () async {
      final helper = WeChatThumbnailHelper();
      final testBytes = await _createTestImageBytes(width: 400, height: 400);

      final result = await helper.compressThumbnail(testBytes);

      expect(result, isNotNull);
      expect(result!.lengthInBytes, lessThanOrEqualTo(WeChatThumbnailHelper.maxThumbBytes));
    });
  });
}

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

/// 设备定位服务（公共能力，供各 feature 复用）。
class DeviceLocationService {
  /// 获取设备定位；无定位服务或未授权时返回 null，不使用假坐标。
  Future<Position?> getDevicePosition() async {
    if (kIsWeb) {
      // Web 端暂用青海省西宁市坐标（lng, lat）代替定位，便于 Chrome 联调。
      return Position(
        longitude: 101.7782,
        latitude: 36.6171,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );
    }
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    try {
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) return lastKnown;
    } catch (e) {
      debugPrint('[Location] 获取缓存位置失败或超时: $e');
    }

    try {
      final locationSettings = defaultTargetPlatform == TargetPlatform.android
          ? AndroidSettings(accuracy: LocationAccuracy.low, forceLocationManager: true, timeLimit: const Duration(seconds: 5))
          : const LocationSettings(accuracy: LocationAccuracy.low, timeLimit: Duration(seconds: 5));
      return await Geolocator.getCurrentPosition(locationSettings: locationSettings);
    } catch (e) {
      debugPrint('[Location] 获取当前位置失败或超时: $e');
      return null;
    }
  }
}

final deviceLocationServiceProvider = Provider<DeviceLocationService>((ref) {
  return DeviceLocationService();
});

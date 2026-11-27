import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

/// 定位失败原因，由页面或门禁决定引导文案与操作，服务层不弹窗、不跳转。
enum LocationFailure {
  /// 系统定位服务（GPS）未开启，可拉起系统定位设置页。
  serviceDisabled,

  /// 定位权限未授予（尚未申请，或本次被拒绝），可申请或拉起应用设置页。
  permissionDenied,

  /// 定位权限被永久拒绝，需在应用设置页开启。
  permissionDeniedForever,

  /// 超时或其他异常，没有可引导的设置项。
  unavailable,
}

extension LocationFailureX on LocationFailure {
  /// 是否存在可以直接跳转的系统设置页。
  bool get canOpenSettings => this != LocationFailure.unavailable;
}

/// 定位结果：成功携带位置，失败携带原因。
sealed class LocationResult {
  const LocationResult();
}

final class LocationSuccess extends LocationResult {
  final Position position;
  const LocationSuccess(this.position);
}

final class LocationError extends LocationResult {
  final LocationFailure failure;
  const LocationError(this.failure);
}

/// 设备定位服务（公共能力，供各 feature 复用）。不使用假坐标。
class DeviceLocationService {
  /// 缓存位置有效期，超过则视为过期并重新定位。
  static const Duration cacheMaxAge = Duration(minutes: 30);

  /// 进程内缓存：最近一次定位成功的结果，供门禁与 WebView 复用。
  static Position? _memoryPosition;

  /// 获取定位：有效缓存优先；无缓存或过期时检查定位服务与权限后再定位。
  Future<LocationResult> getPosition() async {
    // Web 开发联调：仅 debug 模式使用青海西宁坐标（lng, lat），release 构建不生效，不影响真机与线上。
    if (kIsWeb && kDebugMode) {
      return LocationSuccess(_webDebugPosition());
    }

    final cached = await _validCachedPosition();
    if (cached != null) return LocationSuccess(cached);

    final failure = await checkReadiness();
    if (failure != null) return LocationError(failure);

    try {
      final position = await Geolocator.getCurrentPosition(locationSettings: _locationSettings());
      _memoryPosition = position;
      return LocationSuccess(position);
    } catch (e) {
      debugPrint('[Location] 获取当前位置失败或超时: $e');
      return const LocationError(LocationFailure.unavailable);
    }
  }

  /// 是否存在未过期的缓存位置（不检查定位开关与权限）。
  Future<bool> hasValidCache() async => await _validCachedPosition() != null;

  /// 检查定位服务与权限状态，不弹系统框。返回 null 表示已就绪。
  Future<LocationFailure?> checkReadiness() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return LocationFailure.serviceDisabled;
      }
      final permission = await Geolocator.checkPermission();
      return switch (permission) {
        LocationPermission.deniedForever => LocationFailure.permissionDeniedForever,
        LocationPermission.denied => LocationFailure.permissionDenied,
        _ => null,
      };
    } catch (e) {
      debugPrint('[Location] 检查定位状态失败: $e');
      return LocationFailure.unavailable;
    }
  }

  /// 申请定位权限（会弹出系统权限框；iOS 被拒绝后系统不再弹框，需引导去设置）。
  Future<void> requestPermission() async {
    try {
      await Geolocator.requestPermission();
    } catch (e) {
      debugPrint('[Location] 申请定位权限失败: $e');
    }
  }

  /// 按失败原因跳转到对应的系统设置页。
  Future<void> openSettingsFor(LocationFailure failure) async {
    try {
      switch (failure) {
        case LocationFailure.serviceDisabled:
          await Geolocator.openLocationSettings();
        case LocationFailure.permissionDenied:
        case LocationFailure.permissionDeniedForever:
          await Geolocator.openAppSettings();
        case LocationFailure.unavailable:
          break;
      }
    } catch (e) {
      debugPrint('[Location] 打开系统设置失败: $e');
    }
  }

  LocationSettings _locationSettings() {
    return defaultTargetPlatform == TargetPlatform.android
        ? AndroidSettings(accuracy: LocationAccuracy.low, forceLocationManager: true, timeLimit: const Duration(seconds: 5))
        : const LocationSettings(accuracy: LocationAccuracy.low, timeLimit: Duration(seconds: 5));
  }

  /// 有效缓存：优先进程内缓存，其次系统缓存位置；均需在 [cacheMaxAge] 内。
  Future<Position?> _validCachedPosition() async {
    final memory = _memoryPosition;
    if (memory != null && _isFresh(memory)) return memory;
    try {
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null && _isFresh(lastKnown)) return lastKnown;
    } catch (e) {
      debugPrint('[Location] 获取缓存位置失败: $e');
    }
    return null;
  }

  static bool _isFresh(Position position) => DateTime.now().difference(position.timestamp) <= cacheMaxAge;

  /// 仅用于 Web debug 联调的固定坐标，不得在真机或 release 中使用。
  static Position _webDebugPosition() {
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
}

final deviceLocationServiceProvider = Provider<DeviceLocationService>((ref) {
  return DeviceLocationService();
});

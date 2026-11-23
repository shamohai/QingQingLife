import 'package:flutter/services.dart';

/// Web / Non-IO 平台的存根实现，杜绝引入 [dart:io] 和 [path_provider]
class StartupVideoUpdateService {
  StartupVideoUpdateService();

  Future<void> syncAppBuildOnLaunch() async {}

  Future<dynamic> getValidLocalVideoFile() async => null;

  Future<bool> checkAndDownloadUpdate() async => false;
}

/// Web 端不做热更新镜像，直接使用内置资源
class HotAssetBundle extends AssetBundle {
  @override
  Future<ByteData> load(String key) => rootBundle.load(key);
}

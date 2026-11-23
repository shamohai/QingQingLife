/// Web / Non-IO 平台的存根实现，杜绝引入 [dart:io] 和 [path_provider]
class StartupVideoUpdateService {
  StartupVideoUpdateService();

  Future<void> syncAppBuildOnLaunch() async {}

  Future<dynamic> getValidLocalVideoFile() async => null;

  Future<bool> checkAndDownloadUpdate() async => false;
}

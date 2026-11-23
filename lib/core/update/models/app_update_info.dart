/// App 原生版本更新信息（来自 CheckUpdate 接口的 `appversion` 节点）
///
/// 接口文档（LCS.Api.Model.Sys.App.CheckUpdateMsgResp）：
/// - `appversion` 不为空表示存在新版本，客户端需要下载新版本
/// - `isforceupdate` 仅针对 App 版本升级，是否强制升级
class AppUpdateInfo {
  const AppUpdateInfo({
    required this.displayVersion,
    required this.buildNumber,
    required this.fileUrl,
    required this.releaseNotes,
    required this.isForceUpdate,
  });

  /// 显示版本号，如 `1.2.3.build123`
  final String displayVersion;

  /// 版本号（build number）
  final int buildNumber;

  /// 安装包下载地址
  final String fileUrl;

  /// 版本描述
  final String releaseNotes;

  /// 是否强制升级
  final bool isForceUpdate;

  /// 从 CheckUpdateMsgResp 中的 `appversion` 与 `isforceupdate` 构建；`appversion` 为空时返回 null
  static AppUpdateInfo? tryParse(Map<String, dynamic> response) {
    final appversion = response['appversion'];
    if (appversion is! Map) return null;

    final fileUrl = appversion['fileurl'] as String? ?? '';
    if (fileUrl.isEmpty) return null;

    return AppUpdateInfo(
      displayVersion: appversion['displayversion'] as String? ?? '',
      buildNumber: (appversion['buildnumber'] as num?)?.toInt() ?? 0,
      fileUrl: fileUrl,
      releaseNotes: appversion['releasenotes'] as String? ?? '',
      isForceUpdate: response['isforceupdate'] == true,
    );
  }
}

import 'package:umeng_common_sdk/umeng_common_sdk.dart';

import 'app/bootstrap.dart';

/// 友盟 SDK 初始化函数
/// 必须在用户同意隐私政策后调用
void initUmengSdk() {
  UmengCommonSdk.initCommon(
    '6af189d16545637cd6451016', // Android 平台 AppKey
    '6af189d16545637cd6451016', // iOS 平台 AppKey
    'Umeng', // 渠道标识
  );
  UmengCommonSdk.setPageCollectionModeAuto();
}

/// 应用入口函数
///
/// 采用异步初始化方式，确保在应用渲染前完成必要的环境准备工作。
/// 这里调用 bootstrap() 进行核心组件和服务的初始化。
void main() async {
  await bootstrap();
}

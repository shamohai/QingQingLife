import 'package:fluwx/fluwx.dart' as fluwx;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'share_service.dart';

final fluwx.Fluwx _wechatClient = fluwx.Fluwx();

final shareServiceProvider = Provider<ShareService>((ref) {
  return FluwxShareService(wechat: _wechatClient);
});

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/repository_providers.dart';
import '../../data/models/member_sign_in_models.dart';

/// 会员签到页状态
class MemberSignInState {
  /// 是否加载中
  final bool loading;

  /// 错误信息（非 null 表示加载失败）
  final String? errorMessage;

  /// 签到页总览数据
  final MemberSignInOverview? overview;

  /// 是否正在签到（防止重复点击）
  final bool signing;

  const MemberSignInState({this.loading = false, this.errorMessage, this.overview, this.signing = false});

  bool get hasError => errorMessage != null;
}

final memberSignInProvider = NotifierProvider<MemberSignInNotifier, MemberSignInState>(() => MemberSignInNotifier());

/// 会员签到页控制器
///
/// 数据链路：Page → [memberSignInProvider] → MemberSignInRepository → MemberDataSource（签到接口暂未接入，返回失败态）
class MemberSignInNotifier extends Notifier<MemberSignInState> {
  @override
  MemberSignInState build() => const MemberSignInState();

  /// 加载签到页数据
  Future<void> load() async {
    if (state.loading) return;

    state = _copy(loading: true, clearError: true);
    try {
      final resp = await ref.read(memberSignInRepositoryProvider).getSignInOverview();
      if (resp.success && resp.data != null) {
        state = _copy(loading: false, overview: resp.data);
      } else {
        state = _copy(loading: false, errorMessage: '签到信息加载失败，请稍后重试');
      }
    } catch (e) {
      debugPrint('[MemberSignIn] load error: $e');
      state = _copy(loading: false, errorMessage: '签到信息加载失败，请稍后重试');
    }
  }

  /// 执行签到；返回 null 表示请求异常（由页面提示失败）
  Future<MemberSignInResult?> signIn() async {
    if (state.signing) return null;
    state = _copy(signing: true);
    try {
      final resp = await ref.read(memberSignInRepositoryProvider).signIn();
      state = _copy(signing: false);
      return resp.data;
    } catch (e) {
      debugPrint('[MemberSignIn] signIn error: $e');
      state = _copy(signing: false);
      return null;
    }
  }

  MemberSignInState _copy({bool? loading, String? errorMessage, bool clearError = false, MemberSignInOverview? overview, bool? signing}) {
    return MemberSignInState(
      loading: loading ?? state.loading,
      errorMessage: clearError ? null : (errorMessage ?? state.errorMessage),
      overview: overview ?? state.overview,
      signing: signing ?? state.signing,
    );
  }
}

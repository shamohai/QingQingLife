import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qingqinglife/core/network/api_response.dart';
import 'package:qingqinglife/core/providers/repository_providers.dart';
import 'package:qingqinglife/features/member/data/models/cash_coupon_share_model.dart';
import 'package:qingqinglife/features/member/domain/repositories/member_repository.dart';
import 'package:qingqinglife/features/member/presentation/pages/cash_coupon_share_receive_page.dart';
import 'package:qingqinglife/features/member/presentation/providers/cash_coupon_share_provider.dart';

class _RecordingMemberRepository implements MemberRepository {
  final List<bool> receiveFlags = [];
  final bool denyClaim;

  _RecordingMemberRepository({this.denyClaim = false});

  @override
  Future<ApiResponse<ReceiveCashCouponFromShareResult>> receiveCashCouponFromShare({required String shareCode, required bool doReceive}) async {
    receiveFlags.add(doReceive);
    return ApiResponse.success(
      ReceiveCashCouponFromShareResult(
        canReceive: !(doReceive && denyClaim),
        reason: doReceive && denyClaim ? '您已领取过了' : '',
        configInfo: CashCouponShareConfigInfo(rebate: Decimal.parse('0'), money: Decimal.parse('0')),
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('previews on load and only receives after an explicit claim', () async {
    final repository = _RecordingMemberRepository();
    final container = ProviderContainer(overrides: [memberRepositoryProvider.overrideWithValue(repository)]);
    addTearDown(container.dispose);

    final provider = cashCouponShareReceiveProvider('share-code');
    final subscription = container.listen(provider, (_, _) {});
    addTearDown(subscription.close);
    final notifier = container.read(provider.notifier);

    await notifier.load();
    expect(repository.receiveFlags, [false]);
    expect(container.read(provider).received, isFalse);

    expect(await notifier.receive(), isTrue);
    expect(repository.receiveFlags, [false, true]);
    expect(container.read(provider).received, isTrue);
  });

  testWidgets('does not render the denied claim reason twice', (tester) async {
    final repository = _RecordingMemberRepository(denyClaim: true);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [memberRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: CashCouponShareReceivePage(shareCode: 'share-code')),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('立即领取'));
    await tester.pumpAndSettle();

    expect(repository.receiveFlags, [false, true]);
    expect(find.text('您已领取过了'), findsOneWidget);
    expect(find.text('领取失败，请稍后重试'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

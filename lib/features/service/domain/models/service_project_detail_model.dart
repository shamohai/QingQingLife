import 'service_card_data.dart';

/// 预约项目详情数据模型（本地 mock，待 API 对接后替换）
class ServiceProjectDetail {
  final String id;
  /// 项目名称（从 ServiceCardData.title 查找，未找到时回退 '预约项目'）
  final String title;
  final String heroAsset;
  final String description;
  final Function onBook;

  const ServiceProjectDetail({
    required this.id,
    required this.title,
    required this.heroAsset,
    required this.description,
    required this.onBook,
  });

  /// 一期静态 mock 数据，对应蓝湖设计稿中的山野野营活动
  factory ServiceProjectDetail.mock(String projectId) => ServiceProjectDetail(
        id: projectId,
        title: _lookupMock(projectId)?.title ?? '预约项目',
        heroAsset: _lookupMock(projectId)?.heroAsset ?? 'assets/images/service/service_project_hero.png',
        description: _lookupMock(projectId)?.description ?? '',
        onBook: () {},
      );

  /// 从静态 mock 数据查找项目名称，找不到时回退为 '预约项目'
  static ServiceCardData? _lookupMock(String projectId) {
    for (final list in ServiceCardData.staticListByTab.values) {
      for (final card in list) {
        if (card.id == projectId) return card;
      }
    }
    return null;
  }
}

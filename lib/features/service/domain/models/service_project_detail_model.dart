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
        title: _lookupTitle(projectId),
        heroAsset: 'assets/images/service/service_project_hero.png',
        description: '远离城市喧嚣，奔赴山野自然！本次野营活动，邀大家暂别日常忙碌，沉浸式感受户外山野风光，体验轻松治愈的露营时光。'
            '活动将安排营地搭建、山野漫步、趣味互动游戏、星空夜谈等丰富内容。白天可漫步林间，呼吸清新空气，和伙伴结伴休闲打卡；'
            '傍晚围坐一起，分享美食，畅谈趣事；入夜仰望漫天星空，感受独属于野外的浪漫与宁静。'
            '活动全程做好基础安全保障，配备基础应急物资。大家可结伴体验户外野营乐趣，学习简单露营常识，放松身心，结识志同道合的朋友。'
            '温馨提示：户外活动存在一定不确定性，请报名参与者遵守现场工作人员安排，爱护自然环境，做到无痕露营；'
            '根据天气自备保暖衣物、个人生活用品，注意蚊虫防护。根据天气自备保暖衣物、个人生活用品，注意蚊虫防护。根据天气自备保暖衣物、个人生活用品，注意蚊虫防护。根据天气自备保暖衣物、个人生活用品，注意蚊虫防护。根据天气自备保暖衣物、个人生活用品，注意蚊虫防护。根据天气自备保暖衣物、个人生活用品，注意蚊虫防护。根据天气自备保暖衣物、个人生活用品，注意蚊虫防护。根据天气自备保暖衣物、个人生活用品，注意蚊虫防护。根据天气自备保暖衣物、个人生活用品，注意蚊虫防护。根据天气自备保暖衣物、个人生活用品，注意蚊虫防护。根据天气自备保暖衣物、个人生活用品，注意蚊虫防护。根据天气自备保暖衣物、个人生活用品，注意蚊虫防护。根据天气自备保暖衣物、个人生活用品，注意蚊虫防护。根据天气自备保暖衣物、个人生活用品，注意蚊虫防护。根据天气自备保暖衣物、个人生活用品，注意蚊虫防护。根据天气自备保暖衣物、个人生活用品，注意蚊虫防护。根据天气自备保暖衣物、个人生活用品，注意蚊虫防护。根据天气自备保暖衣物、个人生活用品，注意蚊虫防护。根据天气自备保暖衣物、个人生活用品，注意蚊虫防护。根据天气自备保暖衣物、个人生活用品，注意蚊虫防护。根据天气自备保暖衣物、个人生活用品，注意蚊虫防护。根据天气自备保暖衣物、个人生活用品，注意蚊虫防护。根据天气自备保暖衣物、个人生活用品，注意蚊虫防护。根据天气自备保暖衣物、个人生活用品，注意蚊虫防护。根据天气自备保暖衣物、个人生活用品，注意蚊虫防护。根据天气自备保暖衣物、个人生活用品，注意蚊虫防护。根据天气自备保暖衣物、个人生活用品，注意蚊虫防护。根据天气自备保暖衣物、个人生活用品，注意蚊虫防护。根据天气自备保暖衣物、个人生活用品，注意蚊虫防护。根据天气自备保暖衣物、个人生活用品，注意蚊虫防护。根据天气自备保暖衣物、个人生活用品，注意蚊虫防护。根据天气自备保暖衣物、个人生活用品，注意蚊虫防护。根据天气自备保暖衣物、个人生活用品，注意蚊虫防护。根据天气自备保暖衣物、个人生活用品，注意蚊虫防护。根据天气自备保暖衣物、个人生活用品，注意蚊虫防护。根据天气自备保暖衣物、个人生活用品，注意蚊虫防护。根据天气自备保暖衣物、个人生活用品，注意蚊虫防护。',
        onBook: () {},
      );

  /// 从静态 mock 数据查找项目名称，找不到时回退为 '预约项目'
  static String _lookupTitle(String projectId) {
    for (final list in ServiceCardData.staticListByTab.values) {
      for (final card in list) {
        if (card.id == projectId) return card.title;
      }
    }
    return '预约项目';
  }
}

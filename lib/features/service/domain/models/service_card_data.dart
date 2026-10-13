/// 服务列表卡片数据模型（mock 数据，正式 API 对接后替换）
class ServiceCardData {
  final String id;
  final String imageAsset;
  final String title;
  final String subtitle;
  final String buttonText;
  final String? heroAsset;        // 详情页头图，可选
  final String? description;      // 详情页描述，可选
  final String? dateRange;        // 活动日期范围，如 "2026-08-01 至 2026-09-01"
  final int? limitCount;          // 人数限制

  /// 所属分类 Tab key：'fuwu' | 'zhiyouhui' | 'huodong' | 'goujiu'
  final String tabKey;

  const ServiceCardData({
    required this.id,
    required this.imageAsset,
    required this.title,
    required this.subtitle,
    this.buttonText = '立即预约',
    this.heroAsset,
    this.description,
    this.dateRange,
    this.limitCount,
    required this.tabKey,
  });

  /// 按 Tab key 分组的静态 mock 数据，对应蓝湖设计稿
  static const Map<String, List<ServiceCardData>> staticListByTab = {
    'fuwu': [
      ServiceCardData(
        id: 'fuwu_1',
        tabKey: 'fuwu',
        imageAsset: 'assets/images/service/service_golf.png',
        title: '高尔夫',
        subtitle: '当前已有100人参与预约',
        buttonText: '立即预约',
        heroAsset: 'assets/images/service/service_golf.png',
        description: '高尔夫是一项优雅而精准的运动，既能锻炼身体又能陶冶情操。本课程由专业教练指导，从基础挥杆姿势到进阶击球技巧，循序渐进帮助您掌握高尔夫核心技能。场地设施完善，环境优美，适合各水平学员。',
      ),
      ServiceCardData(
        id: 'fuwu_2',
        tabKey: 'fuwu',
        imageAsset: 'assets/images/service/service_running.png',
        title: '跑步',
        subtitle: '当前已有100人参与预约',
        buttonText: '立即预约',
        heroAsset: 'assets/images/service/service_running.png',
        description: '科学跑步训练营，由国家级教练设计训练计划。涵盖热身拉伸、核心力量、配速训练、恢复拉伸全流程。帮助跑者提升耐力、改善姿态、预防损伤，享受奔跑的自由与快乐。',
      ),
      ServiceCardData(
        id: 'fuwu_3',
        tabKey: 'fuwu',
        imageAsset: 'assets/images/service/service_cycling.png',
        title: '自行车',
        subtitle: '当前已有100人参与预约',
        buttonText: '立即预约',
        heroAsset: 'assets/images/service/service_cycling.png',
        description: '骑行技巧进阶课程，包含公路车与山地车双模式教学。从车辆调整、骑行姿势、变速技巧到爬坡冲刺，全方位提升骑行能力。配备专业领骑，路线风景优美，安全有保障。',
      ),
      ServiceCardData(
        id: 'fuwu_4',
        tabKey: 'fuwu',
        imageAsset: 'assets/images/service/service_camping.png',
        title: '露营基地',
        subtitle: '当前已有100人参与预约',
        buttonText: '立即预约',
        heroAsset: 'assets/images/service/service_camping.png',
        description: '远离城市喧嚣，奔赴山野自然！本次野营活动邀大家暂别日常忙碌，沉浸式感受户外山野风光，体验轻松治愈的露营时光。活动安排营地搭建、山野漫步、趣味互动游戏、星空夜谈等丰富内容。',
      ),
    ],
    'zhiyouhui': [
      ServiceCardData(
        id: 'zyh_1',
        tabKey: 'zhiyouhui',
        imageAsset: 'assets/images/service/service_golf.png',
        title: '第四期：同心挚友・寻光之旅',
        subtitle: '当前已有100人参与报名',
        buttonText: '立即报名',
        heroAsset: 'assets/images/service/service_zhiyouhui.webp',
        description: '同心挚友・寻光之旅，第四期活动主题为"寻光"。邀请挚友相聚，共同探索内心的光亮。活动包含主题分享、圆桌对话、冥想体验、自然漫步等环节，在轻松愉悦的氛围中重新连接自我，结识志同道合的朋友。',
      ),
      ServiceCardData(
        id: 'zyh_2',
        tabKey: 'zhiyouhui',
        imageAsset: 'assets/images/service/service_running.png',
        title: '第三期：挚友相逢・聚力沙龙',
        subtitle: '当前已有100人参与报名',
        buttonText: '立即报名',
        heroAsset: 'assets/images/service/service_zhiyouhui.webp',
        description: '挚友相逢・聚力沙龙，第三期主题"聚力"。汇聚各行业优秀挚友，通过主题演讲、分组讨论、资源对接等形式，激发思维碰撞，共创商业与人生新可能。这里不只有分享，更有深度连接。',
      ),
      ServiceCardData(
        id: 'zyh_3',
        tabKey: 'zhiyouhui',
        imageAsset: 'assets/images/service/service_cycling.png',
        title: '第二期：星聚挚友・思享会',
        subtitle: '当前已有100人参与报名',
        buttonText: '立即报名',
        heroAsset: 'assets/images/service/service_zhiyouhui.webp',
        description: '星聚挚友・思享会，第二期主题"思享"。邀请思想领袖分享前沿洞见，设置开放式提问与深度对话环节。在星空下交换思想，在碰撞中启迪智慧，让思考成为一种生活方式。',
      ),
      ServiceCardData(
        id: 'zyh_4',
        tabKey: 'zhiyouhui',
        imageAsset: 'assets/images/service/service_camping.png',
        title: '第一期：挚友同行・山野雅集',
        subtitle: '当前已有100人参与报名',
        buttonText: '立即报名',
        heroAsset: 'assets/images/service/service_zhiyouhui.webp',
        description: '挚友同行・山野雅集，首期活动在山野间举办。茶酒花香，琴棋书画，古风雅集现代演绎。漫步林间、围炉煮茶、吟诗作对，在自然美学中找回内心的宁静与诗意。',
      ),
    ],
    'huodong': [
      ServiceCardData(
        id: 'hd_1',
        tabKey: 'huodong',
        imageAsset: 'assets/images/service/service_golf.png',
        title: '春季户外骑行活动',
        subtitle: '当前已有80人参与报名',
        buttonText: '立即报名',
        dateRange: '2026-08-01 至 2026-09-01',
        limitCount: 100,
        heroAsset: 'assets/images/service/service_huodong.webp',
        description: '春季户外骑行活动，路线全长约30公里，途经湖畔、森林、花海等多重景观。设置多个补给站与打卡点，配备领骑车与收容车，全程安全无忧。春风拂面，骑行赏花，尽享春日限定浪漫。',
      ),
      ServiceCardData(
        id: 'hd_2',
        tabKey: 'huodong',
        imageAsset: 'assets/images/service/service_running.png',
        title: '会员专属品酒会',
        subtitle: '当前已有60人参与报名',
        buttonText: '立即报名',
        dateRange: '2026-09-15 至 2026-10-15',
        limitCount: 80,
        heroAsset: 'assets/images/service/service_huodong.webp',
        description: '会员专属品酒会，精选全球十大产区代表性佳酿，搭配米其林级餐点。邀请资深品酒师现场讲解风土风味、年份特征、配餐艺术。在优雅氛围中品味美酒，拓展高端社交圈层。',
      ),
      ServiceCardData(
        id: 'hd_3',
        tabKey: 'huodong',
        imageAsset: 'assets/images/service/service_cycling.png',
        title: '夏日露营季',
        subtitle: '当前已有120人参与报名',
        buttonText: '立即报名',
        dateRange: '2026-07-01 至 2026-08-31',
        limitCount: 150,
        heroAsset: 'assets/images/service/service_huodong.webp',
        description: '夏日露营季，精选湖畔营地，夜观繁星、晨赏日出。活动含帐篷搭建教学、户外烹饪体验、篝火晚会、水上项目等。亲子同行、情侣约会、好友聚会皆宜，定制专属夏日记忆。',
      ),
      ServiceCardData(
        id: 'hd_4',
        tabKey: 'huodong',
        imageAsset: 'assets/images/service/service_camping.png',
        title: '秋季登山徒步',
        subtitle: '当前已有45人参与报名',
        buttonText: '立即报名',
        dateRange: '2026-10-01 至 2026-11-30',
        limitCount: 60,
        heroAsset: 'assets/images/service/service_huodong.webp',
        description: '秋季登山徒步，路线穿越彩林层染的山谷，海拔落差适中，适合有一定户外基础的参与者。专业领队带队，配备急救包与通讯设备。登顶俯瞰秋色满山，收获身心双重升华。',
      ),
    ],
    'goujiu': [
      ServiceCardData(
        id: 'gj_1',
        tabKey: 'goujiu',
        imageAsset: 'assets/images/service/service_golf.png',
        title: '青稞酒品鉴专场',
        subtitle: '当前已有50人参与预约',
        buttonText: '立即购买',
        heroAsset: 'assets/images/service/service_goujiu.webp',
        description: '青稞酒品鉴专场，深度解析青稞酒独特酿造工艺与风味密码。品鉴5款不同陈酿年份青稞酒，搭配藏式风味小食。了解高原青稞酒的文化传承与创新发展，收藏级佳酿现场可购。',
      ),
      ServiceCardData(
        id: 'gj_2',
        tabKey: 'goujiu',
        imageAsset: 'assets/images/service/service_running.png',
        title: '红酒搭配晚餐',
        subtitle: '当前已有30人参与预约',
        buttonText: '立即购买',
        heroAsset: 'assets/images/service/service_goujiu.webp',
        description: '红酒搭配晚餐，五道式精致西餐对应五款精选红酒。从清爽白葡萄酒开胃，到浓郁红葡萄酒佐主餐，最后甜酒配甜点。主厨现场讲解配餐逻辑，品酒师指导品鉴要领，味蕾的极致享受。',
      ),
      ServiceCardData(
        id: 'gj_3',
        tabKey: 'goujiu',
        imageAsset: 'assets/images/service/service_cycling.png',
        title: '威士忌品鉴课',
        subtitle: '当前已有25人参与预约',
        buttonText: '立即购买',
        heroAsset: 'assets/images/service/service_goujiu.webp',
        description: '威士忌品鉴课，系统讲授威士忌产区分布、蒸馏工艺、桶型风味、陈年变化等核心知识。盲品测试环节训练嗅觉辨识力。适合入门爱好者进阶，也适合资深玩家校准风味认知。',
      ),
      ServiceCardData(
        id: 'gj_4',
        tabKey: 'goujiu',
        imageAsset: 'assets/images/service/service_camping.png',
        title: '鸡尾酒调酒体验',
        subtitle: '当前已有40人参与预约',
        buttonText: '立即购买',
        heroAsset: 'assets/images/service/service_goujiu.webp',
        description: '鸡尾酒调酒体验，国际调酒大赛冠军亲授经典与创意鸡尾酒配方。手把手教学：摇酒器技法、分层倒酒、装饰艺术。现场调制3杯专属鸡尾酒，带走调酒工具包，在家也能做专业级调酒师。',
      ),
    ],
  };
}

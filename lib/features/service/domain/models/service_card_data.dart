/// 服务列表卡片数据模型（mock 数据，正式 API 对接后替换）
class ServiceCardData {
  final String id;
  final String imageAsset;
  final String title;
  final String subtitle;
  final String buttonText;
  final String? heroAsset; // 详情页头图，可选
  final String? description; // 详情页描述，可选
  final String? dateRange; // 活动日期范围，如 "2026-08-01 至 2026-09-01"
  final int? limitCount; // 人数限制
  final String? registrationRange;
  final String? activityAddress;
  final String? detailImageAsset;

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
    this.registrationRange,
    this.activityAddress,
    this.detailImageAsset,
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
        imageAsset: 'assets/images/service/service_zhiyouhui.webp',
        title: '第四期：同心挚友・寻光之旅',
        subtitle: '当前已有100人参与报名',
        buttonText: '立即报名',
        heroAsset: 'assets/images/service/service_zhiyouhui.webp',
        description: '挚友会是专属优质会员的线下圈层社交活动，旨在搭建高端、纯粹、真诚的挚友交流平台。汇聚志同道合的伙伴，跳出日常忙碌，以相聚赋能成长，以交流链接资源。在这里结识同频挚友、分享生活感悟、交流优质认知、拓展优质人脉圈层，解锁全新生活与社交体验。\n\n活动亮点\n纯粹圈层：精准汇聚优质会员，氛围轻松纯粹，拒绝无效社交\n深度交流：主题分享、圆桌畅谈、经验互通，实现思想碰撞\n趣味互动：沉浸式趣味游戏、休闲体验，拉近彼此距离\n资源链接：结识各行各业挚友，拓展人脉、互通资源、共同成长',
      ),
      ServiceCardData(
        id: 'zyh_2',
        tabKey: 'zhiyouhui',
        imageAsset: 'assets/images/service/service_zhiyouhui.webp',
        title: '第三期：挚友相逢・聚力沙龙',
        subtitle: '当前已有100人参与报名',
        buttonText: '立即报名',
        heroAsset: 'assets/images/service/service_zhiyouhui.webp',
        description: '挚友会是专属优质会员的线下圈层社交活动，旨在搭建高端、纯粹、真诚的挚友交流平台。第三期以深度交流与资源链接为主题，邀请同频伙伴在真诚相聚中碰撞思想、连接资源、共同成长。',
      ),
      ServiceCardData(
        id: 'zyh_3',
        tabKey: 'zhiyouhui',
        imageAsset: 'assets/images/service/service_zhiyouhui.webp',
        title: '第二期：星聚挚友・思享会',
        subtitle: '当前已有100人参与报名',
        buttonText: '立即报名',
        heroAsset: 'assets/images/service/service_zhiyouhui.webp',
        description: '挚友会是专属优质会员的线下圈层社交活动，第二期围绕思想分享与深度对话展开，在交流与碰撞中拓展认知边界。',
      ),
      ServiceCardData(
        id: 'zyh_4',
        tabKey: 'zhiyouhui',
        imageAsset: 'assets/images/service/service_zhiyouhui.webp',
        title: '第一期：挚友同行・山野雅集',
        subtitle: '当前已有100人参与报名',
        buttonText: '立即报名',
        heroAsset: 'assets/images/service/service_zhiyouhui.webp',
        description: '挚友会是专属优质会员的线下圈层社交活动，首期以自然雅集为主题，在轻松纯粹的氛围中认识挚友、分享生活、连接彼此。',
      ),
    ],
    'huodong': [
      ServiceCardData(
        id: 'hd_1',
        tabKey: 'huodong',
        imageAsset: 'assets/images/service/activity_detail_hero.png',
        title: '天佑德英才夏令营',
        subtitle: '限100人',
        buttonText: '立即报名',
        dateRange: '2026-08-01至2026-09-01',
        limitCount: 100,
        registrationRange: '2026-08-01至2026-09-01',
        activityAddress: '青海省海东市互助土族自治县天佑德大道',
        heroAsset: 'assets/images/service/activity_detail_hero.png',
        detailImageAsset: 'assets/images/service/activity_detail_content.png',
        description: '天佑德英才夏令营，围绕户外探索、团队协作与成长体验展开，为孩子们带来充实而有意义的夏日时光。',
      ),
      ServiceCardData(
        id: 'hd_2',
        tabKey: 'huodong',
        imageAsset: 'assets/images/service/service_zhiyouhui.webp',
        title: 'Tashi青稞中式微醺夜',
        subtitle: '限100人',
        buttonText: '立即报名',
        dateRange: '2026-08-01至2026-09-01',
        limitCount: 100,
        registrationRange: '2026-08-01至2026-09-01',
        activityAddress: '青海省海东市互助土族自治县天佑德大道',
        heroAsset: 'assets/images/service/activity_detail_hero.png',
        detailImageAsset: 'assets/images/service/activity_detail_content.png',
        description: 'Tashi青稞中式微醺夜，围绕青稞酒与中式风味展开沉浸式品鉴体验。',
      ),
      ServiceCardData(
        id: 'hd_3',
        tabKey: 'huodong',
        imageAsset: 'assets/images/service/service_huodong.webp',
        title: '致敬平凡力量-品味红四星',
        subtitle: '限100人',
        buttonText: '立即报名',
        dateRange: '2026-08-01至2026-09-01',
        limitCount: 100,
        registrationRange: '2026-08-01至2026-09-01',
        activityAddress: '青海省海东市互助土族自治县天佑德大道',
        heroAsset: 'assets/images/service/activity_detail_hero.png',
        detailImageAsset: 'assets/images/service/activity_detail_content.png',
        description: '致敬平凡力量-品味红四星，在轻松的品鉴与交流中感受生活的美好。',
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

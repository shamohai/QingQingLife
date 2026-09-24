/// 服务列表卡片数据模型（mock 数据，正式 API 对接后替换）
class ServiceCardData {
  final String id;
  final String imageAsset;
  final String title;
  final String subtitle;
  final String buttonText;

  /// 所属分类 Tab key：'golf' | 'zhiyouhui' | 'huodong' | 'goujiu'
  final String tabKey;

  const ServiceCardData({
    required this.id,
    required this.imageAsset,
    required this.title,
    required this.subtitle,
    this.buttonText = '立即预约',
    required this.tabKey,
  });

  /// 按 Tab key 分组的静态 mock 数据，对应蓝湖设计稿
  static const Map<String, List<ServiceCardData>> staticListByTab = {
    'golf': [
      ServiceCardData(
        id: 'golf_1',
        tabKey: 'golf',
        imageAsset: 'assets/images/service/service_golf.png',
        title: '高尔夫',
        subtitle: '当前已有100人参与预约',
        buttonText: '立即预约',
      ),
      ServiceCardData(
        id: 'golf_2',
        tabKey: 'golf',
        imageAsset: 'assets/images/service/service_running.png',
        title: '跑步',
        subtitle: '当前已有100人参与预约',
        buttonText: '立即预约',
      ),
      ServiceCardData(
        id: 'golf_3',
        tabKey: 'golf',
        imageAsset: 'assets/images/service/service_cycling.png',
        title: '自行车',
        subtitle: '当前已有100人参与预约',
        buttonText: '立即预约',
      ),
      ServiceCardData(
        id: 'golf_4',
        tabKey: 'golf',
        imageAsset: 'assets/images/service/service_camping.png',
        title: '露营基地',
        subtitle: '当前已有100人参与预约',
        buttonText: '立即预约',
      ),
      ServiceCardData(
        id: 'golf_4',
        tabKey: 'golf',
        imageAsset: 'assets/images/service/service_camping.png',
        title: '露营基地',
        subtitle: '当前已有100人参与预约',
        buttonText: '立即预约',
      ),
      ServiceCardData(
        id: 'golf_4',
        tabKey: 'golf',
        imageAsset: 'assets/images/service/service_camping.png',
        title: '露营基地',
        subtitle: '当前已有100人参与预约',
        buttonText: '立即预约',
      ),
      ServiceCardData(
        id: 'golf_4',
        tabKey: 'golf',
        imageAsset: 'assets/images/service/service_camping.png',
        title: '露营基地',
        subtitle: '当前已有100人参与预约',
        buttonText: '立即预约',
      ),
      ServiceCardData(
        id: 'golf_4',
        tabKey: 'golf',
        imageAsset: 'assets/images/service/service_camping.png',
        title: '露营基地',
        subtitle: '当前已有100人参与预约',
        buttonText: '立即预约',
      ),
      ServiceCardData(
        id: 'golf_4',
        tabKey: 'golf',
        imageAsset: 'assets/images/service/service_camping.png',
        title: '露营基地',
        subtitle: '当前已有100人参与预约',
        buttonText: '立即预约',
      ),
      ServiceCardData(
        id: 'golf_4',
        tabKey: 'golf',
        imageAsset: 'assets/images/service/service_camping.png',
        title: '露营基地',
        subtitle: '当前已有100人参与预约',
        buttonText: '立即预约',
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
      ),
      ServiceCardData(
        id: 'zyh_2',
        tabKey: 'zhiyouhui',
        imageAsset: 'assets/images/service/service_running.png',
        title: '第三期：挚友相逢・聚力沙龙',
        subtitle: '当前已有100人参与报名',
        buttonText: '立即报名',
      ),
      ServiceCardData(
        id: 'zyh_3',
        tabKey: 'zhiyouhui',
        imageAsset: 'assets/images/service/service_cycling.png',
        title: '第二期：星聚挚友・思享会',
        subtitle: '当前已有100人参与报名',
        buttonText: '立即报名',
      ),
      ServiceCardData(
        id: 'zyh_4',
        tabKey: 'zhiyouhui',
        imageAsset: 'assets/images/service/service_camping.png',
        title: '第一期：挚友同行・山野雅集',
        subtitle: '当前已有100人参与报名',
        buttonText: '立即报名',
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
      ),
      ServiceCardData(
        id: 'hd_2',
        tabKey: 'huodong',
        imageAsset: 'assets/images/service/service_running.png',
        title: '会员专属品酒会',
        subtitle: '当前已有60人参与报名',
        buttonText: '立即报名',
      ),
      ServiceCardData(
        id: 'hd_3',
        tabKey: 'huodong',
        imageAsset: 'assets/images/service/service_cycling.png',
        title: '夏日露营季',
        subtitle: '当前已有120人参与报名',
        buttonText: '立即报名',
      ),
      ServiceCardData(
        id: 'hd_4',
        tabKey: 'huodong',
        imageAsset: 'assets/images/service/service_camping.png',
        title: '秋季登山徒步',
        subtitle: '当前已有45人参与报名',
        buttonText: '立即报名',
      ),
    ],
    'goujiu': [
      ServiceCardData(
        id: 'gj_1',
        tabKey: 'goujiu',
        imageAsset: 'assets/images/service/service_golf.png',
        title: '青稞酒品鉴专场',
        subtitle: '当前已有50人参与预约',
        buttonText: '立即预约',
      ),
      ServiceCardData(
        id: 'gj_2',
        tabKey: 'goujiu',
        imageAsset: 'assets/images/service/service_running.png',
        title: '红酒搭配晚餐',
        subtitle: '当前已有30人参与预约',
        buttonText: '立即预约',
      ),
      ServiceCardData(
        id: 'gj_3',
        tabKey: 'goujiu',
        imageAsset: 'assets/images/service/service_cycling.png',
        title: '威士忌品鉴课',
        subtitle: '当前已有25人参与预约',
        buttonText: '立即预约',
      ),
      ServiceCardData(
        id: 'gj_4',
        tabKey: 'goujiu',
        imageAsset: 'assets/images/service/service_camping.png',
        title: '鸡尾酒调酒体验',
        subtitle: '当前已有40人参与预约',
        buttonText: '立即预约',
      ),
    ],
  };
}

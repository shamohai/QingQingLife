/// 首页 4 个模块接口响应数据模型（POST /api/common/app/gethomeinfo）
library;

import 'package:qingqinglife/features/product/domain/repositories/product_repository.dart';

import 'carousel_model.dart';

/// 首页 4 个模块响应聚合模型
class HomeInfoModel {
  final List<HomeNavListModel> navList;
  final HomeMonthlyServiceInfoModel? monthlyServiceInfo;
  final HomeOnlineActivityInfoModel? onlineActivityInfo;
  final HomeOfflineActivityInfoModel? offlineActivityInfo;

  const HomeInfoModel({required this.navList, this.monthlyServiceInfo, this.onlineActivityInfo, this.offlineActivityInfo});

  factory HomeInfoModel.fromJson(Map<String, dynamic> json) {
    // 1. navlist (金刚区)
    final navRaw = json['navlist'];
    final navList = <HomeNavListModel>[];
    if (navRaw is List) {
      for (final item in navRaw) {
        if (item is Map<String, dynamic>) {
          navList.add(HomeNavListModel.fromJson(item));
        }
      }
    }

    // 2. monthlyserviceinfo (每月权益)
    final monthlyRaw = json['monthlyserviceinfo'];
    HomeMonthlyServiceInfoModel? monthlyServiceInfo;
    if (monthlyRaw is Map<String, dynamic>) {
      monthlyServiceInfo = HomeMonthlyServiceInfoModel.fromJson(monthlyRaw);
    }

    // 3. 新接口在线活动字段在根对象下分别返回。
    final activityBlocks = <HomeActivityBlockModel>[];
    for (final entry in const <String>['drinkmapactivity', 'drinkrankactivity']) {
      final activity = json[entry];
      if (activity is Map) {
        activityBlocks.add(HomeActivityBlockModel.fromJson(Map<String, dynamic>.from(activity), id: entry));
      }
    }
    final onlineActivityInfo = activityBlocks.isEmpty ? null : HomeOnlineActivityInfoModel(title: '线上活动', blocks: activityBlocks);

    // 4. offlineactivityinfo (线下活动)
    final offlineRaw = json['offlineactivityinfo'];
    HomeOfflineActivityInfoModel? offlineActivityInfo;
    if (offlineRaw != null) {
      offlineActivityInfo = HomeOfflineActivityInfoModel.fromJson(offlineRaw);
    }

    return HomeInfoModel(
      navList: navList,
      monthlyServiceInfo: monthlyServiceInfo,
      onlineActivityInfo: onlineActivityInfo,
      offlineActivityInfo: offlineActivityInfo,
    );
  }

  List<HomeKingKongItem> toKingKongItems() {
    return navList.map((e) => e.toKingKongItem()).toList();
  }

  List<HomeMonthlyBenefit> toMonthlyBenefits() {
    return monthlyServiceInfo?.toMonthlyBenefits() ?? [];
  }

  List<HomeActivityBlock> toActivityBlocks() {
    return onlineActivityInfo?.toActivityBlocks() ?? [];
  }

  List<HomeTopicActivityBlock> toTopicActivityBlocks() {
    return offlineActivityInfo?.toTopicActivityBlocks() ?? [];
  }
}

/// 1. 金刚区导航数据模型 (navlist)
class HomeNavListModel {
  final String id;
  final String title;
  final String iconUrl;
  final String actionUrl;
  final JumpType jumpType;

  const HomeNavListModel({required this.id, required this.title, required this.iconUrl, required this.actionUrl, required this.jumpType});

  factory HomeNavListModel.fromJson(Map<String, dynamic> json) {
    return HomeNavListModel(
      id: '',
      title: (json['title'] ?? '').toString(),
      iconUrl: (json['icon'] ?? '').toString().replaceAll('&amp;', '&'),
      actionUrl: (json['link'] ?? '').toString(),
      jumpType: JumpType.fromJson(json['jumptype']),
    );
  }

  HomeKingKongItem toKingKongItem() {
    return HomeKingKongItem(iconUrl: iconUrl, label: title, actionUrl: actionUrl.isNotEmpty ? actionUrl : null, jumpType: jumpType);
  }
}

/// 2. 每月权益数据模型 (monthlyserviceinfo)
class HomeMonthlyServiceInfoModel {
  final int serviceId;
  final String title;
  final String subtitle;
  final bool isReceived; // 当月权益优惠券已领取
  final bool settlemented; // 已发货\已兑换\已核销
  final int userServiceId;
  final List<HomeMonthlyProductModel> productList;

  const HomeMonthlyServiceInfoModel({
    this.serviceId = 0,
    required this.title,
    this.subtitle = '',
    this.isReceived = false,
    this.settlemented = false,
    this.userServiceId = 0,
    required this.productList,
  });

  factory HomeMonthlyServiceInfoModel.fromJson(Map<String, dynamic> json) {
    final serviceIdVal = json['serviceid'] ?? 0;
    final parentServiceId = serviceIdVal is num ? serviceIdVal.toInt() : int.tryParse('$serviceIdVal') ?? 0;

    final isReceivedVal = json['isreceived'] ?? false;
    final parsedIsReceived = isReceivedVal is bool ? isReceivedVal : (isReceivedVal == 1 || isReceivedVal == '1' || isReceivedVal == 'true');

    final settlementedVal = json['settlemented'] ?? false;
    final parsedSettlemented = settlementedVal is bool ? settlementedVal : (settlementedVal == 1 || settlementedVal == '1' || settlementedVal == 'true');

    final userServiceIdVal = json['userserviceid'] ?? 0;
    final parsedUserServiceId = userServiceIdVal is num ? userServiceIdVal.toInt() : int.tryParse('$userServiceIdVal') ?? 0;

    final rawList = json['productlist'];
    final items = <HomeMonthlyProductModel>[];
    if (rawList is List) {
      for (final item in rawList) {
        if (item is Map<String, dynamic>) {
          items.add(
            HomeMonthlyProductModel.fromJson(
              item,
              parentServiceId: parentServiceId,
              parentIsReceived: parsedIsReceived || parsedUserServiceId > 0,
              parentUserServiceId: parsedUserServiceId,
              parentSettlemented: parsedSettlemented,
            ),
          );
        }
      }
    }
    return HomeMonthlyServiceInfoModel(
      serviceId: parentServiceId,
      title: (json['title'] ?? '每月权益').toString(),
      subtitle: (json['subtitle'] ?? '').toString(),
      isReceived: parsedIsReceived,
      settlemented: parsedSettlemented,
      userServiceId: parsedUserServiceId,
      productList: items,
    );
  }

  List<HomeMonthlyBenefit> toMonthlyBenefits() {
    return productList.map((e) => e.toMonthlyBenefit()).toList();
  }
}

/// 每月权益商品项 (monthlyserviceinfo.productlist)
class HomeMonthlyProductModel {
  final String id;
  final String title;
  final String imageUrl;
  final String actionUrl;
  final int userServiceId;
  final bool isReceived; // 当月权益优惠券已领取
  final bool settlemented; // 已发货\已兑换\已核销
  final int serviceId;

  const HomeMonthlyProductModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.actionUrl,
    this.userServiceId = 0,
    this.isReceived = false,
    this.settlemented = false,
    this.serviceId = 0,
  });

  factory HomeMonthlyProductModel.fromJson(
    Map<String, dynamic> json, {
    int? parentServiceId,
    bool? parentIsReceived,
    int? parentUserServiceId,
    bool? parentSettlemented,
  }) {
    // 优先识别 pid 作为权益项商品 ID，如无则回退到 parentServiceId / id
    final itemId = json['pid'] ?? parentServiceId ?? '';

    // 优先识别 productname 作为权益标题，回退到 title / name
    final titleVal = json['productname'] ?? '';

    // 优先识别 productimg 作为商品图片，回退到 coverurl / imgurl / imageurl
    final imageVal = json['productimg'] ?? '';

    final itemUserServiceId = parentUserServiceId ?? 0;
    final itemIsReceived = parentIsReceived ?? false;
    final itemSettlemented = parentSettlemented ?? false;

    final parsedUserServiceId = itemUserServiceId;
    final parsedIsReceived = itemIsReceived;
    final parsedSettlemented = itemSettlemented;

    return HomeMonthlyProductModel(
      id: itemId.toString(),
      title: titleVal.toString().trim(),
      imageUrl: imageVal.toString().replaceAll('&amp;', '&'),
      actionUrl: '',
      userServiceId: parsedUserServiceId,
      isReceived: parsedIsReceived,
      settlemented: parsedSettlemented,
      serviceId: parentServiceId ?? 0,
    );
  }

  HomeMonthlyBenefit toMonthlyBenefit() {
    return HomeMonthlyBenefit(
      id: id,
      title: title,
      imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
      actionUrl: actionUrl.isNotEmpty ? actionUrl : null,
      userServiceId: userServiceId,
      isReceived: isReceived,
      settlemented: settlemented,
      serviceId: serviceId,
    );
  }
}

/// 3. 线上活动模块数据模型 (onlineactivityinfo)
class HomeOnlineActivityInfoModel {
  final String title;
  final List<HomeActivityBlockModel> blocks;

  const HomeOnlineActivityInfoModel({required this.title, required this.blocks});

  List<HomeActivityBlock> toActivityBlocks() {
    return blocks.map((e) => e.toActivityBlock()).toList();
  }
}

/// 线上活动单块数据模型
class HomeActivityBlockModel {
  final String id;
  final String title;
  final String? imageUrl;
  final String actionUrl;

  const HomeActivityBlockModel({required this.id, required this.title, this.imageUrl, required this.actionUrl});

  factory HomeActivityBlockModel.fromJson(Map<String, dynamic> json, {required String id}) {
    final imageUrl = (json['cardimg'] ?? '').toString().replaceAll('&amp;', '&');

    return HomeActivityBlockModel(id: id, title: '', imageUrl: imageUrl.isNotEmpty ? imageUrl : null, actionUrl: (json['activityurl'] ?? '').toString());
  }

  HomeActivityBlock toActivityBlock() {
    return HomeActivityBlock(id: id, title: title, imageUrl: imageUrl, actionUrl: actionUrl.isNotEmpty ? actionUrl : null);
  }
}

/// 4. 线下活动模块数据模型 (offlineactivityinfo)
class HomeOfflineActivityInfoModel {
  final String title;
  final List<HomeOfflineBlockModel> blocks;

  const HomeOfflineActivityInfoModel({required this.title, required this.blocks});

  factory HomeOfflineActivityInfoModel.fromJson(dynamic jsonInput) {
    if (jsonInput is! Map) {
      return const HomeOfflineActivityInfoModel(title: '线下活动', blocks: <HomeOfflineBlockModel>[]);
    }

    final raw = Map<String, dynamic>.from(jsonInput);
    final rawList = raw['list'];
    final items = <HomeOfflineBlockModel>[];
    if (rawList is List) {
      for (final item in rawList) {
        if (item is Map) {
          items.add(HomeOfflineBlockModel.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    return HomeOfflineActivityInfoModel(title: (raw['title'] ?? '线下活动').toString(), blocks: items);
  }

  List<HomeTopicActivityBlock> toTopicActivityBlocks() {
    return blocks.map((e) => e.toTopicActivityBlock()).toList();
  }
}

/// 线下活动单块数据模型
class HomeOfflineBlockModel {
  final String id;
  final String title;
  final String imageUrl;
  final String actionUrl;

  const HomeOfflineBlockModel({required this.id, required this.title, required this.imageUrl, required this.actionUrl});

  factory HomeOfflineBlockModel.fromJson(Map<String, dynamic> json) {
    return HomeOfflineBlockModel(
      id: (json['id'] ?? '').toString(),
      title: (json['name'] ?? '').toString(),
      imageUrl: (json['coverurl'] ?? '').toString().replaceAll('&amp;', '&'),
      actionUrl: (json['activityurl'] ?? '').toString(),
    );
  }

  HomeTopicActivityBlock toTopicActivityBlock() {
    return HomeTopicActivityBlock(id: id, title: title, imageUrl: imageUrl.isNotEmpty ? imageUrl : null, actionUrl: actionUrl.isNotEmpty ? actionUrl : null);
  }
}

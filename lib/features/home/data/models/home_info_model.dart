/// 首页 4 个模块接口响应数据模型（POST /api/common/gethomeinfo）
library;

import 'package:qingqinglife/features/product/domain/repositories/product_repository.dart';

/// 首页 4 个模块响应聚合模型
class HomeInfoModel {
  final List<HomeNavListModel> navList;
  final HomeMonthlyServiceInfoModel? monthlyServiceInfo;
  final HomeOnlineActivityInfoModel? onlineActivityInfo;
  final HomeOfflineActivityInfoModel? offlineActivityInfo;

  const HomeInfoModel({
    required this.navList,
    this.monthlyServiceInfo,
    this.onlineActivityInfo,
    this.offlineActivityInfo,
  });

  factory HomeInfoModel.fromJson(Map<String, dynamic> json) {
    // 1. navlist (金刚区)
    final navRaw = json['navlist'] ?? json['nav_list'] ?? json['navs'];
    final navList = <HomeNavListModel>[];
    if (navRaw is List) {
      for (final item in navRaw) {
        if (item is Map<String, dynamic>) {
          navList.add(HomeNavListModel.fromJson(item));
        }
      }
    }

    // 2. monthlyserviceinfo (每月权益)
    final monthlyRaw = json['monthlyserviceinfo'] ?? json['monthly_service_info'];
    HomeMonthlyServiceInfoModel? monthlyServiceInfo;
    if (monthlyRaw is Map<String, dynamic>) {
      monthlyServiceInfo = HomeMonthlyServiceInfoModel.fromJson(monthlyRaw);
    } else if (monthlyRaw is List) {
      monthlyServiceInfo = HomeMonthlyServiceInfoModel.fromJson(monthlyRaw.isNotEmpty ? monthlyRaw.first as Map<String, dynamic> : {});
    }

    // 3. onlineactivityinfo (线上活动)
    final onlineRaw = json['onlineactivityinfo'] ?? json['online_activity_info'];
    HomeOnlineActivityInfoModel? onlineActivityInfo;
    if (onlineRaw != null) {
      onlineActivityInfo = HomeOnlineActivityInfoModel.fromJson(onlineRaw);
    }

    // 4. offlineactivityinfo (线下活动)
    final offlineRaw = json['offlineactivityinfo'] ?? json['offline_activity_info'];
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

  const HomeNavListModel({
    required this.id,
    required this.title,
    required this.iconUrl,
    required this.actionUrl,
  });

  factory HomeNavListModel.fromJson(Map<String, dynamic> json) {
    return HomeNavListModel(
      id: (json['id'] ?? json['navid'] ?? '').toString(),
      title: (json['title'] ?? json['name'] ?? json['navname'] ?? json['label'] ?? '').toString(),
      iconUrl: (json['coverurl'] ?? json['imgurl'] ?? json['iconurl'] ?? json['icon'] ?? json['imageurl'] ?? '').toString().replaceAll('&amp;', '&'),
      actionUrl: (json['path'] ?? json['viewurl'] ?? json['actionurl'] ?? json['url'] ?? json['link'] ?? '').toString(),
    );
  }

  HomeKingKongItem toKingKongItem() {
    return HomeKingKongItem(
      iconUrl: iconUrl,
      label: title,
      actionUrl: actionUrl.isNotEmpty ? actionUrl : null,
    );
  }
}

/// 2. 每月权益数据模型 (monthlyserviceinfo)
class HomeMonthlyServiceInfoModel {
  final String title;
  final List<HomeMonthlyProductModel> productList;

  const HomeMonthlyServiceInfoModel({
    required this.title,
    required this.productList,
  });

  factory HomeMonthlyServiceInfoModel.fromJson(Map<String, dynamic> json) {
    final rawList = json['productlist'] ?? json['product_list'] ?? json['list'] ?? json['products'];
    final items = <HomeMonthlyProductModel>[];
    if (rawList is List) {
      for (final item in rawList) {
        if (item is Map<String, dynamic>) {
          items.add(HomeMonthlyProductModel.fromJson(item));
        }
      }
    }
    return HomeMonthlyServiceInfoModel(
      title: (json['title'] ?? json['name'] ?? '每月权益').toString(),
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

  const HomeMonthlyProductModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.actionUrl,
  });

  factory HomeMonthlyProductModel.fromJson(Map<String, dynamic> json) {
    return HomeMonthlyProductModel(
      id: (json['id'] ?? json['productid'] ?? '').toString(),
      title: (json['title'] ?? json['name'] ?? json['productname'] ?? '').toString(),
      imageUrl: (json['coverurl'] ?? json['imgurl'] ?? json['imageurl'] ?? json['productimg'] ?? '').toString().replaceAll('&amp;', '&'),
      actionUrl: (json['path'] ?? json['viewurl'] ?? json['actionurl'] ?? json['url'] ?? '').toString(),
    );
  }

  HomeMonthlyBenefit toMonthlyBenefit() {
    return HomeMonthlyBenefit(
      id: id,
      title: title,
      imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
      actionUrl: actionUrl.isNotEmpty ? actionUrl : null,
    );
  }
}

/// 3. 线上活动模块数据模型 (onlineactivityinfo)
class HomeOnlineActivityInfoModel {
  final String title;
  final List<HomeActivityBlockModel> blocks;

  const HomeOnlineActivityInfoModel({
    required this.title,
    required this.blocks,
  });

  factory HomeOnlineActivityInfoModel.fromJson(dynamic jsonInput) {
    var title = '线上活动';
    final items = <HomeActivityBlockModel>[];

    if (jsonInput is List) {
      for (final element in jsonInput) {
        if (element is Map<String, dynamic>) {
          if (element['title'] != null) {
            title = element['title'].toString();
          }
          final subList = element['list'] ?? element['activitylist'] ?? element['blocks'] ?? element['items'];
          if (subList is List) {
            for (final item in subList) {
              if (item is Map<String, dynamic>) {
                items.add(HomeActivityBlockModel.fromJson(item));
              }
            }
          }
        }
      }
    } else if (jsonInput is Map<String, dynamic>) {
      title = (jsonInput['title'] ?? jsonInput['activitytitle'] ?? '线上活动').toString();
      final subList = jsonInput['list'] ?? jsonInput['activitylist'] ?? jsonInput['blocks'] ?? jsonInput['items'];
      if (subList is List) {
        for (final item in subList) {
          if (item is Map<String, dynamic>) {
            items.add(HomeActivityBlockModel.fromJson(item));
          }
        }
      } else if (subList == null && (jsonInput['coverurl'] != null || jsonInput['imgurl'] != null)) {
        items.add(HomeActivityBlockModel.fromJson(jsonInput));
      }
    }

    return HomeOnlineActivityInfoModel(
      title: title,
      blocks: items,
    );
  }

  List<HomeActivityBlock> toActivityBlocks() {
    return blocks.map((e) => e.toActivityBlock()).toList();
  }
}

/// 线上活动单块数据模型
class HomeActivityBlockModel {
  final String id;
  final String title;
  final String? imageUrl;
  final List<String>? imageUrls;
  final String actionUrl;

  const HomeActivityBlockModel({
    required this.id,
    required this.title,
    this.imageUrl,
    this.imageUrls,
    required this.actionUrl,
  });

  factory HomeActivityBlockModel.fromJson(Map<String, dynamic> json) {
    List<String>? urls;
    final rawUrls = json['imageurls'] ?? json['imgurls'] ?? json['images'];
    if (rawUrls is List) {
      urls = rawUrls.map((e) => e.toString().replaceAll('&amp;', '&')).where((e) => e.isNotEmpty).toList();
    } else if (rawUrls is String && rawUrls.contains(',')) {
      urls = rawUrls.split(',').map((e) => e.trim().replaceAll('&amp;', '&')).where((e) => e.isNotEmpty).toList();
    }

    final singleUrl = (json['coverurl'] ?? json['imgurl'] ?? json['imageurl'] ?? json['img'] ?? '').toString().replaceAll('&amp;', '&');

    return HomeActivityBlockModel(
      id: (json['id'] ?? json['activityid'] ?? '').toString(),
      title: (json['title'] ?? json['activitytitle'] ?? json['name'] ?? '').toString(),
      imageUrl: singleUrl.isNotEmpty ? singleUrl : null,
      imageUrls: urls,
      actionUrl: (json['path'] ?? json['viewurl'] ?? json['actionurl'] ?? json['url'] ?? '').toString(),
    );
  }

  HomeActivityBlock toActivityBlock() {
    return HomeActivityBlock(
      id: id,
      title: title,
      imageUrl: imageUrl,
      imageUrls: imageUrls,
      actionUrl: actionUrl.isNotEmpty ? actionUrl : null,
    );
  }
}

/// 4. 线下活动模块数据模型 (offlineactivityinfo)
class HomeOfflineActivityInfoModel {
  final String title;
  final List<HomeOfflineBlockModel> blocks;

  const HomeOfflineActivityInfoModel({
    required this.title,
    required this.blocks,
  });

  factory HomeOfflineActivityInfoModel.fromJson(dynamic jsonInput) {
    var title = '线下活动';
    final items = <HomeOfflineBlockModel>[];

    if (jsonInput is List) {
      for (final element in jsonInput) {
        if (element is Map<String, dynamic>) {
          if (element['title'] != null) {
            title = element['title'].toString();
          }
          final subList = element['list'] ?? element['activitylist'] ?? element['blocks'] ?? element['items'];
          if (subList is List) {
            for (final item in subList) {
              if (item is Map<String, dynamic>) {
                items.add(HomeOfflineBlockModel.fromJson(item));
              }
            }
          }
        }
      }
    } else if (jsonInput is Map<String, dynamic>) {
      title = (jsonInput['title'] ?? jsonInput['activitytitle'] ?? '线下活动').toString();
      final subList = jsonInput['list'] ?? jsonInput['activitylist'] ?? jsonInput['blocks'] ?? jsonInput['items'];
      if (subList is List) {
        for (final item in subList) {
          if (item is Map<String, dynamic>) {
            items.add(HomeOfflineBlockModel.fromJson(item));
          }
        }
      } else if (subList == null && (jsonInput['coverurl'] != null || jsonInput['imgurl'] != null)) {
        items.add(HomeOfflineBlockModel.fromJson(jsonInput));
      }
    }

    return HomeOfflineActivityInfoModel(
      title: title,
      blocks: items,
    );
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

  const HomeOfflineBlockModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.actionUrl,
  });

  factory HomeOfflineBlockModel.fromJson(Map<String, dynamic> json) {
    return HomeOfflineBlockModel(
      id: (json['id'] ?? json['activityid'] ?? '').toString(),
      title: (json['title'] ?? json['activitytitle'] ?? json['name'] ?? '').toString(),
      imageUrl: (json['coverurl'] ?? json['imgurl'] ?? json['imageurl'] ?? json['img'] ?? '').toString().replaceAll('&amp;', '&'),
      actionUrl: (json['path'] ?? json['viewurl'] ?? json['actionurl'] ?? json['url'] ?? '').toString(),
    );
  }

  HomeTopicActivityBlock toTopicActivityBlock() {
    return HomeTopicActivityBlock(
      id: id,
      title: title,
      imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
      actionUrl: actionUrl.isNotEmpty ? actionUrl : null,
    );
  }
}

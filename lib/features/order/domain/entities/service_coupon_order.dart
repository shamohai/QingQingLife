import 'package:decimal/decimal.dart';

/// 服务券订单预处理实体。
///
/// 对应接口：POST /api/order/v2/predealservicecouponorder
class ServiceCouponPreDealData {
  const ServiceCouponPreDealData({
    required this.wallet,
    required this.credit,
    required this.creditMoney,
    required this.shipFee,
    required this.totalDiscount,
    required this.totalAmount,
    required this.couponDiscount,
    required this.maxCouponCount,
    required this.dontShowAddress,
    required this.orderType,
    required this.payType,
    required this.stores,
    this.shipAddress,
    this.sendTimes = const [],
    this.address,
    this.storePhone,
    this.dataTag,
  });

  final Decimal wallet;
  final int credit;
  final Decimal creditMoney;
  final Decimal shipFee;
  final Decimal totalDiscount;
  final Decimal totalAmount;
  final Decimal couponDiscount;
  final int maxCouponCount;
  final bool dontShowAddress;
  final int orderType;
  final int payType;
  final List<ServiceCouponOrderStore> stores;
  final ServiceCouponOrderAddress? shipAddress;
  final List<ServiceCouponOrderSendTime> sendTimes;
  final String? address;
  final String? storePhone;
  final String? dataTag;

  List<ServiceCouponOrderProduct> get products => stores.expand((store) => store.products).toList(growable: false);

  factory ServiceCouponPreDealData.fromJson(Map<String, dynamic> json) {
    return ServiceCouponPreDealData(
      wallet: _decimal(json['wallet']),
      credit: _integer(json['credit']),
      creditMoney: _decimal(json['creditmoney']),
      shipFee: _decimal(json['shipfee']),
      totalDiscount: _decimal(json['totaldiscount']),
      totalAmount: _decimal(json['totalamount']),
      couponDiscount: _decimal(json['coupondiscount']),
      maxCouponCount: _integer(json['maxcouponcount']),
      dontShowAddress: _boolean(json['dontshowaddress']),
      orderType: _integer(json['ordertype']),
      payType: _integer(json['paytype']),
      stores: _mapList(json['stores'], ServiceCouponOrderStore.fromJson),
      shipAddress: _mapValue(json['shipaddress'], ServiceCouponOrderAddress.fromJson),
      sendTimes: _mapList(json['sendtime'], ServiceCouponOrderSendTime.fromJson),
      address: _nullableText(json['address']),
      storePhone: _nullableText(json['storephone']),
      dataTag: _nullableText(json['datatag']),
    );
  }
}

class ServiceCouponOrderStore {
  const ServiceCouponOrderStore({
    required this.shipFee,
    required this.orderAmount,
    required this.products,
    this.remark,
    this.sort = 0,
    this.storeId = 0,
    this.storeName,
  });

  final Decimal shipFee;
  final Decimal orderAmount;
  final List<ServiceCouponOrderProduct> products;
  final String? remark;
  final int sort;
  final int storeId;
  final String? storeName;

  factory ServiceCouponOrderStore.fromJson(Map<String, dynamic> json) {
    return ServiceCouponOrderStore(
      shipFee: _decimal(json['shipfee']),
      orderAmount: _decimal(json['orderamount']),
      products: _mapList(json['products'], ServiceCouponOrderProduct.fromJson),
      remark: _nullableText(json['remark']),
      sort: _integer(json['sort']),
      storeId: _integer(json['storeid']),
      storeName: _nullableText(json['storename']),
    );
  }
}

class ServiceCouponOrderProduct {
  const ServiceCouponOrderProduct({
    required this.productType,
    required this.productId,
    required this.storeId,
    required this.quantity,
    required this.creditCount,
    required this.price,
    required this.marketPrice,
    required this.prepaidPrice,
    required this.discount,
    required this.isCredit,
    this.productSn,
    this.productName,
    this.imgUrl,
    this.priceDescription,
    this.marketPriceDescription,
    this.saleUnit,
    this.warning,
  });

  final int productType;
  final int productId;
  final int storeId;
  final int quantity;
  final Decimal creditCount;
  final Decimal price;
  final Decimal marketPrice;
  final Decimal prepaidPrice;
  final Decimal discount;
  final bool isCredit;
  final String? productSn;
  final String? productName;
  final String? imgUrl;
  final String? priceDescription;
  final String? marketPriceDescription;
  final String? saleUnit;
  final String? warning;

  String get displayName => productName?.trim().isNotEmpty == true ? productName!.trim() : '服务券商品';

  String get displaySpec {
    final candidates = [priceDescription, marketPriceDescription, saleUnit];
    return candidates.whereType<String>().map((value) => value.trim()).firstWhere((value) => value.isNotEmpty, orElse: () => '');
  }

  factory ServiceCouponOrderProduct.fromJson(Map<String, dynamic> json) {
    return ServiceCouponOrderProduct(
      productType: _integer(json['producttype']),
      productId: _integer(json['productid']),
      storeId: _integer(json['storeid']),
      quantity: _integer(json['num']),
      creditCount: _decimal(json['creditcount']),
      price: _decimal(json['price']),
      marketPrice: _decimal(json['marketprice']),
      prepaidPrice: _decimal(json['prepaidprice']),
      discount: _decimal(json['discount']),
      isCredit: _boolean(json['iscredit']),
      productSn: _nullableText(json['productsn']),
      productName: _nullableText(json['productname']),
      imgUrl: _nullableText(json['imgurl']),
      priceDescription: _nullableText(json['pricedesc']),
      marketPriceDescription: _nullableText(json['marketpricedesc']),
      saleUnit: _nullableText(json['saleunit']),
      warning: _nullableText(json['warning']),
    );
  }
}

class ServiceCouponOrderAddress {
  const ServiceCouponOrderAddress({
    required this.id,
    required this.regionId,
    required this.name,
    required this.cityId,
    required this.cityName,
    required this.provinceId,
    required this.provinceName,
    required this.districtId,
    required this.districtName,
    required this.address,
    required this.isDefault,
    required this.phone,
    required this.mobile,
    this.email,
    this.zipCode,
  });

  final int id;
  final int regionId;
  final String name;
  final int cityId;
  final String cityName;
  final int provinceId;
  final String provinceName;
  final int districtId;
  final String districtName;
  final String address;
  final bool isDefault;
  final String phone;
  final String mobile;
  final String? email;
  final String? zipCode;

  String get displayPhone => phone.trim().isNotEmpty ? phone : mobile;

  String get regionText => [provinceName, cityName, districtName].where((value) => value.trim().isNotEmpty).join(' ');

  factory ServiceCouponOrderAddress.fromJson(Map<String, dynamic> json) {
    return ServiceCouponOrderAddress(
      id: _integer(json['id']),
      regionId: _integer(json['regionid']),
      name: _nullableText(json['consignee']) ?? '',
      cityId: _integer(json['cityid']),
      cityName: _nullableText(json['cityname']) ?? '',
      provinceId: _integer(json['provinceid']),
      provinceName: _nullableText(json['provincename']) ?? '',
      districtId: _integer(json['countyid']),
      districtName: _nullableText(json['countyname']) ?? '',
      address: _nullableText(json['address']) ?? '',
      isDefault: _boolean(json['isdefult']),
      phone: _nullableText(json['phone']) ?? '',
      mobile: _nullableText(json['mobile']) ?? '',
      email: _nullableText(json['email']),
      zipCode: _nullableText(json['zipcode']),
    );
  }
}

class ServiceCouponOrderSendTime {
  const ServiceCouponOrderSendTime({this.sendDate, this.date, this.timeList = const []});

  final String? sendDate;
  final DateTime? date;
  final List<String> timeList;

  factory ServiceCouponOrderSendTime.fromJson(Map<String, dynamic> json) {
    final rawTimeList = json['Timelist'] ?? json['timelist'];
    return ServiceCouponOrderSendTime(
      sendDate: _nullableText(json['senddate']),
      date: _dateTime(json['date']),
      timeList: rawTimeList is List ? rawTimeList.map((value) => value.toString()).toList(growable: false) : const [],
    );
  }
}

/// 服务券订单提交响应。
///
/// 对应接口：POST /api/order/v2/submitservicecouponorder
class ServiceCouponOrderSubmitResult {
  const ServiceCouponOrderSubmitResult({required this.payableAmount, required this.orderId, this.dataTag, this.productImage});

  final Decimal payableAmount;
  final int orderId;
  final String? dataTag;
  final String? productImage;

  factory ServiceCouponOrderSubmitResult.fromJson(Map<String, dynamic> json) {
    return ServiceCouponOrderSubmitResult(
      payableAmount: _decimal(json['surplusmoney']),
      orderId: _integer(json['orderid']),
      dataTag: _nullableText(json['datatag']),
      productImage: _nullableText(json['productimg']),
    );
  }
}

String? _nullableText(dynamic value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

int _integer(dynamic value) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

Decimal _decimal(dynamic value) {
  if (value == null) return Decimal.zero;
  if (value is Decimal) return value;
  return Decimal.tryParse(value.toString()) ?? Decimal.zero;
}

bool _boolean(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final normalized = value?.toString().trim().toLowerCase();
  return normalized == 'true' || normalized == '1';
}

DateTime? _dateTime(dynamic value) {
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

T? _mapValue<T>(dynamic value, T Function(Map<String, dynamic>) fromJson) {
  if (value is! Map) return null;
  return fromJson(Map<String, dynamic>.from(value));
}

List<T> _mapList<T>(dynamic value, T Function(Map<String, dynamic>) fromJson) {
  if (value is! List) return const [];
  return value.whereType<Map>().map((item) => fromJson(Map<String, dynamic>.from(item))).toList(growable: false);
}

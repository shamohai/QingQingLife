import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_response.dart';
import '../../../../../core/network/providers.dart';
import '../../domain/repositories/service_repository.dart';
import '../../domain/models/share_cart_template_model.dart';
import '../../domain/models/share_cart_template_detail_model.dart';
import '../../domain/models/share_cart_product_model.dart';
import '../../domain/models/share_cart_candidate_model.dart';
import '../../domain/models/service_submit_order_model.dart';
import '../../domain/models/offline_activity_item.dart';
import '../../domain/models/offline_activity_detail_model.dart';
import '../../domain/models/reservation_service_item.dart';
import '../../domain/models/reservation_service_detail_model.dart';
import '../../domain/models/reservation_record_item.dart';

/// 服务中心远程数据源
class ServiceRemoteDataSource implements ServiceRepository {
  final ApiClient apiClient;

  ServiceRemoteDataSource({required this.apiClient});

  @override
  Future<ApiResponse<List<ReservationServiceItem>>> getReservationServiceList() async {
    return apiClient.post<List<ReservationServiceItem>>(
      '/api/sys/app/getreservationservicelist',
      data: <String, dynamic>{},
      fromJson: (dynamic json) {
        final source = json as Map<String, dynamic>? ?? const <String, dynamic>{};
        final listJson = source['list'] as List<dynamic>? ?? const <dynamic>[];
        return listJson.map((e) => ReservationServiceItem.fromJson(e as Map<String, dynamic>)).toList();
      },
    );
  }

  @override
  Future<ApiResponse<ReservationServiceDetail>> getReservationServiceDetail(int serviceId) async {
    return apiClient.post<ReservationServiceDetail>(
      '/api/sys/app/getreservationservicedetail',
      data: <String, dynamic>{'serviceid': serviceId},
      fromJson: (dynamic json) => ReservationServiceDetail.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<int>> submitReservation({
    required int serviceId,
    required String contactName,
    required String contactPhoneNumber,
    required String reservationDateTime,
    required String idNo,
    required int userCount,
    required String remark,
  }) async {
    return apiClient.post<int>(
      '/api/sys/app/submitreservation',
      data: <String, dynamic>{
        'serviceid': serviceId,
        'contactname': contactName,
        'contactphonenumber': contactPhoneNumber,
        'reservationdatetime': reservationDateTime,
        'idno': idNo,
        'usercount': userCount,
        'remark': remark,
      },
      fromJson: (dynamic json) {
        if (json is num) return json.toInt();
        if (json is Map) {
          final rid = json['reservationid'] ?? json['reservationId'];
          if (rid is num) return rid.toInt();
          if (rid is String) return int.tryParse(rid) ?? 0;
        }
        return 0;
      },
    );
  }

  @override
  Future<ApiResponse<List<ReservationRecordItem>>> getMyReservationList({required int reservationListType, int pageIndex = 1, int pageSize = 20}) async {
    return apiClient.post<List<ReservationRecordItem>>(
      '/api/sys/app/getmyreservationlist',
      data: <String, dynamic>{'reservationlisttype': reservationListType, 'pageindex': pageIndex, 'pagesize': pageSize},
      fromJson: (dynamic json) {
        final source = json as Map<String, dynamic>? ?? const <String, dynamic>{};
        final listJson = source['list'] as List<dynamic>? ?? const <dynamic>[];
        return listJson.map((e) => ReservationRecordItem.fromJson(e as Map<String, dynamic>)).toList();
      },
    );
  }

  @override
  Future<ApiResponse<List<ShareCartTemplate>>> getShareCartTemplateList() async {
    return apiClient.post<List<ShareCartTemplate>>(
      '/api/groupMall/shareCart/gettemplatelist',
      data: <String, dynamic>{'biztype': 1},
      fromJson: (dynamic json) {
        final listJson = json['list'] as List<dynamic>? ?? [];
        return listJson.map((e) => ShareCartTemplate.fromJson(e as Map<String, dynamic>)).toList();
      },
    );
  }

  @override
  Future<ApiResponse<ShareCartTemplateDetail>> getShareCartTemplateDetail(int templateId) async {
    return apiClient.post<ShareCartTemplateDetail>(
      '/api/groupMall/shareCart/gettemplatedetail',
      data: <String, dynamic>{'templateid': templateId},
      fromJson: (dynamic json) => ShareCartTemplateDetail.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<int>> createShareCart(int templateId) async {
    final response = await apiClient.post<int>(
      '/api/groupMall/app/createsharecart',
      data: <String, dynamic>{'templateid': templateId},
      fromJson: (dynamic json) {
        if (json is num) return json.toInt();
        if (json is Map) {
          final shareCartId = json['sharecartid'] ?? json['shareCartId'];
          if (shareCartId is num) return shareCartId.toInt();
          if (shareCartId is String) return int.tryParse(shareCartId) ?? 0;
        }
        return 0;
      },
    );
    return response;
  }

  @override
  Future<ApiResponse<ShareCartProductList>> getShareCartProductList(int shareCartId) async {
    return apiClient.post<ShareCartProductList>(
      '/api/groupMall/shareCart/getsharecartproductlist',
      data: <String, dynamic>{'sharecartid': shareCartId, 'listtype': 1},
      fromJson: (dynamic json) => ShareCartProductList.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<CandidateProductList>> getCandidateProductList(int shareCartId, int pageIndex, int pageSize) async {
    return apiClient.post<CandidateProductList>(
      '/api/groupMall/shareCart/getcondidateproductlist',
      data: <String, dynamic>{'sharecartid': shareCartId, 'pageindex': pageIndex, 'pagesize': pageSize},
      fromJson: (dynamic json) => CandidateProductList.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<ShareCartProductList>> addProductToShareCart(int shareCartId, int pid, int newCount) async {
    return apiClient.post<ShareCartProductList>(
      '/api/groupMall/shareCart/addproducttosharecart',
      data: <String, dynamic>{'sharecartid': shareCartId, 'pid': pid, 'newcount': newCount, 'increment': false},
      fromJson: (dynamic json) => ShareCartProductList.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<ServiceSubmitOrderResult>> submitGroupOrder(int shareCartId, int addressId) async {
    return apiClient.post<ServiceSubmitOrderResult>(
      '/api/groupMall/order/submitgrouporder',
      data: <String, dynamic>{'sharecartid': shareCartId, 'addressid': addressId},
      fromJson: (dynamic json) => ServiceSubmitOrderResult.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<List<OfflineActivityItem>>> getOfflineActivityList({required bool typdsfriends, int pageIndex = 1, int pageSize = 20}) async {
    return apiClient.post<List<OfflineActivityItem>>(
      '/api/promotion/app/activity/getofflineactivitylist',
      data: <String, dynamic>{'typdsfriends': typdsfriends, 'authtoken': 0, 'pageindex': pageIndex, 'pagesize': pageSize},
      fromJson: (dynamic json) {
        final source = json as Map<String, dynamic>? ?? const <String, dynamic>{};
        final listJson = source['activitylist'] as List<dynamic>? ?? const <dynamic>[];
        return listJson.map((e) => OfflineActivityItem.fromJson(e as Map<String, dynamic>)).toList();
      },
    );
  }

  @override
  Future<ApiResponse<OfflineActivityDetail>> getOfflineActivityDetail(String activityId) async {
    return apiClient.post<OfflineActivityDetail>(
      '/api/promotion/app/activity/getofflineactivitydetail',
      data: <String, dynamic>{'activityid': activityId, 'authtoken': 0},
      fromJson: (dynamic json) {
        final source = json as Map<String, dynamic>? ?? const <String, dynamic>{};
        return OfflineActivityDetail.fromJson(source);
      },
    );
  }

  @override
  Future<ApiResponse<int>> signupOfflineActivity({
    required String activityId,
    required String username,
    required String phone,
    String idNo = '',
    String remark = '',
    int signupUserCount = 1,
  }) async {
    return apiClient.post<int>(
      '/api/promotion/app/activity/signupofflineactivity',
      data: <String, dynamic>{
        'activityid': activityId,
        'username': username,
        'phone': phone,
        'idno': idNo,
        'remark': remark,
        'signupusercount': signupUserCount
      },
      fromJson: (dynamic json) => 0,
    );
  }
}

final serviceRemoteDataSourceProvider = Provider<ServiceRemoteDataSource>((ref) {
  return ServiceRemoteDataSource(apiClient: ref.read(apiClientProvider));
});

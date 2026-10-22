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
import '../../domain/models/reservation_service_item.dart';

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
}

final serviceRemoteDataSourceProvider = Provider<ServiceRemoteDataSource>((ref) {
  return ServiceRemoteDataSource(apiClient: ref.read(apiClientProvider));
});

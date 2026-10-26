import '../../../../core/network/api_response.dart';
import '../models/offline_activity_item.dart';
import '../models/offline_activity_detail_model.dart';
import '../models/reservation_service_item.dart';
import '../models/reservation_service_detail_model.dart';
import '../models/reservation_record_item.dart';
import '../models/share_cart_template_model.dart';
import '../models/share_cart_template_detail_model.dart';
import '../models/share_cart_product_model.dart';
import '../models/share_cart_candidate_model.dart';
import '../models/service_submit_order_model.dart';

/// 服务中心仓库接口
abstract class ServiceRepository {
  /// 获取服务预约列表
  Future<ApiResponse<List<ReservationServiceItem>>> getReservationServiceList();

  /// 获取预约服务详情（服务中心 - 服务预约 tab 详情页）
  /// 请求：{serviceid: serviceId}，authtoken 由拦截器自动注入
  /// 响应：detail / myreservationinfo / calendar
  Future<ApiResponse<ReservationServiceDetail>> getReservationServiceDetail(int serviceId);

  /// 提交预约报名
  /// 请求：{serviceid, contactname, contactphonenumber, reservationdatetime, idno, usercount, remark}
  /// 响应：reservationid
  Future<ApiResponse<int>> submitReservation({
    required int serviceId,
    required String contactName,
    required String contactPhoneNumber,
    required String reservationDateTime,
    required String idNo,
    required int userCount,
    required String remark,
  });

  /// 获取我的预约/报名记录列表（分页）
  /// 请求：{reservationlisttype: 0|1|2, pageindex: int, pagesize: int}
  /// reservationlisttype: 0=全部, 1=已预约, 2=已完成
  Future<ApiResponse<List<ReservationRecordItem>>> getMyReservationList({required int reservationListType, int pageIndex = 1, int pageSize = 20});

  /// 获取购酒享服务模板列表
  Future<ApiResponse<List<ShareCartTemplate>>> getShareCartTemplateList();

  /// 获取购酒享服务模板详情
  Future<ApiResponse<ShareCartTemplateDetail>> getShareCartTemplateDetail(int templateId);

  /// 创建权益购物车（当 cartId 为空时调用）
  /// 请求 body：{templateid: templateId}
  /// 响应：{sharecartid: int}
  Future<ApiResponse<int>> createShareCart(int templateId);

  /// 获取购物车中的商品列表
  /// 请求 body：{sharecartid: shareCartId, listtype: 1}
  Future<ApiResponse<ShareCartProductList>> getShareCartProductList(int shareCartId);

  /// 获取继续加购候选商品列表（支持分页）
  /// 请求 body：{sharecartid: shareCartId, pageindex: pageIndex, pagesize: pageSize}
  Future<ApiResponse<CandidateProductList>> getCandidateProductList(int shareCartId, int pageIndex, int pageSize);

  /// 向权益购物车添加/修改商品数量
  /// 请求 body：{sharecartid: shareCartId, pid: pid, newcount: newCount, increment: false}
  /// 响应包含 cansubmit / verifymsg
  Future<ApiResponse<ShareCartProductList>> addProductToShareCart(int shareCartId, int pid, int newCount);

  /// 提交权益团购订单
  /// 请求 body：{sharecartid: int, addressid: int}
  /// 响应包含 cansubmit / verifymsg，成功后包含 orderId
  Future<ApiResponse<ServiceSubmitOrderResult>> submitGroupOrder(int shareCartId, int addressId);

  /// 获取线下活动列表（挚友会 / 活动报名共用）
  /// 请求：{typdsfriends: bool, authtoken: 0, pageindex: int, pagesize: int}
  /// typdsfriends=true 查询挚友会活动，false 查询其他活动
  /// 响应：{activitylist: [...], result: 0, descr: null, datatag: ""}
  Future<ApiResponse<List<OfflineActivityItem>>> getOfflineActivityList({required bool typdsfriends, int pageIndex = 1, int pageSize = 20});

  /// Get offline activity detail
  /// POST /api/promotion/app/activity/getofflineactivitydetail
  Future<ApiResponse<OfflineActivityDetail>> getOfflineActivityDetail(String activityId);
}

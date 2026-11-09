import '../../../../core/network/api_response.dart';
import '../models/notification_models.dart';

/// 通知中心仓库接口
///
/// 后端接口（公共模块）：
///   - POST /api/common/app/getnotificationtypestat   通知类型统计（顶部类型入口）
///   - POST /api/common/app/getmynotificationlist     我的通知列表（按 type 过滤，分页）
///   - POST /api/common/app/marknotificationasread    标记通知已读
///
/// authtoken、meta 等公共字段由拦截器统一注入，调用点只需传业务参数。
abstract class NotificationRepository {
  /// 获取通知类型统计（顶部类型入口的 icon / typename / type / unreadcount）
  Future<ApiResponse<List<NotificationTypeStat>>> getTypeStats();

  /// 获取我的通知列表
  ///
  /// [typeValue] 为接口下发的原始 type 数值（来自类型统计的 type 字段）；
  /// null 表示全部类型（接口约定 null 或 -1 表示全部）。
  /// [pageIndex] 从 1 开始，[pageSize] 不传时后端默认 10。
  Future<ApiResponse<List<NotificationMessage>>> getMessages({int? typeValue, int pageIndex = 1, int pageSize = 20});

  /// 标记通知已读
  ///
  /// [notificationId] 指定则只标记该条；为 null 时按 [typeValue] 标记该类型全部通知。
  /// 返回成功标记行数（0 表示没有通知被标记，不作为错误处理）。
  Future<ApiResponse<int>> markAsRead({int? notificationId, int? typeValue});
}

# Flutter Logging Skill

## 1. Skill 目标

为 Flutter 中大型商业 App 建立统一、可维护、可扩展的日志体系。

当前项目采用：

```text
Talker
+
AppLogger
+
LogContext / TraceId
+
LogSanitizer
+
Dio Logging
+
Local Log Buffer
+
Remote Batch Upload
```

不使用 Sentry，不引入第三方 Crash SaaS。

核心目标：

1. 全项目统一日志入口。
2. 禁止业务代码直接使用 `print`、`debugPrint`、`developer.log`。
3. 支持 Debug / Release 不同日志策略。
4. 日志结构化。
5. 支持 TraceId。
6. 支持 Dio 网络日志。
7. 支持 Flutter 全局异常捕获。
8. 支持日志敏感信息脱敏。
9. 支持本地缓存。
10. 支持离线补传。
11. 支持批量远程上传。
12. 日志系统异常不能影响 App 正常运行。
13. 支持订单、支付、直播、秒杀等关键业务问题排查。

---

# 2. 技术选型

默认采用：

```yaml
dependencies:
  talker_flutter:
  talker_dio_logger:
  dio:
  path_provider:
```

安装时优先使用：

```bash
flutter pub add talker_flutter
flutter pub add talker_dio_logger
flutter pub add dio
flutter pub add path_provider
```

具体版本必须根据当前 Flutter / Dart SDK 选择兼容的稳定版本。

不要固定本 Skill 中的版本号。

如果项目中已经存在功能相同的依赖，优先复用，不要重复引入。

---

# 3. 总体架构

```text
Flutter App
│
├── AppLogger
│
├── Talker
│   ├── debug
│   ├── info
│   ├── warning
│   ├── error
│   └── critical
│
├── LogContext
│   ├── traceId
│   ├── sessionId
│   ├── userId
│   ├── deviceId
│   ├── appVersion
│   ├── buildNumber
│   ├── platform
│   ├── osVersion
│   └── screen
│
├── LogSanitizer
│
├── Dio Logging Interceptor
│
├── LogBuffer
│   ├── Memory Queue
│   └── Local Persistence
│
└── RemoteLogUploader
    └── Batch Upload
```

统一数据流：

```text
业务代码
   ↓
AppLogger
   ↓
LogEntry
   ↓
LogSanitizer
   ↓
Talker
   ├── Debug Console
   └── Remote Buffer
           ↓
      Batch Upload
           ↓
      自建日志 API
```

---

# 4. 统一日志入口

整个项目只允许：

```dart
AppLogger.debug(...)
AppLogger.info(...)
AppLogger.warning(...)
AppLogger.error(...)
AppLogger.critical(...)
```

业务代码禁止直接：

```dart
print(...)
debugPrint(...)
developer.log(...)
```

业务层也禁止直接创建：

```dart
Talker(...)
```

Talker 只能在日志基础设施内部使用。

---

# 5. 推荐目录

建议：

```text
lib/
└── core/
    └── logging/
        ├── app_logger.dart
        ├── log_entry.dart
        ├── log_level.dart
        ├── log_context.dart
        ├── log_sanitizer.dart
        ├── log_buffer.dart
        ├── remote_log_uploader.dart
        ├── talker_logger.dart
        ├── logging_initializer.dart
        └── interceptors/
            └── logging_interceptor.dart
```

如果当前项目已有：

```text
core/observability
core/infrastructure
core/monitoring
```

等合理目录，可以复用。

不要为了日志再建立重复的基础设施目录。

---

# 6. 日志等级

统一：

```text
debug
info
warning
error
critical
```

## debug

用于开发调试。

例如：

```text
页面初始化
Provider 状态变化
缓存命中
本地数据转换
```

Debug 日志默认只本地输出，不上传生产服务器。

---

## info

正常业务运行信息。

例如：

```text
用户登录成功
商品详情加载成功
加入购物车
订单创建成功
支付成功
```

关键业务事件可以上传。

---

## warning

异常但可恢复。

例如：

```text
缓存不存在
接口响应过慢
图片加载失败后降级
Token 即将过期
接口返回非预期数据但可继续运行
```

Release 建议上传。

---

## error

业务失败或技术异常。

例如：

```text
API 请求失败
JSON 解析失败
订单创建失败
支付失败
本地数据异常
```

Release 必须上传。

---

## critical

严重异常。

例如：

```text
核心初始化失败
关键流程无法继续
全局未捕获异常
严重状态异常
```

Release 必须上传。

---

# 7. AppLogger API

建议 API：

```dart
AppLogger.debug(
  '商品详情页面初始化',
  module: 'product',
  event: 'product_detail_init',
);

AppLogger.info(
  '创建订单成功',
  module: 'order',
  event: 'order_create_success',
  data: {
    'orderId': orderId,
  },
);

AppLogger.warning(
  '缓存不存在，使用网络数据',
  module: 'product',
  event: 'cache_miss',
);

AppLogger.error(
  '创建订单失败',
  module: 'order',
  event: 'order_create_failed',
  error: error,
  stackTrace: stackTrace,
);

AppLogger.critical(
  '核心模块初始化失败',
  module: 'app',
  event: 'module_init_failed',
  error: error,
  stackTrace: stackTrace,
);
```

统一支持：

```text
message
module
event
data
error
stackTrace
```

---

# 8. 结构化日志

不要把所有数据拼接到 message 中。

不推荐：

```dart
AppLogger.info(
  '创建订单成功 orderId=$orderId productId=$productId',
);
```

推荐：

```dart
AppLogger.info(
  '创建订单成功',
  module: 'order',
  event: 'order_create_success',
  data: {
    'orderId': orderId,
    'productId': productId,
  },
);
```

最终日志应可以转换为 JSON：

```json
{
  "timestamp": "2026-08-31T10:00:00Z",
  "level": "info",
  "module": "order",
  "event": "order_create_success",
  "message": "创建订单成功",
  "traceId": "abc123",
  "sessionId": "session123",
  "userId": "10001",
  "appVersion": "2.0.0",
  "buildNumber": "200",
  "platform": "android",
  "osVersion": "16",
  "data": {
    "orderId": "202608310001",
    "productId": 10001
  }
}
```

---

# 9. LogEntry

所有日志最终统一转换为：

```text
LogEntry
```

建议字段：

```text
timestamp
level
module
event
message
traceId
sessionId
userId
deviceId
appVersion
buildNumber
platform
osVersion
networkType
screen
durationMs
error
stackTrace
data
```

不是所有日志都需要填充全部字段。

日志模型必须可序列化。

---

# 10. TraceId

项目必须支持 TraceId。

TraceId 用来关联一次完整业务链路：

```text
用户操作
↓
页面
↓
Controller / ViewModel
↓
Repository
↓
Dio
↓
API
```

例如：

```text
traceId=abc123

点击立即购买
↓
buy_click

创建订单
↓
order_create

POST /api/order/create
↓
http_request

接口成功
↓
order_create_success

支付
↓
payment_start

支付成功
↓
payment_success
```

---

# 11. TraceId 规则

没有 TraceId 时自动创建。

已有 TraceId 必须优先复用。

禁止每个方法重新生成 TraceId。

Dio 请求推荐加入：

```http
X-Trace-Id: abc123
```

如果后端已经实现 TraceId：

1. 客户端生成 TraceId。
2. 写入请求头。
3. 服务端继续使用同一个 TraceId。
4. 服务端响应中的 TraceId 如有需要可以更新本地上下文。

目标：

```text
Flutter traceId
=
API traceId
=
服务端日志 traceId
```

---

# 12. LogContext

统一维护：

```text
traceId
sessionId
userId
deviceId
appVersion
buildNumber
platform
osVersion
networkType
screen
```

用户未登录：

```text
userId = null
```

登录以后：

```text
userId = 当前用户 ID
```

退出登录必须清理：

```text
userId
```

不能出现用户 A 退出后，用户 B 登录但日志仍带用户 A 的 userId。

---

# 13. SessionId

App 启动后建立一个 sessionId。

例如：

```text
App Start
↓
sessionId=xxx
```

直到 App 会话结束。

SessionId 用于分析：

```text
某一次 App 启动期间
发生了什么
```

SessionId 不得包含用户密码、Token 等敏感数据。

---

# 14. 敏感数据脱敏

所有日志必须经过：

```text
LogSanitizer
```

才能：

```text
输出
缓存
上传
```

禁止直接记录：

```text
password
验证码
accessToken
refreshToken
Authorization
Cookie
secret
sign
signature
银行卡完整号码
身份证完整号码
支付敏感参数
私钥
密钥
```

推荐敏感字段至少覆盖：

```text
password
pwd
token
accessToken
refreshToken
authorization
cookie
secret
sign
signature
idCard
identityCard
bankCard
cardNo
phone
mobile
email
```

---

# 15. 脱敏示例

手机号：

```text
13812345678
```

变成：

```text
138****5678
```

Authorization：

```text
Bearer abcdef
```

变成：

```text
***
```

Token：

```text
eyJhbGciOi...
```

变成：

```text
***
```

身份证：

```text
110101199001011234
```

原则上直接：

```text
***
```

支付敏感参数：

```text
***
```

---

# 16. JSON 递归脱敏

对于：

```dart
Map<String, dynamic>
```

必须支持递归脱敏。

例如：

```json
{
  "username": "bob",
  "phone": "13812345678",
  "token": "abcdef",
  "profile": {
    "idCard": "110101199001011234",
    "nickname": "Bob"
  }
}
```

转换：

```json
{
  "username": "bob",
  "phone": "138****5678",
  "token": "***",
  "profile": {
    "idCard": "***",
    "nickname": "Bob"
  }
}
```

禁止因为调试方便而原样打印整个请求对象。

---

# 17. Dio 网络日志

Dio 必须接入统一日志体系。

网络日志至少记录：

```text
method
url
traceId
status
durationMs
businessCode
exception
```

请求：

```text
HTTP START
traceId=abc123
POST /api/order/create
```

成功：

```text
HTTP SUCCESS
traceId=abc123
POST /api/order/create
status=200
duration=326ms
```

失败：

```text
HTTP ERROR
traceId=abc123
POST /api/order/create
status=500
duration=826ms
```

---

# 18. Request / Response Body

Debug 环境可以有限输出：

```text
query
request body
response body
```

但必须经过：

```text
LogSanitizer
```

并限制最大长度。

不能把超大响应完整写入日志。

超出长度：

```text
<TRUNCATED>
```

---

# 19. Release 网络日志

Release 默认不上传完整 response body。

只保留：

```text
method
url
status
durationMs
traceId
businessCode
error
```

例如：

```json
{
  "module": "network",
  "event": "http_error",
  "level": "error",
  "traceId": "abc123",
  "method": "POST",
  "url": "/api/order/create",
  "status": 500,
  "durationMs": 826
}
```

---

# 20. HTTP 200 不代表业务成功

必须区分：

```text
HTTP Success
```

与：

```text
Business Success
```

例如：

```text
HTTP 200
businessCode = 5001
```

仍然属于业务失败。

日志应该：

```text
network:
http_success

order:
order_create_failed
```

不能只看到 HTTP 200 就认为业务成功。

---

# 21. 全局异常捕获

项目必须建立 Flutter 全局异常捕获。

至少处理：

```dart
FlutterError.onError
```

以及：

```dart
PlatformDispatcher.instance.onError
```

未捕获异常必须进入：

```text
AppLogger.critical(...)
```

例如：

```dart
FlutterError.onError = (details) {
  AppLogger.critical(
    'Flutter 未捕获异常',
    module: 'app',
    event: 'flutter_uncaught_error',
    error: details.exception,
    stackTrace: details.stack,
  );
};
```

注意：

日志处理失败不能反过来导致 App Crash。

---

# 22. Error 日志必须包含 StackTrace

错误日志推荐：

```dart
try {
  await repository.createOrder();
} catch (error, stackTrace) {
  AppLogger.error(
    '创建订单失败',
    module: 'order',
    event: 'order_create_failed',
    error: error,
    stackTrace: stackTrace,
  );

  rethrow;
}
```

禁止：

```dart
catch (e) {
  AppLogger.error(
    '创建订单失败',
  );
}
```

除非没有 stackTrace 可用。

---

# 23. 日志上传

禁止每条日志单独请求服务端。

错误：

```text
log
↓
POST
log
↓
POST
log
↓
POST
```

正确：

```text
AppLogger
↓
Memory Queue
↓
达到数量 / 定时
↓
Batch Upload
↓
Remote API
```

建议默认：

```text
批量：20~50 条
定时：10~30 秒
```

具体参数可以根据实际运行情况调整。

---

# 24. Remote Log API

建议预留：

```http
POST /api/app-log/batch
```

请求：

```json
{
  "appVersion": "2.0.0",
  "buildNumber": "200",
  "platform": "android",
  "logs": [
    {
      "timestamp": "2026-08-31T10:00:00Z",
      "level": "error",
      "module": "order",
      "event": "order_create_failed",
      "traceId": "abc123",
      "data": {}
    }
  ]
}
```

服务端后续至少能够按：

```text
traceId
userId
sessionId
orderId
event
module
level
timestamp
appVersion
deviceId
```

查询。

---

# 25. RemoteLogUploader

职责：

```text
从 Buffer 获取日志
↓
批量序列化
↓
发送服务端
↓
成功删除
↓
失败保留
```

日志上传失败：

```text
不能影响业务
```

不能阻塞：

```text
登录
下单
支付
购物车
直播
秒杀
```

---

# 26. 本地缓存

必须支持远程上传失败后的本地保存。

流程：

```text
Memory Queue
↓
Remote Upload
↓
失败
↓
Local Persistence
```

App 下次启动：

```text
读取未上传日志
↓
重新 Batch Upload
```

---

# 27. 本地缓存限制

默认建议：

```text
最大容量：10 MB
```

同时支持：

```text
最大日志条数
最大保存时间
```

超过限制：

```text
删除最旧日志
```

不能无限增长。

---

# 28. Retry

日志上传失败不得无限重试。

建议：

```text
第一次失败
↓
10 秒

第二次失败
↓
30 秒

第三次失败
↓
60 秒
```

之后进入本地持久化队列，等待：

```text
下一次 App 启动
```

或：

```text
网络恢复
```

禁止：

```dart
while (true) {
  uploadLogs();
}
```

---

# 29. 网络状态

日志系统应该尽可能感知网络状态。

无网络：

```text
不进行无意义的远程请求
```

网络恢复：

```text
触发 Batch Upload
```

日志系统本身不能因为网络异常不断消耗流量。

---

# 30. Debug / Release 策略

推荐：

```text
                    Debug       Release

debug               本地        关闭
info                本地        部分关键事件
warning             本地        上传
error               本地        上传
critical            本地        上传
```

Release 不上传大量 debug 日志。

---

# 31. 关键业务事件

当前项目属于电商 App，至少应该覆盖：

```text
app_launch
app_update

login_start
login_success
login_failed
logout

product_view
product_favorite
product_add_cart

checkout_start

order_create
order_create_success
order_create_failed

payment_start
payment_success
payment_failed
payment_cancel

refund_start
refund_success
refund_failed

coupon_receive
coupon_use

flash_sale_enter
flash_sale_submit
flash_sale_success
flash_sale_failed

live_room_enter
live_room_exit
live_stream_error
live_product_click
live_buy_click

address_select
address_create
address_update

after_sale_create
after_sale_success
```

只记录关键业务状态变化。

---

# 32. 订单日志

订单是最高优先级业务之一。

重点：

```text
order_create_start
order_create_success
order_create_failed

order_cancel
order_cancel_success
order_cancel_failed

order_detail_view

order_confirm

order_submit
```

推荐数据：

```text
orderId
productId
activityId
traceId
durationMs
businessCode
```

不要记录不必要的大对象。

---

# 33. 支付日志

支付日志必须重点记录：

```text
payment_start
payment_parameter_ready
payment_sdk_start
payment_success
payment_failed
payment_cancel
```

建议记录：

```text
orderId
paymentType
durationMs
resultCode
traceId
```

禁止记录：

```text
支付签名
支付密钥
Token
私钥
完整敏感支付参数
```

---

# 34. 秒杀日志

至少：

```text
flash_sale_enter
flash_sale_product_view
flash_sale_submit
flash_sale_success
flash_sale_failed
flash_sale_timeout
```

记录：

```text
activityId
productId
traceId
durationMs
resultCode
```

禁止高频日志。

例如：

```text
10
9
8
7
6
...
```

不能每秒上传。

---

# 35. 直播日志

直播属于高频场景。

记录：

```text
live_room_enter
live_room_exit
live_stream_error
live_product_click
live_buy_click
```

不要记录：

```text
视频每一帧
每次心跳
每条弹幕
每次 UI 刷新
每次倒计时
```

---

# 36. State Management 日志

如果使用 Riverpod：

可以接入：

```text
ProviderObserver
```

如果使用 BLoC：

可以接入：

```text
BlocObserver
```

重点记录：

```text
状态异常
关键状态转换
```

不要把整个大 State 每次变化完整上传。

---

# 37. Repository 日志

关键 Repository 方法应该记录：

```text
开始
成功
失败
```

特别是：

```text
createOrder
cancelOrder
payOrder
refundOrder
submitAfterSale
```

普通纯查询方法不需要过度打印。

---

# 38. 页面日志

重要页面可以记录：

```dart
AppLogger.info(
  '进入商品详情',
  module: 'product',
  event: 'product_detail_enter',
  data: {
    'productId': productId,
  },
);
```

不要为了统计页面浏览而让日志系统产生大量重复数据。

---

# 39. 性能要求

日志系统必须是非阻塞的。

禁止在 UI 线程执行大量：

```text
JSON 序列化
文件 IO
网络 IO
```

日志处理应该尽可能：

```text
异步
批量
低开销
```

日志系统异常不得影响：

```text
UI
网络
登录
订单
支付
直播
```

---

# 40. Logger 生命周期

整个 App 只允许一个统一 Logger。

推荐：

```dart
AppLogger.instance
```

或者项目现有 DI 容器中的单例。

禁止：

```text
ProductLogger
OrderLogger
PaymentLogger
LiveLogger
```

分别创建完全独立的 Logger。

模块通过：

```text
module
event
```

进行分类。

---

# 41. Environment

至少区分：

```text
development
staging
production
```

支持：

```text
LOG_ENABLE
LOG_LEVEL
REMOTE_LOG_ENABLE
REMOTE_LOG_ENDPOINT
```

Development：

```text
debug = 开
console = 开
network debug = 开
remote log = 可选
```

Production：

```text
debug = 关闭
关键 info = 按策略
warning = 开
error = 开
critical = 开
remote log = 开
```

---

# 42. 日志 API 认证

生产环境日志上传必须使用：

```text
HTTPS
```

日志 API 如需要认证：

```text
使用专用认证机制
```

不要为了方便把用户 Token 当作日志系统安全凭证。

更不能把日志 API Token 写进普通日志。

---

# 43. Logger 自身容错

日志系统失败：

```text
不能影响业务
```

例如：

```dart
try {
  await remoteLogUploader.upload();
} catch (_) {
  // 日志系统异常不得影响业务流程。
}
```

本地磁盘满：

```text
放弃缓存
```

不能：

```text
抛异常导致 App Crash
```

网络上传失败：

```text
进入本地队列
```

不能：

```text
阻塞业务请求
```

---

# 44. 删除用户上下文

用户退出登录时：

```text
userId
user-related context
```

必须清理。

SessionId 是否重建，由项目登录模型决定。

绝对禁止：

```text
用户 A
↓
Logout
↓
用户 B
↓
日志仍然带 A 的 userId
```

---

# 45. 数据最小化原则

日志不是数据库。

不要为了“以后可能有用”把整个对象塞进去。

例如不推荐：

```dart
data: {
  'entireProductObject': product,
}
```

推荐：

```dart
data: {
  'productId': product.id,
  'productType': product.type,
}
```

只记录排查问题真正需要的数据。

---

# 46. 代码生成规则

Codex 新增或修改 Flutter 代码时：

1. 优先检查已有 AppLogger。
2. 不得新增第二套日志框架。
3. 禁止 `print`。
4. 禁止 `debugPrint`。
5. 禁止业务层直接使用 `Talker`。
6. 禁止绕过 `LogSanitizer`。
7. Dio 必须接入统一日志拦截器。
8. 错误日志优先保留 `stackTrace`。
9. 关键业务必须使用结构化事件。
10. 日志上传必须异步。
11. 日志失败不能影响业务。
12. Release 必须限制日志量。
13. 订单、支付、直播、秒杀必须重点记录。
14. 优先复用现有实现，不重复造轮子。
15. 不得为了日志修改业务行为。

---

# 47. 新增模块时的日志检查

Codex 完成一个新业务模块以后，应主动检查：

```text
[ ] 是否存在关键业务事件？
[ ] 是否存在异常分支？
[ ] 是否记录 error + stackTrace？
[ ] 是否能够通过 traceId 串起来？
[ ] 是否涉及敏感数据？
[ ] 是否经过 LogSanitizer？
[ ] 是否可能产生大量高频日志？
[ ] Release 环境日志量是否合理？
```

---

# 48. 测试要求

必须测试：

## AppLogger

```text
debug
info
warning
error
critical
```

## TraceId

```text
自动生成
上下文传递
Dio 传递
退出登录清理
```

## Sanitizer

```text
password
token
authorization
phone
email
idCard
bankCard
signature
```

## Dio

```text
200
400
401
403
404
429
500
timeout
network error
```

## Batch

```text
空队列
1 条
20 条
50 条
超限
```

## Local Buffer

```text
写入
读取
删除
过期
容量超限
```

## Retry

```text
第一次失败
第二次失败
第三次失败
网络恢复
```

## Global Exception

```text
FlutterError
PlatformDispatcher
```

---

# 49. Definition of Done

任何新增业务模块完成以后：

```text
[ ] 没有 print
[ ] 没有 debugPrint
[ ] 没有业务层 developer.log
[ ] 使用 AppLogger
[ ] 关键业务有 event
[ ] Error 有 stackTrace
[ ] TraceId 可追踪
[ ] Dio 使用统一日志拦截
[ ] 敏感信息经过脱敏
[ ] Release 不上传大量 Debug 日志
[ ] 日志上传非阻塞
[ ] 日志上传失败不会导致 App 异常
[ ] 本地日志大小受限制
```

---

# 50. 推荐使用方式

普通日志：

```dart
AppLogger.info(
  '商品详情加载成功',
  module: 'product',
  event: 'product_detail_load_success',
  data: {
    'productId': productId,
  },
);
```

异常：

```dart
try {
  final result = await orderRepository.createOrder(request);

  AppLogger.info(
    '创建订单成功',
    module: 'order',
    event: 'order_create_success',
    data: {
      'orderId': result.orderId,
    },
  );

  return result;
} catch (error, stackTrace) {
  AppLogger.error(
    '创建订单失败',
    module: 'order',
    event: 'order_create_failed',
    error: error,
    stackTrace: stackTrace,
  );

  rethrow;
}
```

网络请求由统一 Dio Interceptor 自动记录：

```text
http_start
http_success
http_error
```

并自动关联：

```text
traceId
appVersion
platform
```

---

# 51. 最终架构原则

整个项目只认：

```text
AppLogger
```

日志模型只认：

```text
LogEntry
```

上下文只认：

```text
LogContext
```

敏感信息只通过：

```text
LogSanitizer
```

网络日志统一：

```text
Dio Logging Interceptor
```

远程日志统一：

```text
RemoteLogUploader
```

缓存统一：

```text
LogBuffer
```

整个日志体系不依赖 Sentry 或其他第三方 Crash SaaS。

最终目标：

```text
用户反馈：
“刚才下单失败了”

↓ 查询 userId / orderId / traceId

找到：

order_create_start
        ↓
http_start
        ↓
http_error
        ↓
order_create_failed

↓
定位 API
↓
定位业务错误
↓
定位 App 版本
↓
定位设备
↓
定位具体业务链路
```

日志体系必须服务于问题排查，而不是单纯增加日志数量。

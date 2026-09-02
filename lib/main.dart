import 'app/bootstrap.dart';

/// 应用入口函数
/// 
/// 采用异步初始化方式，确保在应用渲染前完成必要的环境准备工作。
/// 这里调用 bootstrap() 进行核心组件和服务的初始化。
void main() async {
  await bootstrap();
}

import 'package:flutter/material.dart';
import '../../../../core/widgets/app_empty.dart';

class ServicePage extends StatelessWidget {
  const ServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: AppEmpty(message: '服务预约内容开发中，敬请期待')),
    );
  }
}

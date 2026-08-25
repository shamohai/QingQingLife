import 'package:flutter/material.dart';
import '../../../../core/widgets/app_empty.dart';

class ProductDetailPage extends StatelessWidget {
  final String productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('商品详情')),
      body: AppEmpty(message: '商品详情页开发中，敬请期待'),
    );
  }
}
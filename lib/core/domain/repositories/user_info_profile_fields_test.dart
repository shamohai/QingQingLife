import 'package:flutter_test/flutter_test.dart';
import 'package:qingqinglife/core/domain/repositories/auth_repository.dart';

void main() {
  group('UserInfo 解析 getmyprofile 新增字段', () {
    test('gender / gendername / birthday 取自 baseprofile，address 取自顶层', () {
      final user = UserInfo.fromJson(const <String, dynamic>{
        'baseprofile': <String, dynamic>{
          'nickname': '锐',
          'avatar': 'https://static.crm.qkj.com.cn/avatar.jpg',
          'mobile': '13641005224',
          'paycredit': 50656,
          'gender': 2,
          'gendername': '女',
          'birthday': '1997-10-01 00:00:00',
        },
        'rankinfo': <String, dynamic>{'userrid': 10, 'userridname': '普通会员'},
        'address': '北京市北京市丰台区1123111',
      });

      expect(user.gender, 2);
      expect(user.genderName, '女');
      expect(user.birthday, DateTime(1997, 10, 1));
      expect(user.address, '北京市北京市丰台区1123111');
    });

    test('未完善资料时 gender 为 0、birthday 与 address 为空', () {
      final user = UserInfo.fromJson(const <String, dynamic>{
        'baseprofile': <String, dynamic>{'nickname': '未登录', 'gender': 0, 'gendername': '未知', 'birthday': null},
        'address': '',
      });

      expect(user.gender, 0);
      expect(user.genderName, '未知');
      expect(user.birthday, isNull);
      expect(user.address, isNull);
    });
  });
}

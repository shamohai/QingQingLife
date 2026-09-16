---
name: flutter-storage
description: 青轻生活馆本地存储、登录态和缓存规范。
---

# Storage

## 1. Token

Token 必须使用安全存储。

禁止：

- 明文文件
- 普通缓存
- SharedPreferences 保存敏感 Token

优先：

flutter_secure_storage

---

# 2. 本地数据

可以缓存：

- 用户基本信息
- App 配置
- 搜索历史
- 最近浏览
- 首页缓存
- 商品缓存
- 非敏感设置

---

# 3. Cache

缓存必须设置：

- key
- version
- expiration

禁止无限缓存。

---

# 4. Logout

退出登录必须清理：

- Token
- 用户信息
- 用户私有缓存
- 用户相关 Provider 状态

但不得误删：

- App 公共配置
- 公共商品缓存
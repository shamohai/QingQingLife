---
name: ecommerce-components
description: 青轻生活馆电商核心业务组件规范。
---

# 电商组件

## 商品

统一：

ProductCard
ProductGrid
ProductList
ProductDetail
SkuSelector
ProductPrice

---

# 购物车

统一：

CartPage
CartItem
CartSummary
CouponSelector
PointsDeduction
ShippingFee

---

# 订单

统一：

OrderList
OrderCard
OrderDetail
OrderStatus
OrderTimeline

订单状态：

- 待付款
- 待发货
- 待收货
- 待评价
- 已完成
- 售后

---

# 地址

统一：

AddressList
AddressCard
AddressEdit
AddressSelector

---

# 优惠券

统一：

CouponCard
CouponList
CouponSelector

支持：

- 可用
- 不可用
- 已使用
- 已过期

---

# 积分

统一：

PointsBalance
PointsTransaction
PointsRule
PointsMall
PointsProduct

---

# 会员

统一：

MemberLevel
MemberBenefits
MemberPrivilege

---

# 服务

统一：

ServiceCard
ServiceList
ServiceDetail
BookingPage
BookingResult

---

# 金额

所有金额：

禁止使用 double 做核心业务计算。

优先使用：

Decimal / int 分

金额必须统一精度。

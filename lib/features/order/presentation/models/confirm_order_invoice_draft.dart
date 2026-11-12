/// 确认订单页发票信息草稿：发票信息页保存后返回给确认订单页。
typedef MallConfirmOrderInvoiceDraft = ({
  String? invoiceType,
  String title,
  String taxId,
  String? registrationAddress,
  String phone,
  String bank,
  String bankAccount,
  bool isCompany,
});

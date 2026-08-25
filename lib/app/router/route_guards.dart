/// 判断当前路由是否需要登录（供路由器守卫使用）
bool requireLogin(String path) {
  // 当前所有主 Tab 为公开路由，后续按需添加保护规则
  const publicRoutes = ['/home', '/shop', '/service', '/points', '/profile'];
  return !publicRoutes.any((r) => path.startsWith(r));
}
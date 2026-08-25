/// 运行环境枚举
enum Env {
  dev,
  staging,
  prod,
}

/// 当前运行环境（可通过启动参数或环境变量切换）
abstract final class EnvConfig {
  static Env get current => _current;
  static Env _current = Env.prod;

  static void set(Env env) => _current = env;

  /// 是否为开发环境
  static bool get isDev => _current == Env.dev;

  /// 是否为生产环境
  static bool get isProd => _current == Env.prod;
}

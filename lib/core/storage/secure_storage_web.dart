import 'package:web/web.dart' as web;

String? getLocalStorageItem(String key) {
  return web.window.localStorage.getItem(key);
}

void setLocalStorageItem(String key, String value) {
  web.window.localStorage.setItem(key, value);
}

void removeLocalStorageItem(String key) {
  web.window.localStorage.removeItem(key);
}

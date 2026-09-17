import 'package:get_storage/get_storage.dart';

class LocalStorageService {
  final GetStorage _box = GetStorage();
  static const String _firstTimeKey = 'is_first_time';
  static const String _themeKey = 'is_dark_mode';
  static const String _isLoggedInKey = 'is_logged_in';


  static Future<void> init() async {
    await GetStorage.init();
  }

  // ---------- First Time ----------
  bool isFirstTime() {
    return _box.read(_firstTimeKey) ?? true;
  }

  void setNotFirstTime() {
    _box.write(_firstTimeKey, false);
  }

  // ---------- Theme Mode ----------
  bool? isDarkMode() {
    return _box.read<bool>(_themeKey);
  }

  void setDarkMode(bool isDark) {
    _box.write(_themeKey, isDark);
  }

  // ---------- Auth Status ----------
  bool isLoggedIn() {
    return _box.read(_isLoggedInKey) ?? false;
  }

  void setLoggedIn(bool isLoggedIn) {
    _box.write(_isLoggedInKey, isLoggedIn);
  }
  GetStorage get box => _box;
}

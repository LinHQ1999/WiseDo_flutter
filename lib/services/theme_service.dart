import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import 'preference_service.dart';

/// 主题服务类
/// 
/// 负责管理应用主题的切换，包括暗黑模式切换等
class ThemeService {
  // 单例实例
  static final ThemeService instance = ThemeService._internal();
  
  // 偏好设置服务实例
  final PreferenceService _preferenceService = PreferenceService.instance;
  
  // 主题模式变更控制器
  final _themeModeController = StreamController<ThemeMode>.broadcast();
  
  // 主题数据变更控制器
  final _themeDataController = StreamController<ThemeData>.broadcast();
  
  // 提供主题模式变更的流
  Stream<ThemeMode> get themeModeStream => _themeModeController.stream;
  
  // 提供主题数据变更的流
  Stream<ThemeData> get themeDataStream => _themeDataController.stream;
  
  // 当前主题模式
  ThemeMode _themeMode = ThemeMode.system;
  
  // 当前亮色主题
  late ThemeData _lightTheme;
  
  // 当前暗色主题
  late ThemeData _darkTheme;
  
  // 是否初始化完成的标志
  bool _initialized = false;
  
  // 私有构造函数，确保单例模式
  ThemeService._internal() {
    _lightTheme = AppTheme.lightTheme();
    _darkTheme = AppTheme.darkTheme();
    
    // 监听偏好设置变更
    _preferenceService.preferencesStream.listen((_) {
      _updateThemeFromPreferences();
    });
  }
  
  /// 初始化服务
  Future<void> init() async {
    if (_initialized) return;
    
    try {
      await _preferenceService.init();
      await _updateThemeFromPreferences();
      
      _initialized = true;
      debugPrint('主题服务初始化完成');
    } catch (e) {
      debugPrint('初始化主题服务失败: $e');
    }
  }
  
  /// 从偏好设置更新主题
  Future<void> _updateThemeFromPreferences() async {
    // 获取暗黑模式设置
    final isDarkMode = _preferenceService.isDarkMode;
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    
    // 更新并发布主题
    _lightTheme = AppTheme.lightTheme();
    _darkTheme = AppTheme.darkTheme();
    
    // 发布主题数据更新
    _themeDataController.add(isDarkMode ? _darkTheme : _lightTheme);
    
    // 发布主题模式更新
    _themeModeController.add(_themeMode);
    
    debugPrint('主题已更新: isDarkMode=$isDarkMode');
  }
  
  /// 获取当前主题模式
  ThemeMode get themeMode => _themeMode;
  
  /// 获取当前亮色主题
  ThemeData get lightTheme => _lightTheme;
  
  /// 获取当前暗色主题
  ThemeData get darkTheme => _darkTheme;
  
  /// 获取当前主题
  ThemeData get currentTheme => _themeMode == ThemeMode.dark ? _darkTheme : _lightTheme;
  
  /// 切换暗黑模式
  Future<bool> toggleDarkMode() async {
    final newValue = !_preferenceService.isDarkMode;
    return await setDarkMode(newValue);
  }
  
  /// 设置暗黑模式
  Future<bool> setDarkMode(bool isDarkMode) async {
    final result = await _preferenceService.setDarkMode(isDarkMode);
    if (result) {
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
      _themeModeController.add(_themeMode);
      _themeDataController.add(isDarkMode ? _darkTheme : _lightTheme);
    }
    return result;
  }
  
  /// 关闭服务，释放资源
  void dispose() {
    _themeModeController.close();
    _themeDataController.close();
    debugPrint('主题服务已关闭');
  }
} 
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'task_service.dart';
import 'preference_service.dart';
import 'theme_service.dart';

/// 服务定位器类
/// 
/// 使用GetIt包提供对服务的全局访问点，
/// 使得依赖注入更加简单和统一
class ServiceLocator {
  // GetIt实例
  static final _getIt = GetIt.instance;
  
  // 是否已初始化标志
  static bool _initialized = false;
  
  /// 初始化所有服务
  static Future<void> init() async {
    if (_initialized) return;
    
    try {
      // 注册偏好设置服务
      _getIt.registerSingleton<PreferenceService>(PreferenceService.instance);
      await PreferenceService.instance.init();
      
      // 注册主题服务
      _getIt.registerSingleton<ThemeService>(ThemeService.instance);
      await ThemeService.instance.init();
      
      // 注册任务服务
      _getIt.registerSingleton<TaskService>(TaskService.instance);
      await TaskService.instance.init();
      
      _initialized = true;
      debugPrint('服务定位器初始化完成');
    } catch (e) {
      debugPrint('初始化服务定位器失败: $e');
      rethrow;
    }
  }
  
  /// 获取偏好设置服务
  static PreferenceService get preferenceService => _getIt<PreferenceService>();
  
  /// 获取主题服务
  static ThemeService get themeService => _getIt<ThemeService>();
  
  /// 获取任务服务
  static TaskService get taskService => _getIt<TaskService>();
} 
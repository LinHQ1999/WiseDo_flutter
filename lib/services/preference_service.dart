import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../database/database_helper.dart';

/// 偏好设置类型枚举
enum PreferenceType {
  string,
  bool,
  int,
  double,
  json,
}

/// 偏好设置键名枚举
class PreferenceKeys {
  // 主题相关
  static const String darkMode = 'darkMode';
  
  // 语言相关
  static const String language = 'language';
  
  // 通知相关
  static const String notificationsEnabled = 'notificationsEnabled';
  static const String reminderTime = 'reminderTime';
  
  // 其他设置
  static const String showCompletedTasks = 'showCompletedTasks';
  static const String autoDeleteCompleted = 'autoDeleteCompleted';
  static const String defaultView = 'defaultView';
  static const String lastSyncTime = 'lastSyncTime';
}

/// 偏好设置服务类
class PreferenceService {
  // 单例实例
  static final PreferenceService instance = PreferenceService._internal();
  
  // 数据库辅助类实例
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  
  // 缓存的偏好设置
  final Map<String, dynamic> _preferences = {};
  
  // 偏好设置变更控制器
  final _preferencesStreamController = StreamController<Map<String, dynamic>>.broadcast();
  
  // 提供偏好设置变更的流
  Stream<Map<String, dynamic>> get preferencesStream => _preferencesStreamController.stream;
  
  // 是否初始化完成的标志
  bool _initialized = false;
  
  // 偏好设置类型映射
  final Map<String, PreferenceType> _preferenceTypes = {
    PreferenceKeys.darkMode: PreferenceType.bool,
    PreferenceKeys.language: PreferenceType.string,
    PreferenceKeys.notificationsEnabled: PreferenceType.bool,
    PreferenceKeys.reminderTime: PreferenceType.string,
    PreferenceKeys.showCompletedTasks: PreferenceType.bool,
    PreferenceKeys.autoDeleteCompleted: PreferenceType.bool,
    PreferenceKeys.defaultView: PreferenceType.string,
    PreferenceKeys.lastSyncTime: PreferenceType.string,
  };
  
  // 默认偏好设置值
  final Map<String, dynamic> _defaultPreferences = {
    PreferenceKeys.darkMode: false,
    PreferenceKeys.language: 'zh',
    PreferenceKeys.notificationsEnabled: true,
    PreferenceKeys.reminderTime: '08:00',
    PreferenceKeys.showCompletedTasks: true,
    PreferenceKeys.autoDeleteCompleted: false,
    PreferenceKeys.defaultView: 'quadrant',
    PreferenceKeys.lastSyncTime: '',
  };
  
  // 私有构造函数，确保单例模式
  PreferenceService._internal();
  
  /// 初始化服务
  Future<void> init() async {
    if (_initialized) return;
    
    try {
      // 从数据库加载所有偏好设置
      final Map<String, String> storedPrefs = await _dbHelper.getAllPreferences();
      
      // 处理每个偏好设置，根据类型转换为正确的数据类型
      storedPrefs.forEach((key, value) {
        final type = _preferenceTypes[key] ?? PreferenceType.string;
        _preferences[key] = _parsePreferenceValue(value, type);
      });
      
      // 检查是否有缺失的默认值，如果有则添加
      _defaultPreferences.forEach((key, defaultValue) {
        if (!_preferences.containsKey(key)) {
          _preferences[key] = defaultValue;
          _savePreference(key, defaultValue); // 保存到数据库
        }
      });
      
      _initialized = true;
      
      // 发布初始偏好设置
      _preferencesStreamController.add(Map.unmodifiable(_preferences));
      
      debugPrint('偏好设置服务初始化完成');
    } catch (e) {
      debugPrint('初始化偏好设置服务失败: $e');
      
      // 发布默认偏好设置
      _preferences.addAll(_defaultPreferences);
      _preferencesStreamController.add(Map.unmodifiable(_preferences));
    }
  }
  
  /// 获取偏好设置值
  T? get<T>(String key) {
    if (!_initialized) {
      debugPrint('警告：偏好设置服务尚未初始化');
    }
    
    // 如果偏好设置中不存在，则返回默认值
    if (!_preferences.containsKey(key) && _defaultPreferences.containsKey(key)) {
      return _defaultPreferences[key] as T?;
    }
    
    return _preferences[key] as T?;
  }
  
  /// 设置偏好设置值
  Future<bool> set<T>(String key, T value) async {
    try {
      if (!_initialized) {
        await init();
      }
      
      // 相同值不重复设置
      if (_preferences.containsKey(key) && _preferences[key] == value) {
        return true;
      }
      
      // 更新内存中的偏好设置
      _preferences[key] = value;
      
      // 保存到数据库
      await _savePreference(key, value);
      
      // 发布更新
      _preferencesStreamController.add(Map.unmodifiable(_preferences));
      
      debugPrint('偏好设置已更新: $key = $value');
      return true;
    } catch (e) {
      debugPrint('设置偏好失败: $e');
      return false;
    }
  }
  
  /// 保存偏好设置到数据库
  Future<void> _savePreference(String key, dynamic value) async {
    final stringValue = _stringifyPreferenceValue(value);
    await _dbHelper.setPreference(key, stringValue);
  }
  
  /// 将偏好设置值转换为字符串
  String _stringifyPreferenceValue(dynamic value) {
    if (value == null) return '';
    
    if (value is bool) {
      return value ? '1' : '0';
    } else if (value is Map || value is List) {
      return json.encode(value);
    } else {
      return value.toString();
    }
  }
  
  /// 解析偏好设置字符串值
  dynamic _parsePreferenceValue(String value, PreferenceType type) {
    switch (type) {
      case PreferenceType.bool:
        return value == '1' || value.toLowerCase() == 'true';
      case PreferenceType.int:
        return int.tryParse(value) ?? 0;
      case PreferenceType.double:
        return double.tryParse(value) ?? 0.0;
      case PreferenceType.json:
        try {
          return value.isNotEmpty ? json.decode(value) : null;
        } catch (_) {
          return null;
        }
      case PreferenceType.string:
      default:
        return value;
    }
  }
  
  /// 删除偏好设置
  Future<bool> remove(String key) async {
    try {
      if (!_initialized) {
        await init();
      }
      
      // 如果偏好设置中不存在，则直接返回成功
      if (!_preferences.containsKey(key)) {
        return true;
      }
      
      // 从内存中删除
      _preferences.remove(key);
      
      // 从数据库中删除
      await _dbHelper.deletePreference(key);
      
      // 发布更新
      _preferencesStreamController.add(Map.unmodifiable(_preferences));
      
      debugPrint('偏好设置已删除: $key');
      return true;
    } catch (e) {
      debugPrint('删除偏好失败: $e');
      return false;
    }
  }
  
  /// 重置所有偏好设置为默认值
  Future<bool> resetToDefaults() async {
    try {
      // 清空内存中的偏好设置
      _preferences.clear();
      
      // 添加默认值
      _preferences.addAll(_defaultPreferences);
      
      // 保存到数据库
      for (final entry in _defaultPreferences.entries) {
        await _savePreference(entry.key, entry.value);
      }
      
      // 发布更新
      _preferencesStreamController.add(Map.unmodifiable(_preferences));
      
      debugPrint('所有偏好设置已重置为默认值');
      return true;
    } catch (e) {
      debugPrint('重置偏好设置失败: $e');
      return false;
    }
  }
  
  /// 获取暗黑模式状态
  bool get isDarkMode => get<bool>(PreferenceKeys.darkMode) ?? false;
  
  /// 设置暗黑模式状态
  Future<bool> setDarkMode(bool value) => set(PreferenceKeys.darkMode, value);
  
  /// 获取应用语言
  String get language => get<String>(PreferenceKeys.language) ?? 'zh';
  
  /// 设置应用语言
  Future<bool> setLanguage(String value) => set(PreferenceKeys.language, value);
  
  /// 获取通知启用状态
  bool get notificationsEnabled => get<bool>(PreferenceKeys.notificationsEnabled) ?? true;
  
  /// 设置通知启用状态
  Future<bool> setNotificationsEnabled(bool value) => set(PreferenceKeys.notificationsEnabled, value);
  
  /// 关闭服务，释放资源
  void dispose() {
    _preferencesStreamController.close();
    debugPrint('偏好设置服务已关闭');
  }
} 
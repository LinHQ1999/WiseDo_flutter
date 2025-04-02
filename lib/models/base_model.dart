/// 所有模型类的基础抽象类
abstract class BaseModel {
  /// 将模型转换为Map
  Map<String, dynamic> toMap();
  
  /// 创建模型的副本
  BaseModel copyWith();
  
  /// 比较两个模型是否相等
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BaseModel && runtimeType == other.runtimeType;
  }
  
  @override
  int get hashCode => 0; // 子类需要重写以提供适当的哈希码
  
  /// 将模型转换为易读的字符串形式
  @override
  String toString() => 'BaseModel';
}

/// 数据库实体的标识接口
abstract class DatabaseEntity {
  /// 数据库ID
  int? get id;
}

/// 字符串转布尔值的工具方法 (用于数据库中的布尔值转换)
bool dbBoolFromInt(dynamic value) {
  if (value == null) return false;
  if (value is bool) return value;
  if (value is int) return value == 1;
  if (value is String) return value == '1' || value.toLowerCase() == 'true';
  return false;
}

/// 布尔值转整数的工具方法 (用于数据库中的布尔值存储)
int dbBoolToInt(bool value) {
  return value ? 1 : 0;
}

/// 时间戳转DateTime的工具方法
DateTime? dbTimestampToDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  if (value is String) {
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }
  return null;
}

/// DateTime转时间戳的工具方法
String? dbDateTimeToTimestamp(DateTime? value) {
  if (value == null) return null;
  return value.toIso8601String();
} 
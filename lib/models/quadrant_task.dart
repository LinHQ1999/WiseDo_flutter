import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../models/base_model.dart';

/// 象限类型枚举
enum QuadrantType {
  /// 重要且紧急
  importantUrgent,
  /// 重要不紧急
  importantNotUrgent,
  /// 紧急不重要
  urgentNotImportant,
  /// 不重要不紧急
  notImportantNotUrgent,
}

/// 象限类型扩展方法
extension QuadrantTypeExtension on QuadrantType {
  /// 获取象限的显示名称
  String getDisplayName(BuildContext context) {
    // 需要根据本地化获取文本，这里是示例
    switch (this) {
      case QuadrantType.importantUrgent:
        return '重要且紧急';
      case QuadrantType.importantNotUrgent:
        return '重要不紧急';
      case QuadrantType.urgentNotImportant:
        return '紧急不重要';
      case QuadrantType.notImportantNotUrgent:
        return '不重要不紧急';
    }
  }
  
  /// 获取象限的建议行动
  String getActionSuggestion(BuildContext context) {
    // 需要根据本地化获取文本，这里是示例
    switch (this) {
      case QuadrantType.importantUrgent:
        return '立即处理';
      case QuadrantType.importantNotUrgent:
        return '计划处理';
      case QuadrantType.urgentNotImportant:
        return '委托他人';
      case QuadrantType.notImportantNotUrgent:
        return '考虑删除';
    }
  }
  
  /// 获取象限颜色
  Color getColor(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    
    switch (this) {
      case QuadrantType.importantUrgent:
        return isDark ? AppColors.importantUrgentDark : AppColors.importantUrgentLight;
      case QuadrantType.importantNotUrgent:
        return isDark ? AppColors.importantNotUrgentDark : AppColors.importantNotUrgentLight;
      case QuadrantType.urgentNotImportant:
        return isDark ? AppColors.urgentNotImportantDark : AppColors.urgentNotImportantLight;
      case QuadrantType.notImportantNotUrgent:
        return isDark ? AppColors.notImportantNotUrgentDark : AppColors.notImportantNotUrgentLight;
    }
  }
  
  /// 获取象限图标
  IconData getIcon() {
    switch (this) {
      case QuadrantType.importantUrgent:
        return Icons.error_outline; // 重要且紧急
      case QuadrantType.importantNotUrgent:
        return Icons.star; // 重要不紧急
      case QuadrantType.urgentNotImportant:
        return Icons.flash_on; // 紧急不重要
      case QuadrantType.notImportantNotUrgent:
        return Icons.remove_circle_outline; // 不重要不紧急
    }
  }
}

/// 四象限任务模型类
class QuadrantTask extends BaseModel {
  /// 任务ID (与数据库中的id对应)
  final String id;
  
  /// 任务标题
  final String title;
  
  /// 截止日期/时间描述
  final String? deadline;
  
  /// 象限类型
  final QuadrantType quadrantType;
  
  /// 是否已完成
  final bool isCompleted;
  
  /// 创建时间
  final DateTime? createdAt;
  
  /// 更新时间
  final DateTime? updatedAt;
  
  /// 构造函数
  QuadrantTask({
    required this.id,
    required this.title,
    this.deadline,
    required this.quadrantType,
    this.isCompleted = false,
    this.createdAt,
    this.updatedAt,
  });
  
  /// 复制并修改任务
  @override
  QuadrantTask copyWith({
    String? id,
    String? title,
    String? deadline,
    QuadrantType? quadrantType,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return QuadrantTask(
      id: id ?? this.id,
      title: title ?? this.title,
      deadline: deadline ?? this.deadline,
      quadrantType: quadrantType ?? this.quadrantType,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  /// 将模型转换为Map
  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'deadline': deadline,
      'quadrantType': quadrantType.index,
      'isCompleted': dbBoolToInt(isCompleted),
      'createdAt': dbDateTimeToTimestamp(createdAt),
      'updatedAt': dbDateTimeToTimestamp(updatedAt),
    };
  }
  
  /// 从Map创建QuadrantTask
  factory QuadrantTask.fromMap(Map<String, dynamic> map) {
    return QuadrantTask(
      id: map['id'].toString(),
      title: map['title'] as String,
      deadline: map['deadline'] as String?,
      quadrantType: QuadrantType.values[map['quadrantType'] as int],
      isCompleted: dbBoolFromInt(map['isCompleted']),
      createdAt: dbTimestampToDateTime(map['createdAt']),
      updatedAt: dbTimestampToDateTime(map['updatedAt']),
    );
  }
  
  /// 比较两个QuadrantTask是否相等
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is QuadrantTask &&
      other.id == id &&
      other.title == title &&
      other.deadline == deadline &&
      other.quadrantType == quadrantType &&
      other.isCompleted == isCompleted &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;
  }
  
  /// 获取QuadrantTask的哈希码
  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      deadline,
      quadrantType,
      isCompleted,
      createdAt,
      updatedAt,
    );
  }
  
  /// 将QuadrantTask转换为易读的字符串
  @override
  String toString() {
    return 'QuadrantTask(id: $id, title: $title, quadrantType: $quadrantType, isCompleted: $isCompleted)';
  }
  
  /// 获取象限颜色 (兼容旧代码)
  static Color getQuadrantColor(QuadrantType type) {
    final brightness = MediaQueryData.fromView(WidgetsBinding.instance.platformDispatcher.views.first).platformBrightness;
    return type.getColor(brightness);
  }
  
  /// 获取象限图标 (兼容旧代码)
  static IconData getQuadrantIcon(QuadrantType type) {
    return type.getIcon();
  }
} 

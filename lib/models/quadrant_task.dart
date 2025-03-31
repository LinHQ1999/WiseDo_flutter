import 'package:flutter/material.dart';

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

/// 四象限任务模型类
class QuadrantTask {
  /// 任务ID
  final String id;
  
  /// 任务标题
  final String title;
  
  /// 截止日期/时间描述
  final String? deadline;
  
  /// 象限类型
  final QuadrantType quadrantType;
  
  /// 是否已完成
  bool isCompleted;
  
  /// 构造函数
  QuadrantTask({
    required this.id,
    required this.title,
    this.deadline,
    required this.quadrantType,
    this.isCompleted = false,
  });
  
  /// 复制并修改任务
  QuadrantTask copyWith({
    String? id,
    String? title,
    String? deadline,
    QuadrantType? quadrantType,
    bool? isCompleted,
  }) {
    return QuadrantTask(
      id: id ?? this.id,
      title: title ?? this.title,
      deadline: deadline ?? this.deadline,
      quadrantType: quadrantType ?? this.quadrantType,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
  
  /// 获取象限颜色
  static Color getQuadrantColor(QuadrantType type) {
    // 获取当前环境的亮度模式
    final brightness = MediaQueryData.fromWindow(WidgetsBinding.instance.window).platformBrightness;
    final isDark = brightness == Brightness.dark;
    
    switch (type) {
      case QuadrantType.importantUrgent:
        return isDark ? const Color(0xFFE57373) : const Color(0xFFFF5252); // 红色
      case QuadrantType.importantNotUrgent:
        return isDark ? const Color(0xFF64B5F6) : const Color(0xFF2196F3); // 蓝色
      case QuadrantType.urgentNotImportant:
        return isDark ? const Color(0xFFFFB74D) : const Color(0xFFFF9800); // 橙黄色
      case QuadrantType.notImportantNotUrgent:
        return isDark ? const Color(0xFF81C784) : const Color(0xFF4CAF50); // 绿色
    }
  }
  
  /// 获取象限图标
  static IconData getQuadrantIcon(QuadrantType type) {
    switch (type) {
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
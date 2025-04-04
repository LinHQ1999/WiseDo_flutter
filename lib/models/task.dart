import '../models/base_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// 任务状态枚举
enum TaskStatus {
  /// 待完成
  pending,
  /// 已完成
  completed,
  /// 过期
  expired,
  /// 已删除
  deleted,
}

/// 任务类型枚举
enum TaskType {
  /// 邮件
  email,
  /// 会议
  meeting,
  /// 报告
  report,
  /// 电话
  call,
  /// 学习
  study,
  /// 普通任务
  regular,
}

/// 任务分类
enum TaskCategory {
  /// 工作类
  work,
  /// 生活类
  life,
  /// 学习类
  study,
  /// 健康类
  health,
  /// 社交类
  social,
  /// 其他类
  other,
}

/// 任务类型扩展
extension TaskTypeExtension on TaskType {
  /// 获取任务类型的图标
  IconData get icon {
    switch (this) {
      case TaskType.email:
        return CupertinoIcons.envelope_fill;
      case TaskType.meeting:
        return CupertinoIcons.person_2_fill;
      case TaskType.report:
        return CupertinoIcons.doc_text_fill;
      case TaskType.call:
        return CupertinoIcons.phone_fill;
      case TaskType.study:
        return CupertinoIcons.book_fill;
      case TaskType.regular:
        return CupertinoIcons.checkmark_circle_fill;
    }
  }
  
  /// 获取任务类型的显示名称
  String get displayName {
    switch (this) {
      case TaskType.email:
        return '邮件';
      case TaskType.meeting:
        return '会议';
      case TaskType.report:
        return '报告';
      case TaskType.call:
        return '电话';
      case TaskType.study:
        return '学习';
      case TaskType.regular:
        return '普通任务';
    }
  }
  
  /// 从字符串推断任务类型
  static TaskType fromTitle(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('邮件') || lowerTitle.contains('email')) {
      return TaskType.email;
    } else if (lowerTitle.contains('会议') || lowerTitle.contains('演示')) {
      return TaskType.meeting;
    } else if (lowerTitle.contains('报告') || lowerTitle.contains('总结')) {
      return TaskType.report;
    } else if (lowerTitle.contains('电话') || lowerTitle.contains('call')) {
      return TaskType.call;
    } else if (lowerTitle.contains('复习') || lowerTitle.contains('学习') || lowerTitle.contains('read')) {
      return TaskType.study;
    } else {
      return TaskType.regular;
    }
  }
}

/// 优先级枚举
enum PriorityLevel {
  /// 高优先级
  high,
  /// 中优先级
  medium,
  /// 低优先级
  low,
  /// 无优先级
  none,
}

/// 优先级扩展方法
extension PriorityLevelExtension on PriorityLevel {
  /// 获取优先级的显示文本
  String get displayName {
    switch (this) {
      case PriorityLevel.high:
        return '高优先级';
      case PriorityLevel.medium:
        return '中优先级';
      case PriorityLevel.low:
        return '低优先级';
      case PriorityLevel.none:
        return '无优先级';
    }
  }
  
  /// 从字符串转换为优先级枚举
  static PriorityLevel fromString(String? value) {
    if (value == null) return PriorityLevel.none;
    if (value.contains('高')) return PriorityLevel.high;
    if (value.contains('中')) return PriorityLevel.medium;
    if (value.contains('低')) return PriorityLevel.low;
    return PriorityLevel.none;
  }
}

/// 任务分类扩展
extension TaskCategoryExtension on TaskCategory {
  /// 获取分类的颜色
  Color get color {
    switch (this) {
      case TaskCategory.work:
        return Color(0xFF5E8CE4); // 蓝色
      case TaskCategory.life:
        return Color(0xFF66BB6A); // 绿色
      case TaskCategory.study:
        return Color(0xFFFFA726); // 橙色
      case TaskCategory.health:
        return Color(0xFFEF5350); // 红色
      case TaskCategory.social:
        return Color(0xFF8E44AD); // 紫色
      case TaskCategory.other:
        return Color(0xFF78909C); // 灰蓝色
    }
  }
  
  /// 获取分类的图标
  IconData get icon {
    switch (this) {
      case TaskCategory.work:
        return CupertinoIcons.briefcase_fill;
      case TaskCategory.life:
        return CupertinoIcons.house_fill;
      case TaskCategory.study:
        return CupertinoIcons.book_fill;
      case TaskCategory.health:
        return CupertinoIcons.heart_fill;
      case TaskCategory.social:
        return CupertinoIcons.person_2_fill;
      case TaskCategory.other:
        return CupertinoIcons.tag_fill;
    }
  }
  
  /// 获取分类名称
  String get displayName {
    // 获取当前上下文的本地化，如果没有上下文则使用默认的中文名称
    return getLocalizedName(null);
  }
  
  /// 获取本地化的分类名称
  String getLocalizedName(BuildContext? context) {
    final l10n = context != null ? AppLocalizations.of(context) : null;
    
    switch (this) {
      case TaskCategory.work:
        return l10n?.categoryWork ?? '工作';
      case TaskCategory.life:
        return l10n?.categoryLife ?? '生活';
      case TaskCategory.study:
        return l10n?.categoryStudy ?? '学习';
      case TaskCategory.health:
        return l10n?.categoryHealth ?? '健康';
      case TaskCategory.social:
        return l10n?.categorySocial ?? '社交';
      case TaskCategory.other:
        return l10n?.categoryOther ?? '其他';
    }
  }
  
  /// 从标题推断分类
  static TaskCategory fromTitle(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('工作') || lowerTitle.contains('报告') || 
        lowerTitle.contains('会议') || lowerTitle.contains('邮件') || 
        lowerTitle.contains('work') || lowerTitle.contains('report') || 
        lowerTitle.contains('meeting') || lowerTitle.contains('email')) {
      return TaskCategory.work;
    } else if (lowerTitle.contains('学习') || lowerTitle.contains('读书') || 
               lowerTitle.contains('复习') || lowerTitle.contains('课程') ||
               lowerTitle.contains('study') || lowerTitle.contains('book') || 
               lowerTitle.contains('review') || lowerTitle.contains('course')) {
      return TaskCategory.study;
    } else if (lowerTitle.contains('饮食') || lowerTitle.contains('运动') || 
               lowerTitle.contains('健康') || lowerTitle.contains('医疗') ||
               lowerTitle.contains('food') || lowerTitle.contains('exercise') || 
               lowerTitle.contains('health') || lowerTitle.contains('medical')) {
      return TaskCategory.health;
    } else if (lowerTitle.contains('朋友') || lowerTitle.contains('聚会') || 
               lowerTitle.contains('社交') || lowerTitle.contains('约会') ||
               lowerTitle.contains('friend') || lowerTitle.contains('party') || 
               lowerTitle.contains('social') || lowerTitle.contains('date')) {
      return TaskCategory.social;
    } else if (lowerTitle.contains('购物') || lowerTitle.contains('打扫') || 
               lowerTitle.contains('生活') || lowerTitle.contains('家庭') ||
               lowerTitle.contains('shopping') || lowerTitle.contains('clean') || 
               lowerTitle.contains('life') || lowerTitle.contains('home')) {
      return TaskCategory.life;
    } else {
      return TaskCategory.other;
    }
  }
}

/// 任务模型类
class Task extends BaseModel implements DatabaseEntity {
  /// 任务ID
  @override
  final int? id;
  
  /// 任务标题
  final String title;
  
  /// 任务时间（可选）
  final String? time;
  
  /// 截止日期（可选）
  final String? deadline;
  
  /// 提醒时间（可选）
  final String? reminderTime;
  
  /// 优先级说明（可选）
  final String? priority;
  
  /// 是否为高优先级
  final bool isPriority;
  
  /// 任务状态
  final TaskStatus status;
  
  /// 任务类型
  final TaskType? taskType;
  
  /// 任务分类
  final TaskCategory? category;
  
  /// 创建日期
  final String? createdAt;
  
  /// 最后更新日期
  final String? updatedAt;
  
  /// 任务是否已完成 (兼容旧代码)
  bool get isCompleted => status == TaskStatus.completed;
  
  /// 设置任务状态为已完成 (兼容旧代码)
  set isCompleted(bool value) {
    if (value && status != TaskStatus.completed) {
      copyWith(status: TaskStatus.completed);
    } else if (!value && status == TaskStatus.completed) {
      copyWith(status: TaskStatus.pending);
    }
  }
  
  /// 优先级枚举
  PriorityLevel get priorityLevel => PriorityLevelExtension.fromString(priority);
  
  /// 获取任务类型（如果未设置，则根据标题推断）
  TaskType get type => taskType ?? TaskTypeExtension.fromTitle(title);
  
  /// 获取任务分类（如果未设置，则根据标题推断）
  TaskCategory get taskCategory => category ?? TaskCategoryExtension.fromTitle(title);

  /// 构造函数
  Task({
    this.id,
    required this.title,
    this.time,
    this.deadline,
    this.reminderTime,
    this.priority,
    this.isPriority = false,
    this.taskType,
    this.category,
    this.createdAt,
    this.updatedAt,
    bool isCompleted = false,
    TaskStatus? status,
  }) : this.status = status ?? (isCompleted ? TaskStatus.completed : TaskStatus.pending);

  /// 转换为Map用于数据库存储
  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'time': time,
      'deadline': deadline,
      'reminderTime': reminderTime,
      'priority': priority,
      'isPriority': dbBoolToInt(isPriority),
      'isCompleted': dbBoolToInt(status == TaskStatus.completed),
      'status': status.index,
      'taskType': taskType?.index,
      'category': category?.index.toString(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// 从Map创建Task对象
  factory Task.fromMap(Map<String, dynamic> map) {
    final isCompleted = dbBoolFromInt(map['isCompleted']);
    
    // 如果有status字段则使用它，否则基于isCompleted来决定状态
    final statusIndex = map['status'] as int?;
    final status = statusIndex != null 
        ? TaskStatus.values[statusIndex]
        : (isCompleted ? TaskStatus.completed : TaskStatus.pending);
    
    // 解析任务类型
    final taskTypeIndex = map['taskType'] as int?;
    final taskType = taskTypeIndex != null 
        ? TaskType.values[taskTypeIndex]
        : null;
        
    // 解析任务分类 - 支持字符串和整数格式
    TaskCategory? category;
    final categoryValue = map['category'];
    if (categoryValue != null) {
      if (categoryValue is String && categoryValue.isNotEmpty) {
        // 尝试解析字符串格式的索引
        try {
          final index = int.parse(categoryValue);
          if (index >= 0 && index < TaskCategory.values.length) {
            category = TaskCategory.values[index];
          }
        } catch (e) {
          debugPrint('解析分类索引失败: $e');
        }
      } else if (categoryValue is int) {
        // 直接使用整数索引
        if (categoryValue >= 0 && categoryValue < TaskCategory.values.length) {
          category = TaskCategory.values[categoryValue];
        }
      }
    }
        
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      time: map['time'] as String?,
      deadline: map['deadline'] as String?,
      reminderTime: map['reminderTime'] as String?,
      priority: map['priority'] as String?,
      isPriority: dbBoolFromInt(map['isPriority']),
      taskType: taskType,
      category: category,
      status: status,
      createdAt: map['createdAt'] as String?,
      updatedAt: map['updatedAt'] as String?,
    );
  }

  /// 创建任务的副本并可选地修改某些属性
  @override
  Task copyWith({
    int? id,
    String? title,
    String? time,
    String? deadline,
    String? reminderTime,
    String? priority,
    bool? isPriority,
    TaskType? taskType,
    TaskCategory? category,
    TaskStatus? status,
    String? createdAt,
    String? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      time: time ?? this.time,
      deadline: deadline ?? this.deadline,
      reminderTime: reminderTime ?? this.reminderTime,
      priority: priority ?? this.priority,
      isPriority: isPriority ?? this.isPriority,
      taskType: taskType ?? this.taskType,
      category: category ?? this.category,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  /// 比较两个Task是否相等
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Task &&
      other.id == id &&
      other.title == title &&
      other.time == time &&
      other.deadline == deadline &&
      other.reminderTime == reminderTime &&
      other.priority == priority &&
      other.isPriority == isPriority &&
      other.taskType == taskType &&
      other.category == category &&
      other.status == status &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;
  }
  
  /// 获取Task的哈希码
  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      time,
      deadline,
      reminderTime,
      priority,
      isPriority,
      taskType,
      category,
      status,
      createdAt,
      updatedAt,
    );
  }
  
  /// 将Task转换为易读的字符串
  @override
  String toString() {
    return 'Task(id: $id, title: $title, category: $category, priority: $priority, status: $status)';
  }
}

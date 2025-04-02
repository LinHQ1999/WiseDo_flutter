import '../models/base_model.dart';

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

  /// 构造函数
  Task({
    this.id,
    required this.title,
    this.time,
    this.deadline,
    this.reminderTime,
    this.priority,
    this.isPriority = false,
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
        
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      time: map['time'] as String?,
      deadline: map['deadline'] as String?,
      reminderTime: map['reminderTime'] as String?,
      priority: map['priority'] as String?,
      isPriority: dbBoolFromInt(map['isPriority']),
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
      status,
      createdAt,
      updatedAt,
    );
  }
  
  /// 将Task转换为易读的字符串
  @override
  String toString() {
    return 'Task(id: $id, title: $title, priority: $priority, status: $status)';
  }
}

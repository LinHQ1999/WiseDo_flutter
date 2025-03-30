/// 任务模型类
class Task {
  /// 任务标题
  final String title;
  
  /// 任务时间（可选）
  final String? time;
  
  /// 截止日期（可选）
  final String? deadline;
  
  /// 优先级说明（可选）
  final String? priority;
  
  /// 是否为高优先级
  final bool isPriority;
  
  /// 任务是否已完成
  bool isCompleted;

  /// 构造函数
  Task({
    required this.title,
    this.time,
    this.deadline,
    this.priority,
    this.isPriority = false,
    this.isCompleted = false,
  });

  /// 创建任务的副本并可选地修改某些属性
  Task copyWith({
    String? title,
    String? time,
    String? deadline,
    String? priority,
    bool? isPriority,
    bool? isCompleted,
  }) {
    return Task(
      title: title ?? this.title,
      time: time ?? this.time,
      deadline: deadline ?? this.deadline,
      priority: priority ?? this.priority,
      isPriority: isPriority ?? this.isPriority,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
} 
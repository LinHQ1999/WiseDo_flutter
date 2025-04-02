import 'package:flutter/material.dart';
import '../models/task.dart';
import '../constants/app_theme.dart';

/// 任务项组件
class TaskItem extends StatelessWidget {
  /// 任务数据
  final Task task;
  
  /// 任务完成状态变更回调
  final Function(bool) onCompletionChanged;

  /// 构造函数
  const TaskItem({
    Key? key,
    required this.task,
    required this.onCompletionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: task.isCompleted,
            onChanged: (value) {
              onCompletionChanged(value ?? false);
            },
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 16,
                    color: task.isPriority ? AppColors.accentColor : AppColors.textPrimaryLight,
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (task.time != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        task.time!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
                if (task.deadline != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    task.deadline!,
                    style: TextStyle(
                      color: Colors.orange[800],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                if (task.priority != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    task.priority!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }
} 
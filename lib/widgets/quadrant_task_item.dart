import 'package:flutter/material.dart';
import '../models/quadrant_task.dart';

/// 四象限任务项组件
class QuadrantTaskItem extends StatelessWidget {
  /// 任务数据
  final QuadrantTask task;
  
  /// 任务完成状态变更回调
  final Function(bool) onCompletionChanged;

  /// 构造函数
  const QuadrantTaskItem({
    Key? key,
    required this.task,
    required this.onCompletionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 复选框
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: task.isCompleted,
              onChanged: (value) {
                onCompletionChanged(value ?? false);
              },
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0),
              ),
              side: BorderSide(
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                width: 1.5,
              ),
              activeColor: task.isCompleted 
                  ? isDark ? Colors.grey.shade700 : Colors.grey 
                  : QuadrantTask.getQuadrantColor(task.quadrantType),
            ),
          ),
          const SizedBox(width: 12),
          
          // 任务内容
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                    color: task.isCompleted 
                        ? theme.disabledColor 
                        : theme.textTheme.bodyLarge?.color,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                if (task.deadline != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    task.deadline!,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
} 
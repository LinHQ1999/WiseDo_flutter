import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/quadrant_task.dart';
import 'quadrant_task_item.dart';

/// 四象限区域组件
class QuadrantSection extends StatelessWidget {
  /// 象限类型
  final QuadrantType quadrantType;
  
  /// 象限标题
  final String title;
  
  /// 任务列表
  final List<QuadrantTask> tasks;
  
  /// 任务完成状态变更回调
  final Function(QuadrantTask, bool) onTaskCompletionChanged;
  
  /// 添加任务回调
  final VoidCallback onAddTask;

  /// 构造函数
  const QuadrantSection({
    Key? key,
    required this.quadrantType,
    required this.title,
    required this.tasks,
    required this.onTaskCompletionChanged,
    required this.onAddTask,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final color = QuadrantTask.getQuadrantColor(quadrantType);
    final icon = QuadrantTask.getQuadrantIcon(quadrantType);
    final quadrantTasks = tasks.where((task) => task.quadrantType == quadrantType).toList();
    
    final backgroundColor = isDark ? theme.cardColor : Colors.white;
    final borderColor = isDark ? Colors.grey[700] : Colors.grey[200];
    
    return Card(
      margin: const EdgeInsets.all(4.0),
      elevation: 2.0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      color: backgroundColor,
      child: Column(
        children: [
          // 象限标题栏
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: color,
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${quadrantTasks.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 任务列表
          Expanded(
            child: Container(
              color: backgroundColor,
              child: quadrantTasks.isEmpty
                  ? Center(
                      child: Text(
                        l10n.noTasks,
                        style: TextStyle(
                          color: theme.textTheme.bodySmall?.color,
                          fontSize: 12,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                      itemCount: quadrantTasks.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        thickness: 0.5,
                        color: borderColor,
                        indent: 8,
                        endIndent: 8,
                      ),
                      itemBuilder: (context, index) {
                        final task = quadrantTasks[index];
                        return QuadrantTaskItem(
                          task: task,
                          onCompletionChanged: (isCompleted) {
                            onTaskCompletionChanged(task, isCompleted);
                          },
                        );
                      },
                    ),
            ),
          ),
          
          // 添加按钮
          Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border(
                top: BorderSide(color: borderColor!, width: 0.5),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onAddTask,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add,
                          size: 16,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          l10n.addTask,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/quadrant_task.dart';
import 'quadrant_task_item.dart';

/// 四象限区域组件常量
class QuadrantSectionConstants {
  /// 标题栏内边距
  static const headerPadding = EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0);
  
  /// 图标大小
  static const iconSize = 16.0;
  
  /// 图标与文本间距
  static const iconTextSpacing = 8.0;
  
  /// 标题文本大小
  static const titleFontSize = 14.0;
  
  /// 卡片圆角
  static const cardBorderRadius = 12.0;
  
  /// 卡片边距
  static const cardMargin = EdgeInsets.all(4.0);
  
  /// 卡片阴影高度
  static const cardElevation = 2.0;
  
  /// 空任务提示文本大小
  static const emptyTextFontSize = 12.0;
}

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

  /// 构造函数
  const QuadrantSection({
    Key? key,
    required this.quadrantType,
    required this.title,
    required this.tasks,
    required this.onTaskCompletionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    
    // 过滤出当前象限的任务
    final quadrantTasks = _getQuadrantTasks();
    
    // 获取背景颜色（主要用于任务列表区域）
    final backgroundColor = isDark ? theme.cardColor : Colors.white;
    
    return Card(
      margin: QuadrantSectionConstants.cardMargin,
      elevation: QuadrantSectionConstants.cardElevation,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(QuadrantSectionConstants.cardBorderRadius),
      ),
      color: backgroundColor,
      child: Column(
        children: [
          // 象限标题栏
          _buildHeader(quadrantTasks.length),
          
          // 任务列表
          Expanded(
            child: _buildTaskList(context, theme, isDark, l10n, quadrantTasks),
          ),
        ],
      ),
    );
  }
  
  /// 获取当前象限的任务列表
  List<QuadrantTask> _getQuadrantTasks() {
    return tasks.where((task) => task.quadrantType == quadrantType).toList();
  }

  /// 构建象限标题栏
  Widget _buildHeader(int taskCount) {
    // 获取象限颜色和图标
    final color = QuadrantTask.getQuadrantColor(quadrantType);
    final icon = QuadrantTask.getQuadrantIcon(quadrantType);

    return Container(
      padding: QuadrantSectionConstants.headerPadding,
      decoration: BoxDecoration(
        color: color,
      ),
      child: Row(
        children: [
          // 象限图标
          Icon(
            icon, 
            color: Colors.white, 
            size: QuadrantSectionConstants.iconSize
          ),
          SizedBox(width: QuadrantSectionConstants.iconTextSpacing),
          
          // 象限标题
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: QuadrantSectionConstants.titleFontSize,
              ),
            ),
          ),
          
          // 任务数量标记
          _buildTaskCountBadge(taskCount),
        ],
      ),
    );
  }
  
  /// 构建任务数量标记
  Widget _buildTaskCountBadge(int taskCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$taskCount',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: QuadrantSectionConstants.titleFontSize,
        ),
      ),
    );
  }

  /// 构建任务列表区域
  Widget _buildTaskList(
    BuildContext context, 
    ThemeData theme, 
    bool isDark, 
    AppLocalizations l10n, 
    List<QuadrantTask> quadrantTasks
  ) {
    final backgroundColor = isDark ? theme.cardColor : Colors.white;
    final borderColor = isDark ? Colors.grey[700] : Colors.grey[200];

    // 若无任务，显示空状态；否则显示任务列表
    return Container(
      color: backgroundColor,
      child: quadrantTasks.isEmpty
          ? _buildEmptyState(theme, l10n)
          : _buildTaskListView(quadrantTasks, borderColor),
    );
  }
  
  /// 构建空状态提示
  Widget _buildEmptyState(ThemeData theme, AppLocalizations l10n) {
    return Center(
      child: Text(
        l10n.noTasks,
        style: TextStyle(
          color: theme.textTheme.bodySmall?.color,
          fontSize: QuadrantSectionConstants.emptyTextFontSize,
        ),
      ),
    );
  }
  
  /// 构建任务列表视图
  Widget _buildTaskListView(List<QuadrantTask> quadrantTasks, Color? borderColor) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount: quadrantTasks.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        thickness: 0.5,
        color: borderColor,
        indent: 12,
        endIndent: 12,
      ),
      itemBuilder: (context, index) => _buildTaskItem(quadrantTasks[index]),
    );
  }
  
  /// 构建单个任务项
  Widget _buildTaskItem(QuadrantTask task) {
    return QuadrantTaskItem(
      task: task,
      onCompletionChanged: (isCompleted) {
        onTaskCompletionChanged(task, isCompleted);
      },
    );
  }
} 
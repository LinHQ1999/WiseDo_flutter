import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/task.dart';
import '../widgets/header_widget.dart';
import '../widgets/section_card.dart';
import '../widgets/task_item.dart';

/// 首页屏幕
class HomeScreen extends StatefulWidget {
  /// 构造函数
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// 任务列表
  late List<Task> _tasks;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
  }
  
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initializeTasks();
      _initialized = true;
    }
  }

  /// 初始化任务列表（使用本地化字符串）
  void _initializeTasks() {
    final l10n = AppLocalizations.of(context)!;
    _tasks = [
      Task(
        title: l10n.taskTitlePrepareDemo,
        time: '14:00 - 公司会议室',
        priority: '高优先级',
        isPriority: true,
      ),
      Task(
        title: l10n.taskTitleReplyEmail,
        deadline: '今天截止',
        priority: '高优先级',
        isPriority: true,
      ),
      Task(
        title: '提交季度报告初稿',
        time: '16:00',
        priority: '中优先级',
      ),
    ];
  }
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // 确保任务已初始化
    if (!_initialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 主要内容区域
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // 头部信息
                HeaderWidget(
                  userName: '李明',
                  dateString: '2025年3月31日 星期一',
                ),
                const SizedBox(height: 24),
                
                // 天气信息卡片
                _buildWeatherCard(theme, isDark),
                const SizedBox(height: 24),
                
                // 优先建议部分
                _buildPrioritySection(l10n, theme, isDark),
                const SizedBox(height: 24),
                
                // 今日任务部分
                _buildTaskSection(l10n, theme, isDark),
                
                // 底部间距
                const SizedBox(height: 60),
              ]),
            ),
          ),
        ],
      ),
      // 添加新建任务的浮动按钮
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        backgroundColor: theme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  /// 构建天气卡片
  Widget _buildWeatherCard(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            Icons.wb_sunny,
            color: isDark ? Colors.amber[300] : Colors.blue[400],
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '今天多云转晴，18-24℃，建议穿着薄外套出门',
              style: TextStyle(
                fontSize: 16,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 显示添加任务对话框
  void _showAddTaskDialog() {
    // 暂时只是一个简单的提示，后续可以实现完整的添加任务功能
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.addNewTask),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// 创建优先建议部分
  Widget _buildPrioritySection(AppLocalizations l10n, ThemeData theme, bool isDark) {
    final priorityTasks = _tasks.where((task) => task.isPriority).toList();
    
    return Container(
      width: double.infinity, // 确保容器宽度填满
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C3E50) : const Color(0xFF4A7BF7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, // 使子元素横向拉伸
        children: [
          // 标题部分
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const Icon(
                  Icons.bolt,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.prioritySuggestion,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          
          // 任务列表
          for (int i = 0; i < priorityTasks.length; i++) 
            _buildPriorityTaskItem(priorityTasks[i], theme, isDark),
          
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  /// 构建优先任务项
  Widget _buildPriorityTaskItem(Task task, ThemeData theme, bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(16),
      width: double.infinity, // 确保宽度填满父容器
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF3E5064) : const Color(0xFF5F88F8),
        borderRadius: BorderRadius.circular(12),
      ),
      constraints: const BoxConstraints(minHeight: 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            task.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          if (task.time != null)
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 14,
                  color: Colors.white70,
                ),
                const SizedBox(width: 4),
                Text(
                  task.time!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          if (task.deadline != null)
            Text(
              task.deadline!,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
        ],
      ),
    );
  }

  /// 创建任务部分
  Widget _buildTaskSection(AppLocalizations l10n, ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题
        Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: theme.primaryColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              l10n.taskSectionTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.titleLarge?.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // 任务列表
        for (int i = 0; i < _tasks.length; i++)
          _buildTaskListItem(_tasks[i], i, theme, isDark),
      ],
    );
  }

  /// 构建任务列表项
  Widget _buildTaskListItem(Task task, int index, ThemeData theme, bool isDark) {
    final taskColor = isDark ? theme.cardColor : Colors.white;
    final borderColor = isDark ? Colors.grey[700] : Colors.grey.withOpacity(0.1);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: taskColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: borderColor!,
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 复选框
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.primaryColor,
                width: 2,
              ),
              color: task.isCompleted ? theme.primaryColor : Colors.transparent,
            ),
            child: InkWell(
              onTap: () {
                setState(() {
                  _tasks[index] = _tasks[index].copyWith(isCompleted: !task.isCompleted);
                });
              },
              child: task.isCompleted
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          
          // 任务内容
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                    color: task.isCompleted 
                        ? theme.disabledColor 
                        : theme.textTheme.bodyLarge?.color,
                  ),
                ),
                if (task.time != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    task.time!,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ],
                if (task.deadline != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    task.deadline!,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // 优先级标签
          if (task.priority != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _getPriorityColor(task.priority!, isDark),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                task.priority!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  /// 获取优先级颜色，根据深色模式调整亮度
  Color _getPriorityColor(String priority, bool isDark) {
    if (priority.contains('高')) {
      return isDark ? const Color(0xFFE57373) : Colors.red;
    } else if (priority.contains('中')) {
      return isDark ? const Color(0xFFFFB74D) : const Color(0xFFFF9800);
    } else {
      return isDark ? const Color(0xFF81C784) : Colors.green;
    }
  }
} 
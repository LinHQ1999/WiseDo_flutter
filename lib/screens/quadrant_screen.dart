import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../constants/app_theme.dart';
import '../database/database_helper.dart';
import '../models/task.dart';
import '../models/quadrant_task.dart';
import '../widgets/quadrant_section.dart';
import '../widgets/task_edit_dialog.dart';

/// 任务过滤器枚举
enum TaskFilter {
  /// 所有任务
  all,
  /// 今日任务
  today,
  /// 本周任务
  thisWeek,
}

/// 四象限屏幕
class QuadrantScreen extends StatefulWidget {
  /// 构造函数
  const QuadrantScreen({Key? key}) : super(key: key);

  @override
  State<QuadrantScreen> createState() => _QuadrantScreenState();
}

class _QuadrantScreenState extends State<QuadrantScreen> {
  /// 当前选中的任务过滤器
  TaskFilter _selectedFilter = TaskFilter.today;
  
  /// 所有任务列表
  List<QuadrantTask> _tasks = [];
  bool _isLoading = true;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  /// 从数据库加载任务
  Future<void> _loadTasks() async {
    try {
      final tasks = await _dbHelper.readAllTasks();
      final quadrantTasks = tasks.map((task) => QuadrantTask(
        id: task.id.toString(),
        title: task.title,
        deadline: task.deadline,
        quadrantType: _convertPriorityToQuadrant(task.priority, task.isPriority),
        isCompleted: task.isCompleted,
      )).toList();

      setState(() {
        _tasks = quadrantTasks;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('加载任务失败: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 将优先级转换为象限类型
  QuadrantType _convertPriorityToQuadrant(String? priority, bool isPriority) {
    if (priority == null) return QuadrantType.notImportantNotUrgent;
    if (priority.contains('高')) return QuadrantType.importantUrgent;
    if (isPriority) return QuadrantType.importantNotUrgent;
    if (priority.contains('中')) return QuadrantType.urgentNotImportant;
    return QuadrantType.notImportantNotUrgent;
  }

  /// 更新任务完成状态
  Future<void> _updateTaskCompletion(QuadrantTask task, bool isCompleted) async {
    final dbTask = Task(
      id: int.tryParse(task.id),
      title: task.title,
      deadline: task.deadline,
      isCompleted: isCompleted,
    );
    
    await _dbHelper.updateTask(dbTask);
    await _loadTasks();
  }

  /// 获取当前过滤后的任务列表
  List<QuadrantTask> get _filteredTasks {
    switch (_selectedFilter) {
      case TaskFilter.today:
        return _tasks.where((task) => 
          task.deadline?.contains('今天') == true || 
          task.deadline?.contains('Today') == true).toList();
      case TaskFilter.thisWeek:
        return _tasks.where((task) => 
          task.deadline?.contains('本周') == true || 
          task.deadline?.contains('Week') == true).toList();
      case TaskFilter.all:
      default:
        return _tasks;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Text(
              l10n.quadrantTaskManager,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 16.0),
            
            // 过滤器选项卡
            _buildFilterTabs(l10n, theme, isDark),
            const SizedBox(height: 16.0),
            
            // 四象限网格
            Expanded(
              child: _buildQuadrantGrid(l10n),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建过滤器选项卡
  Widget _buildFilterTabs(AppLocalizations l10n, ThemeData theme, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Row(
        children: [
          _buildFilterTab(l10n.todayTasks, TaskFilter.today, theme, isDark),
          _buildFilterTab(l10n.weeklyTasks, TaskFilter.thisWeek, theme, isDark),
          _buildFilterTab(l10n.allTasks, TaskFilter.all, theme, isDark),
        ],
      ),
    );
  }

  /// 构建单个过滤器选项卡
  Widget _buildFilterTab(String label, TaskFilter filter, ThemeData theme, bool isDark) {
    final isSelected = _selectedFilter == filter;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilter = filter;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14.0),
          decoration: BoxDecoration(
            color: isSelected 
                ? isDark ? theme.primaryColorDark : theme.primaryColor 
                : Colors.transparent,
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected 
                    ? Colors.white 
                    : isDark ? Colors.grey[300] : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 构建四象限网格
  Widget _buildQuadrantGrid(AppLocalizations l10n) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 8.0,
      mainAxisSpacing: 8.0,
      childAspectRatio: 0.9, // 调整卡片比例
      children: [
        // 重要且紧急
        QuadrantSection(
          quadrantType: QuadrantType.importantUrgent,
          title: l10n.quadrantUrgentImportant,
          tasks: _filteredTasks,
          onTaskCompletionChanged: _handleTaskCompletionChanged,
        ),
        
        // 重要不紧急
        QuadrantSection(
          quadrantType: QuadrantType.importantNotUrgent,
          title: l10n.quadrantImportantNotUrgent,
          tasks: _filteredTasks,
          onTaskCompletionChanged: _handleTaskCompletionChanged,
        ),
        
        // 紧急不重要
        QuadrantSection(
          quadrantType: QuadrantType.urgentNotImportant,
          title: l10n.quadrantUrgentNotImportant,
          tasks: _filteredTasks,
          onTaskCompletionChanged: _handleTaskCompletionChanged,
        ),
        
        // 不重要不紧急
        QuadrantSection(
          quadrantType: QuadrantType.notImportantNotUrgent,
          title: l10n.quadrantNotUrgentNotImportant,
          tasks: _filteredTasks,
          onTaskCompletionChanged: _handleTaskCompletionChanged,
        ),
      ],
    );
  }

  /// 处理任务完成状态变更
  void _handleTaskCompletionChanged(QuadrantTask task, bool isCompleted) {
    _updateTaskCompletion(task, isCompleted);
  }

  /// 显示添加任务对话框
  Future<void> _showAddTaskDialog(QuadrantType quadrantType) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => TaskEditDialog(
        defaultQuadrantType: quadrantType,
      ),
    );
    
    if (result != null) {
      setState(() {
        _tasks.add(
          QuadrantTask(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: result['title'] as String,
            deadline: result['deadline'] as String?,
            quadrantType: result['quadrantType'] as QuadrantType,
          ),
        );
      });
    }
  }
} 

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

/// 过滤器关键词常量
class FilterKeywords {
  static const todayZh = '今天';
  static const todayEn = 'Today';
  static const weekZh = '本周';
  static const weekEn = 'Week';
}

/// 优先级常量
class PriorityLevel {
  static const high = '高优先级';
  static const medium = '中优先级';
  static const low = '低优先级';
}

/// 四象限任务管理屏幕
class QuadrantScreen extends StatefulWidget {
  /// 构造函数
  const QuadrantScreen({Key? key}) : super(key: key);

  @override
  State<QuadrantScreen> createState() => _QuadrantScreenState();
}

class _QuadrantScreenState extends State<QuadrantScreen> {
  /// 当前选中的任务过滤器
  TaskFilter _selectedFilter = TaskFilter.today;
  
  /// 所有任务列表 (从数据库加载)
  List<QuadrantTask> _allTasks = [];
  
  /// 是否正在加载数据
  bool _isLoading = true;
  
  /// 数据库辅助工具
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  
  /// 象限类型定义
  static final List<QuadrantType> _quadrantTypes = [
    QuadrantType.importantUrgent,
    QuadrantType.importantNotUrgent,
    QuadrantType.urgentNotImportant,
    QuadrantType.notImportantNotUrgent,
  ];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  /// 从数据库加载任务列表
  Future<void> _loadTasks() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final tasksFromDb = await _dbHelper.readAllTasks();
      
      if (!mounted) return;
      
      final quadrantTasks = tasksFromDb.map((task) => _convertToQuadrantTask(task)).toList();
      
      setState(() {
        _allTasks = quadrantTasks;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('加载任务失败: $e');
      
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
        // 这里可以设置错误状态或显示错误信息
      });
    }
  }
  
  /// 将数据库任务转换为四象限任务
  QuadrantTask _convertToQuadrantTask(Task task) {
    return QuadrantTask(
      id: task.id.toString(),
      title: task.title,
      deadline: task.deadline,
      quadrantType: _convertPriorityToQuadrant(task.priority, task.isPriority),
      isCompleted: task.isCompleted,
    );
  }

  /// 将优先级转换为象限类型
  QuadrantType _convertPriorityToQuadrant(String? priority, bool isPriority) {
    if (priority == null) return QuadrantType.notImportantNotUrgent;
    
    if (priority.contains('高')) return QuadrantType.importantUrgent;
    
    if (isPriority) return QuadrantType.importantNotUrgent;
    
    if (priority.contains('中')) return QuadrantType.urgentNotImportant;
    
    return QuadrantType.notImportantNotUrgent;
  }
  
  /// 将象限类型转换为优先级信息
  Map<String, dynamic> _convertQuadrantToPriority(QuadrantType quadrantType) {
    switch (quadrantType) {
      case QuadrantType.importantUrgent:
        return {'priority': PriorityLevel.high, 'isPriority': true};
        
      case QuadrantType.importantNotUrgent:
        return {'priority': PriorityLevel.medium, 'isPriority': true};
        
      case QuadrantType.urgentNotImportant:
        return {'priority': PriorityLevel.medium, 'isPriority': false};
        
      case QuadrantType.notImportantNotUrgent:
        return {'priority': PriorityLevel.low, 'isPriority': false};
    }
  }

  /// 更新任务完成状态
  Future<void> _updateTaskCompletion(QuadrantTask task, bool isCompleted) async {
    try {
      final taskId = int.tryParse(task.id);
      
      if (taskId == null) {
        debugPrint('无效的任务ID: ${task.id}');
        return;
      }
      
      final dbTask = Task(
        id: taskId,
        title: task.title,
        deadline: task.deadline,
        isCompleted: isCompleted,
      );
      
      await _dbHelper.updateTask(dbTask);
      await _loadTasks();
    } catch (e) {
      debugPrint('更新任务状态失败: $e');
      // 可以添加错误处理，如显示Snackbar等
    }
  }

  /// 获取当前过滤后的任务列表
  List<QuadrantTask> get _filteredTasks {
    switch (_selectedFilter) {
      case TaskFilter.today:
        return _filterTasksByKeywords([
          FilterKeywords.todayZh, 
          FilterKeywords.todayEn
        ]);
        
      case TaskFilter.thisWeek:
        return _filterTasksByKeywords([
          FilterKeywords.weekZh, 
          FilterKeywords.weekEn
        ]);
        
      case TaskFilter.all:
      default:
        return _allTasks;
    }
  }
  
  /// 根据关键词过滤任务
  List<QuadrantTask> _filterTasksByKeywords(List<String> keywords) {
    return _allTasks.where((task) => 
      task.deadline != null && 
      keywords.any((keyword) => task.deadline!.contains(keyword))
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题
              _buildScreenTitle(l10n, theme),
              const SizedBox(height: 16.0),
              
              // 过滤器选项卡
              _buildFilterTabs(l10n, theme, isDark),
              const SizedBox(height: 16.0),
              
              // 四象限网格或加载指示器
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildQuadrantGrid(l10n),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建屏幕标题
  Widget _buildScreenTitle(AppLocalizations l10n, ThemeData theme) {
    return Text(
      l10n.quadrantTaskManager,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: theme.textTheme.titleLarge?.color,
      ),
    );
  }

  /// 构建过滤器选项卡组
  Widget _buildFilterTabs(AppLocalizations l10n, ThemeData theme, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Row(
        children: TaskFilter.values.map((filter) =>
          _buildFilterTab(
            _getFilterLabel(l10n, filter),
            filter,
            theme,
            isDark,
          )
        ).toList(),
      ),
    );
  }

  /// 获取过滤器的本地化标签
  String _getFilterLabel(AppLocalizations l10n, TaskFilter filter) {
    switch (filter) {
      case TaskFilter.today:
        return l10n.todayTasks;
      case TaskFilter.thisWeek:
        return l10n.weeklyTasks;
      case TaskFilter.all:
      default:
        return l10n.allTasks;
    }
  }

  /// 构建单个过滤器选项卡
  Widget _buildFilterTab(String label, TaskFilter filter, ThemeData theme, bool isDark) {
    final isSelected = _selectedFilter == filter;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_selectedFilter != filter) {
            setState(() {
              _selectedFilter = filter;
            });
          }
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

  /// 构建四象限网格 - 使用GridView.builder动态生成
  Widget _buildQuadrantGrid(AppLocalizations l10n) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 0.9, // 调整卡片比例
      ),
      itemCount: _quadrantTypes.length,
      itemBuilder: (context, index) {
        final quadrantType = _quadrantTypes[index];
        return QuadrantSection(
          quadrantType: quadrantType,
          title: _getQuadrantTitle(l10n, quadrantType),
          tasks: _filteredTasks,
          onTaskCompletionChanged: _handleTaskCompletionChanged,
        );
      },
    );
  }
  
  /// 获取象限的本地化标题
  String _getQuadrantTitle(AppLocalizations l10n, QuadrantType type) {
    switch (type) {
      case QuadrantType.importantUrgent:
        return l10n.quadrantUrgentImportant;
      case QuadrantType.importantNotUrgent:
        return l10n.quadrantImportantNotUrgent;
      case QuadrantType.urgentNotImportant:
        return l10n.quadrantUrgentNotImportant;
      case QuadrantType.notImportantNotUrgent:
        return l10n.quadrantNotUrgentNotImportant;
    }
  }

  /// 处理任务完成状态变更回调
  void _handleTaskCompletionChanged(QuadrantTask task, bool isCompleted) {
    _updateTaskCompletion(task, isCompleted);
  }

  /// 显示添加任务对话框
  Future<void> _showAddTaskDialog(QuadrantType? defaultQuadrantType) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => TaskEditDialog(
        defaultQuadrantType: defaultQuadrantType,
      ),
    );
    
    if (result != null && result.containsKey('title')) {
      try {
        // 从象限类型转换为优先级信息
        final quadrantType = result['quadrantType'] as QuadrantType;
        final priorityInfo = _convertQuadrantToPriority(quadrantType);
        
        // 创建新任务
        final newTask = Task(
          title: result['title'] as String,
          deadline: result['deadline'] as String?,
          priority: priorityInfo['priority'] as String,
          isPriority: priorityInfo['isPriority'] as bool,
          isCompleted: false,
        );
        
        await _dbHelper.createTask(newTask);
        await _loadTasks();
      } catch (e) {
        debugPrint('添加任务失败: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('添加任务失败: $e')),
          );
        }
      }
    }
  }
} 

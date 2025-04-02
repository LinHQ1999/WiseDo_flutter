import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
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
  List<Task> _tasks = [];
  bool _initialized = false;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTasks();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 当从其他页面返回时重新加载任务
    if (_initialized) {
      _loadTasks();
    }
  }
  
  @override
  void dispose() {
    // 不再主动关闭数据库，由DatabaseHelper管理
    super.dispose();
  }

  /// 从数据库加载任务
  Future<void> _loadTasks() async {
    try {
      final tasks = await _dbHelper.readAllTasks();
      if (tasks.isEmpty) {
        await _initializeDefaultTasks();
      } else {
        setState(() {
          _tasks = tasks;
          _initialized = true;
        });
      }
    } catch (e) {
      debugPrint('加载任务失败: $e');
      setState(() {
        _initialized = true; // 即使失败也标记为已初始化
      });
      // 可以在这里添加重试逻辑或显示错误提示
    }
  }

  /// 初始化默认任务（使用本地化字符串）
  Future<void> _initializeDefaultTasks() async {
    final l10n = AppLocalizations.of(context)!;
    final defaultTasks = [
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

    for (final task in defaultTasks) {
      await _dbHelper.createTask(task);
    }

    setState(() {
      _tasks = defaultTasks;
      _initialized = true;
    });
  }

  /// 更新任务完成状态
  Future<void> _updateTaskCompletion(Task task, bool isCompleted) async {
    try {
      if (task.id == null) {
        debugPrint('无法更新任务状态：任务ID为空');
        return;
      }
      
      // 使用专门的方法更新任务完成状态
      await _dbHelper.updateTaskCompletion(task.id!, isCompleted);
      
      // 更新本地状态
      setState(() {
        final index = _tasks.indexWhere((t) => t.id == task.id);
        if (index != -1) {
          _tasks[index] = task.copyWith(
            status: isCompleted ? TaskStatus.completed : TaskStatus.pending,
          );
        }
      });
      
      // 显示成功消息
      final message = isCompleted ? '任务已完成' : '任务已恢复';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      debugPrint('更新任务状态失败: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('更新任务状态失败'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
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

  /// 显示添加任务对话框 -> 修改为显示底部弹出菜单
  void _showAddTaskDialog() {
    // 显示底部弹出菜单
    final titleController = TextEditingController();
    DateTime? selectedDeadline;
    TimeOfDay? selectedReminderTime;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 允许键盘弹出时调整大小
      builder: (BuildContext context) {
        return _buildAddTaskBottomSheet(
          context, 
          titleController,
          selectedDeadline,
          selectedReminderTime,
        );
      },
      backgroundColor: Colors.transparent, // 透明背景
    );
  }
  
  /// 构建添加任务的底部弹出菜单
  Widget _buildAddTaskBottomSheet(
    BuildContext context,
    TextEditingController titleController,
    DateTime? initialDeadline,
    TimeOfDay? initialReminderTime,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    DateTime? selectedDeadline = initialDeadline;
    TimeOfDay? selectedReminderTime = initialReminderTime;

    // 使用StatefulBuilder以便在BottomSheet内部管理状态
    return StatefulBuilder(
      builder: (context, setState) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 任务输入区域
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: Row(
                    children: [
                      // 任务状态图标（未完成圆圈）
                      Container(
                        width: 24.0,
                        height: 24.0,
                        margin: const EdgeInsets.only(right: 16.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.primaryColor.withOpacity(0.7),
                            width: 2.0,
                          ),
                        ),
                      ),
                      
                      // 任务标题输入框
                      Expanded(
                        child: TextField(
                          controller: titleController,
                          decoration: InputDecoration(
                            hintText: l10n.taskTitleHint,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
                          ),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          autofocus: true,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _addTask(titleController.text, selectedDeadline, selectedReminderTime),
                        ),
                      ),
                      
                      // 添加任务按钮 - 改为不太醒目的颜色
                      IconButton(
                        icon: Icon(
                          Icons.arrow_upward_rounded,
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                          size: 28,
                        ),
                        onPressed: () => _addTask(titleController.text, selectedDeadline, selectedReminderTime),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // 分隔线
                Divider(
                  height: 1,
                  thickness: 0.5,
                  color: theme.dividerColor.withOpacity(0.5),
                ),
                
                const SizedBox(height: 8),
                
                // 底部操作按钮栏 - 使用更简洁的行布局
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // 设置截止日期按钮
                      TextButton.icon(
                        icon: Icon(
                          Icons.calendar_today_outlined,
                          size: 18,
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                        ),
                        label: Text(
                          "截止日期",
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDeadline ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2101),
                          );
                          if (picked != null) {
                            setState(() {
                              selectedDeadline = picked;
                            });
                          }
                        },
                      ),
                      
                      const SizedBox(width: 8),
                      
                      // 提醒我按钮
                      TextButton.icon(
                        icon: Icon(
                          Icons.notifications_none_outlined,
                          size: 18,
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                        ),
                        label: Text(
                          "提醒我",
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: selectedReminderTime ?? TimeOfDay.now(),
                          );
                          if (picked != null) {
                            setState(() {
                              selectedReminderTime = picked;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
                
                // 显示所选日期和时间提示
                if (selectedDeadline != null || selectedReminderTime != null) ...[
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        // 显示截止日期标签
                        if (selectedDeadline != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                                ),
                                const SizedBox(width: 8.0),
                                Text(
                                  '${selectedDeadline!.year}-${selectedDeadline!.month.toString().padLeft(2, '0')}-${selectedDeadline!.day.toString().padLeft(2, '0')}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      selectedDeadline = null;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Icon(
                                      Icons.close,
                                      size: 14,
                                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                        // 显示提醒时间标签
                        if (selectedReminderTime != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.notifications_active,
                                  size: 16,
                                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                                ),
                                const SizedBox(width: 8.0),
                                Text(
                                  '${selectedReminderTime!.hour.toString().padLeft(2, '0')}:${selectedReminderTime!.minute.toString().padLeft(2, '0')}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      selectedReminderTime = null;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Icon(
                                      Icons.close,
                                      size: 14,
                                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
  
  /// 添加新任务
  Future<void> _addTask(String title, DateTime? deadline, TimeOfDay? reminderTime) async {
    if (title.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.taskTitleCannotBeEmpty),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    // 格式化截止日期（如果存在）
    String? formattedDeadline;
    if (deadline != null) {
      formattedDeadline = deadline.toIso8601String();
    }
    
    // 格式化提醒时间（如果存在）
    String? formattedReminderTime;
    if (reminderTime != null) {
      final now = DateTime.now();
      final reminderDateTime = DateTime(
        now.year, 
        now.month, 
        now.day, 
        reminderTime.hour, 
        reminderTime.minute
      );
      formattedReminderTime = reminderDateTime.toIso8601String();
    }
    
    // 创建新任务
    final newTask = Task(
      title: title.trim(),
      deadline: formattedDeadline,
      reminderTime: formattedReminderTime,
      priority: PriorityLevel.medium.name,
      status: TaskStatus.pending, // 默认为待完成状态
      isPriority: false,         // 默认非优先级任务
    );
    
    try {
      // 保存到数据库
      final id = await _dbHelper.createTask(newTask);
      
      if (id > 0) {
        // 关闭底部弹出菜单
        Navigator.pop(context); 
        
        // 显示成功提示
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('任务已添加'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
        
        // 刷新任务列表
        setState(() {
          _loadTasks();
        });
      } else {
        _showErrorMessage();
      }
    } catch (e) {
      debugPrint('添加任务出错: $e');
      _showErrorMessage();
    }
  }
  
  /// 显示错误消息
  void _showErrorMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.failedToAddTask),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
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
                _updateTaskCompletion(task, !task.isCompleted);
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
                    _formatDateTime(task.deadline!, isDate: true),
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ],
                if (task.reminderTime != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.notifications,
                        size: 14,
                        color: theme.primaryColor.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDateTime(task.reminderTime!, isTime: true),
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.primaryColor.withOpacity(0.9),
                        ),
                      ),
                    ],
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
  
  /// 格式化日期时间字符串为友好格式
  String _formatDateTime(String isoString, {bool isDate = false, bool isTime = false}) {
    try {
      final dateTime = DateTime.parse(isoString);
      
      if (isDate) {
        // 仅格式化日期部分
        return '${dateTime.year}年${dateTime.month}月${dateTime.day}日';
      } else if (isTime) {
        // 仅格式化时间部分
        return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      } else {
        // 格式化完整日期时间
        return '${dateTime.year}年${dateTime.month}月${dateTime.day}日 ${dateTime.hour}:${dateTime.minute}';
      }
    } catch (e) {
      // 如果解析失败，返回原始字符串
      return isoString;
    }
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

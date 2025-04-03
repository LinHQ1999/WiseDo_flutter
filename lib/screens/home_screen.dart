import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/task.dart';
import '../widgets/header_widget.dart';
import '../widgets/section_card.dart';
import '../widgets/task_item.dart';
import './task_detail_screen.dart'; // 导入任务详情页面
import '../constants/app_theme.dart';

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
      
      // 使用iOS风格的通知
      showCupertinoDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            content: Text(message),
          );
        },
      );
      
      // 1秒后自动关闭
      Future.delayed(const Duration(seconds: 1), () {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      });
    } catch (e) {
      debugPrint('更新任务状态失败: $e');
      
      // 使用iOS风格的错误通知
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text('出错了'),
            content: Text('更新任务状态失败'),
            actions: [
              CupertinoDialogAction(
                child: Text('确定'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        },
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
      return Center(child: CupertinoActivityIndicator());
    }

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('WiseDo'),
        backgroundColor: theme.scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
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
                      const SizedBox(height: 100),
                    ]),
                  ),
                ),
              ],
            ),
            
            // 添加新建任务的浮动按钮 (iOS风格)
            Positioned(
              right: 16,
              bottom: 16,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CupertinoIcons.add,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                onPressed: _showAddTaskDialog,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建天气卡片
  Widget _buildWeatherCard(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1C1C1E) : Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Color(0xFF38383A) : Color(0xFFE5E5EA),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.sun_max,
            color: isDark ? Color(0xFFFFD60A) : Color(0xFF007AFF),
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
    
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return _buildAddTaskBottomSheet(
          context, 
          titleController,
          selectedDeadline,
          selectedReminderTime,
        );
      },
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
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
            child: Container(
              color: theme.cardColor,
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 拖动指示器
                    Container(
                      width: 40,
                      height: 4,
                      margin: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: theme.dividerColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    
                    // 标题输入区域
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: CupertinoTextField(
                              controller: titleController,
                              placeholder: '添加新任务...',
                              placeholderStyle: TextStyle(
                                color: theme.hintColor,
                              ),
                              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                              decoration: BoxDecoration(
                                color: theme.inputDecorationTheme.fillColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              style: theme.textTheme.titleMedium,
                              onSubmitted: (text) {
                                if (text.isNotEmpty) {
                                  _addTask(text, selectedDeadline, selectedReminderTime);
                                }
                              },
                            ),
                          ),
                          SizedBox(width: 8),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: theme.primaryColor,
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: Icon(
                                CupertinoIcons.arrow_up,
                                color: Colors.white,
                                size: 20,
                              ),
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
                      color: theme.dividerColor,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // 底部操作按钮 - 截止日期和提醒
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // 截止日期按钮
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: Row(
                            children: [
                              Icon(
                                CupertinoIcons.calendar,
                                size: 20,
                                color: theme.primaryColor,
                              ),
                              SizedBox(width: 4),
                              Text(
                                '截止日期',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: theme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          onPressed: () async {
                            final DateTime? picked = await showCupertinoModalPopup<DateTime>(
                              context: context,
                              builder: (BuildContext context) {
                                return Container(
                                  height: 216,
                                  padding: const EdgeInsets.only(top: 6.0),
                                  margin: EdgeInsets.only(
                                    bottom: MediaQuery.of(context).viewInsets.bottom,
                                  ),
                                  color: CupertinoColors.systemBackground.resolveFrom(context),
                                  child: SafeArea(
                                    top: false,
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            CupertinoButton(
                                              child: Text('取消'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            CupertinoButton(
                                              child: Text('确定'),
                                              onPressed: () {
                                                Navigator.of(context).pop(
                                                  selectedDeadline ?? DateTime.now()
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                        Expanded(
                                          child: CupertinoDatePicker(
                                            initialDateTime: selectedDeadline ?? DateTime.now(),
                                            mode: CupertinoDatePickerMode.date,
                                            onDateTimeChanged: (DateTime newDate) {
                                              selectedDeadline = newDate;
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                            
                            if (picked != null) {
                              setState(() {
                                selectedDeadline = picked;
                              });
                            }
                          },
                        ),
                        
                        // 分隔线
                        Container(
                          height: 24,
                          width: 1,
                          color: theme.dividerColor,
                        ),
                        
                        // 提醒时间按钮
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: Row(
                            children: [
                              Icon(
                                CupertinoIcons.bell,
                                size: 20,
                                color: theme.primaryColor,
                              ),
                              SizedBox(width: 4),
                              Text(
                                '提醒我',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: theme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          onPressed: () async {
                            final TimeOfDay? picked = await showCupertinoModalPopup<TimeOfDay>(
                              context: context,
                              builder: (BuildContext context) {
                                return Container(
                                  height: 216,
                                  padding: const EdgeInsets.only(top: 6.0),
                                  margin: EdgeInsets.only(
                                    bottom: MediaQuery.of(context).viewInsets.bottom,
                                  ),
                                  color: CupertinoColors.systemBackground.resolveFrom(context),
                                  child: SafeArea(
                                    top: false,
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            CupertinoButton(
                                              child: Text('取消'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            CupertinoButton(
                                              child: Text('确定'),
                                              onPressed: () {
                                                final now = DateTime.now();
                                                final TimeOfDay currentTime = selectedReminderTime ?? TimeOfDay.now();
                                                Navigator.of(context).pop(currentTime);
                                              },
                                            ),
                                          ],
                                        ),
                                        Expanded(
                                          child: CupertinoDatePicker(
                                            initialDateTime: DateTime(
                                              DateTime.now().year,
                                              DateTime.now().month,
                                              DateTime.now().day,
                                              selectedReminderTime?.hour ?? DateTime.now().hour,
                                              selectedReminderTime?.minute ?? DateTime.now().minute,
                                            ),
                                            mode: CupertinoDatePickerMode.time,
                                            onDateTimeChanged: (DateTime newDate) {
                                              selectedReminderTime = TimeOfDay(
                                                hour: newDate.hour,
                                                minute: newDate.minute,
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
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
                    
                    // 显示已选日期和提醒时间
                    SizedBox(height: 8),
                    
                    if (selectedDeadline != null || selectedReminderTime != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (selectedDeadline != null)
                              Container(
                                margin: const EdgeInsets.only(right: 8.0),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: theme.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      CupertinoIcons.calendar,
                                      size: 16,
                                      color: theme.primaryColor.withOpacity(0.8),
                                    ),
                                    const SizedBox(width: 8.0),
                                    Text(
                                      '${selectedDeadline!.year}/${selectedDeadline!.month.toString().padLeft(2, '0')}/${selectedDeadline!.day.toString().padLeft(2, '0')}',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.primaryColor.withOpacity(0.8),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedDeadline = null;
                                        });
                                      },
                                      child: Icon(
                                        CupertinoIcons.clear_circled_solid,
                                        size: 16,
                                        color: theme.primaryColor.withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            
                            if (selectedReminderTime != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: theme.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      CupertinoIcons.bell_fill,
                                      size: 16,
                                      color: theme.primaryColor.withOpacity(0.8),
                                    ),
                                    const SizedBox(width: 8.0),
                                    Text(
                                      '${selectedReminderTime!.hour.toString().padLeft(2, '0')}:${selectedReminderTime!.minute.toString().padLeft(2, '0')}',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.primaryColor.withOpacity(0.8),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedReminderTime = null;
                                        });
                                      },
                                      child: Icon(
                                        CupertinoIcons.clear_circled_solid,
                                        size: 16,
                                        color: theme.primaryColor.withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    
                    SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  /// 添加新任务
  Future<void> _addTask(String title, DateTime? deadline, TimeOfDay? reminderTime) async {
    // 验证标题不为空
    if (title.trim().isEmpty) {
      // 使用iOS风格的错误提示
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text('提示'),
          content: Text('任务标题不能为空'),
          actions: [
            CupertinoDialogAction(
              child: Text('确定'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
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
    
    // 创建新任务对象
    final task = Task(
      title: title.trim(),
      deadline: formattedDeadline,
      reminderTime: formattedReminderTime,
      status: TaskStatus.pending,
      createdAt: DateTime.now().toIso8601String(),
    );
    
    try {
      // 保存到数据库
      final id = await _dbHelper.createTask(task);
      
      // 更新本地任务列表
      setState(() {
        _tasks.add(task.copyWith(id: id));
      });
      
      // 成功提示
      showCupertinoDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            content: Text('任务已添加'),
          );
        },
      );
      
      // 1秒后自动关闭
      Future.delayed(const Duration(seconds: 1), () {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      });
      
      // 关闭底部弹出菜单
      Navigator.pop(context);
    } catch (e) {
      debugPrint('添加任务失败: $e');
      
      // 错误提示
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text('错误'),
          content: Text('添加任务失败'),
          actions: [
            CupertinoDialogAction(
              child: Text('确定'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  /// 构建优先级部分
  Widget _buildPrioritySection(AppLocalizations l10n, ThemeData theme, bool isDark) {
    // 找到优先级任务
    final priorityTasks = _tasks.where((task) => task.isPriority).toList();
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF0A2647) : Color(0xFF007AFF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Color(0xFF0A84FF).withOpacity(0.3) : Color(0xFF007AFF).withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题部分
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.star_fill,
                  color: isDark ? Color(0xFF0A84FF) : Color(0xFF007AFF),
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.prioritySuggestion,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Color(0xFF007AFF),
                  ),
                ),
              ],
            ),
          ),
          
          // 任务列表
          if (priorityTasks.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      CupertinoIcons.star,
                      size: 48,
                      color: (isDark ? Colors.white : Color(0xFF007AFF)).withOpacity(0.5),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '没有优先事项',
                      style: TextStyle(
                        fontSize: 16,
                        color: (isDark ? Colors.white : Color(0xFF007AFF)).withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  for (final task in priorityTasks)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? Color(0xFF0A3060) : Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? Color(0xFF0A84FF).withOpacity(0.3) : Color(0xFF007AFF).withOpacity(0.2),
                          width: 0.5,
                        ),
                      ),
                      child: _buildPriorityTaskItem(task, theme, isDark),
                    ),
                ],
              ),
            ),
          
          const SizedBox(height: 8),
        ],
      ),
    );
  }
  
  /// 构建优先任务项内容
  Widget _buildPriorityTaskItem(Task task, ThemeData theme, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 复选框
        GestureDetector(
          onTap: () {
            _updateTaskCompletion(task, !task.isCompleted);
          },
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: task.isCompleted ? theme.colorScheme.secondary : theme.primaryColor,
                width: 2,
              ),
              color: task.isCompleted ? theme.colorScheme.secondary : Colors.transparent,
            ),
            child: task.isCompleted
                ? Icon(
                    CupertinoIcons.check_mark,
                    size: 16,
                    color: Colors.white,
                  )
                : null,
          ),
        ),
        const SizedBox(width: 12),
        
        // 任务内容
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.3,
                  fontWeight: FontWeight.w600,
                  decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                  color: task.isCompleted 
                      ? isDark ? Colors.white.withOpacity(0.5) : theme.disabledColor
                      : isDark ? Colors.white : theme.textTheme.bodyLarge?.color,
                ),
              ),
              if (task.time != null || task.deadline != null || task.reminderTime != null)
                const SizedBox(height: 4),
              if (task.time != null)
                Text(
                  task.time!,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.2,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white.withOpacity(0.8) : theme.textTheme.bodySmall?.color,
                  ),
                ),
              if (task.deadline != null)
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.calendar,
                      size: 14,
                      color: isDark ? Color(0xFF0A84FF).withOpacity(0.9) : theme.primaryColor.withOpacity(0.8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDateTime(task.deadline!, isDate: true),
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.2,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Color(0xFF0A84FF) : theme.primaryColor.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              if (task.reminderTime != null)
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.bell,
                      size: 14,
                      color: isDark ? Color(0xFF0A84FF).withOpacity(0.9) : theme.primaryColor.withOpacity(0.8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDateTime(task.reminderTime!, isTime: true),
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.2,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Color(0xFF0A84FF) : theme.primaryColor.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
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
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ),
      ],
    );
  }

  /// 构建任务部分
  Widget _buildTaskSection(AppLocalizations l10n, ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题行
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.todayTasks,
              style: theme.textTheme.titleLarge,
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: Row(
                children: [
                  Text(
                    '查看全部',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.primaryColor,
                    ),
                  ),
                  Icon(
                    CupertinoIcons.right_chevron,
                    size: 14,
                    color: theme.primaryColor,
                  ),
                ],
              ),
              onPressed: () {
                // 查看全部任务的逻辑
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // 任务列表
        for (int i = 0; i < _tasks.length; i++)
          _buildTaskListItem(_tasks[i], theme, isDark),
      ],
    );
  }

  /// 构建任务列表项
  Widget _buildTaskListItem(Task task, ThemeData theme, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 复选框
            GestureDetector(
              onTap: () {
                _updateTaskCompletion(task, !task.isCompleted);
              },
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: task.isCompleted ? theme.colorScheme.secondary : theme.primaryColor,
                    width: 2,
                  ),
                  color: task.isCompleted ? theme.colorScheme.secondary : Colors.transparent,
                ),
                child: task.isCompleted
                    ? Icon(
                        CupertinoIcons.check_mark,
                        size: 16,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            
            // 任务内容
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                      color: task.isCompleted 
                          ? isDark ? Colors.white.withOpacity(0.5) : Colors.grey[600]
                          : isDark ? Colors.white : Colors.black.withOpacity(0.87),
                    ),
                  ),
                  if (task.time != null || task.deadline != null || task.reminderTime != null)
                    const SizedBox(height: 4),
                  if (task.time != null)
                    Text(
                      task.time!,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.2,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white.withOpacity(0.8) : Colors.black.withOpacity(0.65),
                      ),
                    ),
                  if (task.deadline != null)
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.calendar,
                          size: 14,
                          color: isDark ? Color(0xFF0A84FF).withOpacity(0.9) : theme.primaryColor.withOpacity(0.8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDateTime(task.deadline!, isDate: true),
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.2,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Color(0xFF0A84FF) : theme.primaryColor.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  if (task.reminderTime != null)
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.bell,
                          size: 14,
                          color: isDark ? Color(0xFF0A84FF).withOpacity(0.9) : theme.primaryColor.withOpacity(0.8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDateTime(task.reminderTime!, isTime: true),
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.2,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Color(0xFF0A84FF) : theme.primaryColor.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            
            // 优先级标记
            if (task.isPriority)
              Container(
                margin: const EdgeInsets.only(left: 8),
                child: Icon(
                  CupertinoIcons.star_fill,
                  color: isDark ? Colors.amber : Colors.amber[600],
                  size: 20,
                ),
              ),
            
            // 操作按钮
            GestureDetector(
              onTap: () => _onTaskTap(task),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  CupertinoIcons.ellipsis_vertical,
                  color: isDark ? Colors.white.withOpacity(0.5) : Colors.grey[700],
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // 任务点击处理
  void _onTaskTap(Task task) {
    // 导航到任务详情页或显示操作菜单
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => TaskDetailScreen(task: task),
      ),
    ).then((result) {
      if (result != null) {
        _loadTasks();
      }
    });
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
      return isDark ? const Color(0xFFFF453A) : const Color(0xFFFF3B30);
    } else if (priority.contains('中')) {
      return isDark ? const Color(0xFFFF9F0A) : const Color(0xFFFF9500);
    } else {
      return isDark ? const Color(0xFF30D158) : const Color(0xFF34C759);
    }
  }
} 

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
      
      // 移除显示成功消息的弹窗代码
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
        bottom: false,
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                // 主要内容区域
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80), // 增加底部间距，为浮动按钮留空间
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
    TaskCategory selectedCategory = TaskCategory.work; // 默认为工作分类

    // 使用StatefulBuilder以便在BottomSheet内部管理状态
    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          // 确保键盘弹出时内容不被遮挡
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 10,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
            child: Container(
              color: theme.cardColor,
              child: SingleChildScrollView(
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
                                    _addTask(text, selectedDeadline, selectedReminderTime, null, selectedCategory);
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
                              onPressed: () => _addTask(titleController.text, selectedDeadline, selectedReminderTime, null, selectedCategory),
                            ),
                          ],
                        ),
                      ),
                      
                      // 选择任务分类
                      Container(
                        height: 58,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          children: [
                            _buildCategoryOption(
                              context, 
                              TaskCategory.work, 
                              selectedCategory, 
                              (category) {
                                setState(() {
                                  selectedCategory = category;
                                });
                              }
                            ),
                            _buildCategoryOption(
                              context, 
                              TaskCategory.life, 
                              selectedCategory, 
                              (category) {
                                setState(() {
                                  selectedCategory = category;
                                });
                              }
                            ),
                            _buildCategoryOption(
                              context, 
                              TaskCategory.study, 
                              selectedCategory, 
                              (category) {
                                setState(() {
                                  selectedCategory = category;
                                });
                              }
                            ),
                            _buildCategoryOption(
                              context, 
                              TaskCategory.health, 
                              selectedCategory, 
                              (category) {
                                setState(() {
                                  selectedCategory = category;
                                });
                              }
                            ),
                            _buildCategoryOption(
                              context, 
                              TaskCategory.social, 
                              selectedCategory, 
                              (category) {
                                setState(() {
                                  selectedCategory = category;
                                });
                              }
                            ),
                            _buildCategoryOption(
                              context, 
                              TaskCategory.other, 
                              selectedCategory, 
                              (category) {
                                setState(() {
                                  selectedCategory = category;
                                });
                              }
                            ),
                          ],
                        ),
                      ),
                      
                      // 移除水平分隔线，保留间距
                      const SizedBox(height: 16),
                      
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
                          
                          // 移除垂直分隔线，使用SizedBox增加间距
                          SizedBox(width: 24),
                          
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
                      
                      SizedBox(height: 16), // 增加底部间距
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  /// 构建任务分类选项
  Widget _buildCategoryOption(
    BuildContext context, 
    TaskCategory category, 
    TaskCategory selectedCategory, 
    Function(TaskCategory) onCategorySelected
  ) {
    final theme = Theme.of(context);
    final isSelected = category == selectedCategory;
    final categoryColor = category.color;
    
    return GestureDetector(
      onTap: () {
        onCategorySelected(category);
      },
      child: Container(
        margin: EdgeInsets.only(right: 8),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? categoryColor.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: isSelected 
                ? Border.all(color: categoryColor, width: 2)
                : null, // 移除未选中状态的边框
          ),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: categoryColor,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 6),
              Text(
                category.getLocalizedName(context),
                style: TextStyle(
                  fontSize: 14,
                  color: isSelected ? categoryColor : theme.textTheme.bodyMedium?.color,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// 添加新任务
  Future<void> _addTask(String title, DateTime? deadline, TimeOfDay? reminderTime, TaskType? taskType, TaskCategory category) async {
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
      taskType: taskType,
      status: TaskStatus.pending,
      createdAt: DateTime.now().toIso8601String(),
      category: category,
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
    
    // 定义颜色变量 - 使用更柔和的色调
    final Color backgroundColor = isDark 
        ? Color(0xFF2C3A47) // 深色模式下的深蓝灰色
        : Color(0xFFEDF6FF); // 浅色模式下的浅蓝色
    final Color textColor = isDark 
        ? Colors.white 
        : Color(0xFF2C3A47); // 深蓝灰色文字
    final Color accentColor = Color(0xFF5E8CE4); // 强调色
    final Color iconBackgroundColor = isDark 
        ? Color(0xFF3A4D5D) 
        : Color(0xFFD6E6FF);
    final Color iconColor = accentColor;
    final Color itemBackgroundColor = isDark 
        ? Color(0xFF38485A).withOpacity(0.6) 
        : Colors.white;
    final Color checkboxBorderColor = accentColor;
    final Color checkboxCheckColor = accentColor;
    
    // 阴影效果
    final List<BoxShadow> cardShadow = [
      BoxShadow(
        color: Colors.black.withOpacity(0.06),
        offset: Offset(0, 3),
        blurRadius: 6,
        spreadRadius: 0,
      ),
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题部分
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconBackgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    CupertinoIcons.bolt_fill,
                    color: iconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '今天优先处理',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          
          // 任务列表
          if (priorityTasks.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: iconBackgroundColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        CupertinoIcons.checkmark_alt_circle,
                        size: 32,
                        color: iconColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '暂无优先任务',
                      style: TextStyle(
                        fontSize: 16,
                        color: textColor.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                children: [
                  for (final task in priorityTasks)
                    GestureDetector(
                      onTap: () => _onTaskTap(task),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: itemBackgroundColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              offset: Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _onTaskTap(task),
                              splashColor: accentColor.withOpacity(0.1),
                              highlightColor: accentColor.withOpacity(0.05),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Row(
                                  children: [
                                    // 任务类型图标
                                    Container(
                                      width: 36,
                                      height: 36,
                                      margin: EdgeInsets.only(right: 12),
                                      decoration: BoxDecoration(
                                        color: iconBackgroundColor,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          task.taskCategory.icon,
                                          color: task.taskCategory.color,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                    // 任务内容
                                    Expanded(
                                      child: _buildPriorityTaskItem(
                                        task,
                                        theme,
                                        isDark,
                                        textColor: textColor,
                                        accentColor: accentColor,
                                        checkboxBorderColor: checkboxBorderColor,
                                        checkboxCheckColor: checkboxCheckColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
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
  Widget _buildPriorityTaskItem(
    Task task,
    ThemeData theme,
    bool isDark, {
    required Color textColor,
    required Color accentColor,
    required Color checkboxBorderColor,
    required Color checkboxCheckColor,
  }) {
    final Color completedTextColor = textColor.withOpacity(0.5);
    final Color completedCheckboxBorderColor = checkboxBorderColor.withOpacity(0.5);
    final Color completedCheckboxColor = checkboxBorderColor.withOpacity(0.1);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 复选框
        GestureDetector(
          onTap: () {
            _updateTaskCompletion(task, !task.isCompleted);
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: task.isCompleted ? completedCheckboxBorderColor : checkboxBorderColor,
                width: 2,
              ),
              color: task.isCompleted ? completedCheckboxColor : Colors.transparent,
            ),
            child: task.isCompleted
                ? Center(
                    child: Icon(
                      CupertinoIcons.check_mark,
                      size: 14,
                      color: checkboxCheckColor,
                    ),
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
                  color: task.isCompleted ? completedTextColor : textColor,
                ),
              ),
              if (task.time != null || task.deadline != null || task.reminderTime != null)
                const SizedBox(height: 6),
              if (task.time != null)
                Text(
                  task.time!,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.2,
                    fontWeight: FontWeight.w500,
                    color: task.isCompleted ? completedTextColor : textColor.withOpacity(0.7),
                  ),
                ),
              if (task.deadline != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.calendar,
                        size: 14,
                        color: accentColor.withOpacity(task.isCompleted ? 0.5 : 0.8),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDateTime(task.deadline!, isDate: true),
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.2,
                          fontWeight: FontWeight.w500,
                          color: accentColor.withOpacity(task.isCompleted ? 0.5 : 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              if (task.reminderTime != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.bell,
                        size: 14,
                        color: accentColor.withOpacity(task.isCompleted ? 0.5 : 0.8),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDateTime(task.reminderTime!, isTime: true),
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.2,
                          fontWeight: FontWeight.w500,
                          color: accentColor.withOpacity(task.isCompleted ? 0.5 : 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
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
    return GestureDetector(
      onTap: () => _onTaskTap(task),
      child: Container(
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
                      color: task.isCompleted ? theme.colorScheme.secondary : task.taskCategory.color,
                      width: 2,
                    ),
                    color: task.isCompleted ? theme.colorScheme.secondary.withOpacity(0.2) : Colors.transparent,
                  ),
                  child: task.isCompleted
                      ? Icon(
                          CupertinoIcons.check_mark,
                          size: 16,
                          color: task.isCompleted ? theme.colorScheme.secondary : task.taskCategory.color,
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
                    Row(
                      children: [
                        // 分类标签
                        Container(
                          margin: EdgeInsets.only(right: 8, bottom: 6),
                          child: Icon(
                            task.taskCategory.icon,
                            color: task.taskCategory.color,
                            size: 16,
                          ),
                        ),
                        Expanded(
                          child: Text(
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
                        ),
                      ],
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
            ],
          ),
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

  /// 根据任务标题返回对应的图标
  IconData _getTaskTypeIcon(String title) {
    return TaskTypeExtension.fromTitle(title).icon;
  }
} 

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../database/database_helper.dart';
import '../models/task.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// 任务详情页面
class TaskDetailScreen extends StatefulWidget {
  /// 构造函数
  const TaskDetailScreen({Key? key, required this.task}) : super(key: key);

  /// 任务实例
  final Task task;

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late Task _task;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  late TextEditingController _titleController;
  late TextEditingController _notesController;
  DateTime? _selectedDeadline;
  TimeOfDay? _selectedReminderTime;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
    _titleController = TextEditingController(text: _task.title);
    _notesController = TextEditingController();
    
    // 截止日期
    if (_task.deadline != null) {
      try {
        _selectedDeadline = DateTime.parse(_task.deadline!);
      } catch (e) {
        debugPrint('解析截止日期失败: $e');
      }
    }
    
    // 提醒时间
    if (_task.reminderTime != null) {
      try {
        final reminderDateTime = DateTime.parse(_task.reminderTime!);
        _selectedReminderTime = TimeOfDay(
          hour: reminderDateTime.hour,
          minute: reminderDateTime.minute,
        );
      } catch (e) {
        debugPrint('解析提醒时间失败: $e');
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// 更新任务
  Future<void> _updateTask() async {
    final String title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('任务标题不能为空'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // 格式化截止日期（如果存在）
    String? formattedDeadline;
    if (_selectedDeadline != null) {
      formattedDeadline = _selectedDeadline!.toIso8601String();
    }
    
    // 格式化提醒时间（如果存在）
    String? formattedReminderTime;
    if (_selectedReminderTime != null) {
      final now = DateTime.now();
      final reminderDateTime = DateTime(
        now.year, 
        now.month, 
        now.day, 
        _selectedReminderTime!.hour, 
        _selectedReminderTime!.minute
      );
      formattedReminderTime = reminderDateTime.toIso8601String();
    }
    
    // 创建更新后的任务对象
    final updatedTask = _task.copyWith(
      title: title,
      deadline: formattedDeadline,
      reminderTime: formattedReminderTime,
      isPriority: _task.isPriority,
    );
    
    try {
      await _dbHelper.updateTask(updatedTask);
      
      // 显示成功提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('任务已更新'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
      }
      
      // 返回上一页
      if (mounted) {
        Navigator.pop(context, updatedTask);
      }
    } catch (e) {
      debugPrint('更新任务出错: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('更新任务失败'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 更新任务完成状态
  Future<void> _updateTaskCompletion(bool isCompleted) async {
    try {
      if (_task.id == null) {
        debugPrint('无法更新任务状态：任务ID为空');
        return;
      }
      
      // 使用专门的方法更新任务完成状态
      await _dbHelper.updateTaskCompletion(_task.id!, isCompleted);
      
      // 更新本地状态
      setState(() {
        _task = _task.copyWith(
          status: isCompleted ? TaskStatus.completed : TaskStatus.pending,
        );
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

  /// 删除任务
  Future<void> _deleteTask() async {
    if (_task.id == null) {
      debugPrint('无法删除任务：任务ID为空');
      return;
    }
    
    // 显示确认对话框 - 使用CupertinoAlertDialog更符合iOS风格
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('确认删除'),
        content: Text('您确定要删除此任务吗？这个操作无法撤销。'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context, false),
            child: Text('取消'),
            isDefaultAction: true,
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context, true),
            child: Text('删除', style: TextStyle(color: Colors.red)),
            isDestructiveAction: true,
          ),
        ],
      ),
    );
    
    // 如果用户确认删除
    if (confirmed == true) {
      try {
        await _dbHelper.deleteTask(_task.id!);
        
        // 显示成功提示
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('任务已删除'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.orange,
            ),
          );
        }
        
        // 返回上一页并刷新任务列表
        if (mounted) {
          Navigator.pop(context, true); // 返回true表示需要刷新任务列表
        }
      } catch (e) {
        debugPrint('删除任务出错: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('删除任务失败'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// 获取智能建议
  List<String> _getSmartSuggestions() {
    // 根据任务标题生成智能建议
    final String title = _titleController.text.toLowerCase();
    final List<String> suggestions = [];
    
    // 读书相关建议
    if (title.contains('读') || title.contains('看') || title.contains('书') || title.contains('book')) {
      suggestions.add('📚 为阅读设置每天固定时间段');
      suggestions.add('📖 记录阅读笔记以加深理解');
    }
    
    // 学习相关建议
    if (title.contains('学习') || title.contains('study') || title.contains('课') || title.contains('作业')) {
      suggestions.add('📝 使用番茄工作法提高学习效率');
      suggestions.add('📊 建立学习计划和进度表');
    }
    
    // 运动健康相关建议
    if (title.contains('跑步') || title.contains('健身') || title.contains('运动') || title.contains('锻炼')) {
      suggestions.add('🏃‍♂️ 设定合理的运动目标和强度');
      suggestions.add('💪 记录每次锻炼数据追踪进度');
    }
    
    // 工作相关建议
    if (title.contains('工作') || title.contains('会议') || title.contains('项目') || title.contains('报告')) {
      suggestions.add('💼 使用SMART准则定义任务');
      suggestions.add('📅 提前15分钟准备会议材料');
    }
    
    // 如果没有匹配特定类别，返回通用建议
    if (suggestions.isEmpty) {
      suggestions.add('⏰ 设置任务提醒可以提高完成率');
      suggestions.add('📋 添加标签和分类便于任务管理');
      suggestions.add('🌟 分解大任务为小步骤更易执行');
    }
    
    return suggestions;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // iOS风格色彩
    final Color backgroundColor = isDark ? Color(0xFF1A1A1A) : Color(0xFFF8F8F8);
    final Color cardColor = isDark ? Color(0xFF2A2A2A) : Colors.white;
    final Color primaryColor = Color(0xFF007AFF); // iOS蓝色
    final Color accentColor = Color(0xFF34C759); // iOS绿色
    final Color subtleColor = isDark ? Colors.grey[600]! : Color(0xFFE5E5EA);
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            CupertinoIcons.back,
            color: primaryColor,
            size: 28,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('任务详情', style: TextStyle(
          color: theme.textTheme.titleLarge?.color,
          fontWeight: FontWeight.w600,
        )),
        backgroundColor: backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(CupertinoIcons.check_mark, color: accentColor),
            onPressed: _updateTask,
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // 任务标题和状态区域
          Card(
            elevation: 0,
            color: cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: subtleColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 任务状态切换 - 更iOS化的切换样式
                  GestureDetector(
                    onTap: () {
                      _updateTaskCompletion(!_task.isCompleted);
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _task.isCompleted ? accentColor : primaryColor,
                          width: 2,
                        ),
                        color: _task.isCompleted ? accentColor : Colors.transparent,
                      ),
                      child: _task.isCompleted
                          ? const Icon(
                              CupertinoIcons.check_mark,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // 任务标题输入
                  Expanded(
                    child: CupertinoTextField(
                      controller: _titleController,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(color: Colors.transparent),
                      ),
                      placeholder: '输入任务标题',
                      placeholderStyle: TextStyle(
                        color: theme.hintColor,
                      ),
                      padding: EdgeInsets.zero,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        decoration: _task.isCompleted ? TextDecoration.lineThrough : null,
                        color: _task.isCompleted 
                            ? theme.disabledColor 
                            : theme.textTheme.titleLarge?.color,
                      ),
                    ),
                  ),
                  
                  // 优先级图标
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _task = _task.copyWith(isPriority: !_task.isPriority);
                      });
                    },
                    child: Icon(
                      _task.isPriority ? CupertinoIcons.star_fill : CupertinoIcons.star,
                      color: _task.isPriority ? Color(0xFFFFCC00) : theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 16),
          
          // 日期和时间选择
          Card(
            elevation: 0,
            color: cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: subtleColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // 截止日期选择
                ListTile(
                  leading: Icon(
                    CupertinoIcons.calendar,
                    color: primaryColor.withOpacity(0.8),
                    size: 26,
                  ),
                  title: Text('截止日期', style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  )),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_selectedDeadline != null)
                        Text(
                          '${_selectedDeadline!.year}-${_selectedDeadline!.month.toString().padLeft(2, '0')}-${_selectedDeadline!.day.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            color: primaryColor.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      SizedBox(width: 8),
                      Icon(
                        CupertinoIcons.right_chevron,
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4),
                        size: 18,
                      ),
                    ],
                  ),
                  onTap: () async {
                    final DateTime? picked = await showCupertinoModalPopup<DateTime>(
                      context: context,
                      builder: (BuildContext context) => Container(
                        height: 216,
                        padding: const EdgeInsets.only(top: 6.0),
                        margin: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        color: CupertinoColors.systemBackground.resolveFrom(context),
                        child: SafeArea(
                          top: false,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
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
                                        _selectedDeadline ?? DateTime.now()
                                      );
                                    },
                                  ),
                                ],
                              ),
                              Expanded(
                                child: CupertinoDatePicker(
                                  initialDateTime: _selectedDeadline ?? DateTime.now(),
                                  mode: CupertinoDatePickerMode.date,
                                  onDateTimeChanged: (DateTime newDate) {
                                    setState(() {
                                      _selectedDeadline = newDate;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedDeadline = picked;
                      });
                    }
                  },
                ),
                
                Divider(height: 1, indent: 72, color: subtleColor.withOpacity(0.3)),
                
                // 提醒时间选择
                ListTile(
                  leading: Icon(
                    CupertinoIcons.bell,
                    color: primaryColor.withOpacity(0.8),
                    size: 26,
                  ),
                  title: Text('提醒时间', style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  )),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_selectedReminderTime != null)
                        Text(
                          '${_selectedReminderTime!.hour.toString().padLeft(2, '0')}:${_selectedReminderTime!.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            color: primaryColor.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      SizedBox(width: 8),
                      Icon(
                        CupertinoIcons.right_chevron,
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4),
                        size: 18,
                      ),
                    ],
                  ),
                  onTap: () async {
                    final TimeOfDay? picked = await showCupertinoModalPopup<TimeOfDay>(
                      context: context,
                      builder: (BuildContext context) => Container(
                        height: 216,
                        padding: const EdgeInsets.only(top: 6.0),
                        margin: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        color: CupertinoColors.systemBackground.resolveFrom(context),
                        child: SafeArea(
                          top: false,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
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
                                      final TimeOfDay currentTime = _selectedReminderTime ?? TimeOfDay.now();
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
                                    _selectedReminderTime?.hour ?? DateTime.now().hour,
                                    _selectedReminderTime?.minute ?? DateTime.now().minute,
                                  ),
                                  mode: CupertinoDatePickerMode.time,
                                  onDateTimeChanged: (DateTime newDate) {
                                    setState(() {
                                      _selectedReminderTime = TimeOfDay(
                                        hour: newDate.hour,
                                        minute: newDate.minute,
                                      );
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedReminderTime = picked;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          
          SizedBox(height: 16),
          
          // 任务备注
          Card(
            elevation: 0,
            color: cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: subtleColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('备注', style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  )),
                  SizedBox(height: 12),
                  CupertinoTextField(
                    controller: _notesController,
                    placeholder: '添加任务备注...',
                    placeholderStyle: TextStyle(
                      color: theme.hintColor,
                    ),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: subtleColor.withOpacity(0.3),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    style: theme.textTheme.bodyMedium,
                    maxLines: 5,
                    minLines: 3,
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 16),
          
          // 智能建议
          if (_titleController.text.isNotEmpty)
            Card(
              elevation: 0,
              color: isDark ? Color(0xFF0A2647) : Color(0xFFEBF5FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: primaryColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.lightbulb,
                          color: Color(0xFFFFCC00),
                        ),
                        SizedBox(width: 8),
                        Text('智能建议', style: theme.textTheme.titleMedium?.copyWith(
                          color: isDark ? Colors.white : primaryColor,
                          fontWeight: FontWeight.w600,
                        )),
                      ],
                    ),
                    SizedBox(height: 12),
                    ..._getSmartSuggestions().map((suggestion) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: Text(
                          suggestion,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.white.withOpacity(0.8) : Color(0xFF2C3E50),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          
          SizedBox(height: 24),
          
          // 创建时间和删除按钮
          Center(
            child: Column(
              children: [
                Text(
                  _task.createdAt != null 
                      ? '创建于 ${_formatDateTime(_task.createdAt!, isDate: true)}'
                      : '创建于 片刻前',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4),
                  ),
                ),
                SizedBox(height: 16),
                CupertinoButton(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  color: Color(0xFFFF3B30).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(CupertinoIcons.delete, color: Color(0xFFFF3B30)),
                      SizedBox(width: 8),
                      Text('删除任务', style: TextStyle(color: Color(0xFFFF3B30))),
                    ],
                  ),
                  onPressed: _deleteTask,
                ),
              ],
            ),
          ),
          
          SizedBox(height: 24),
        ],
      ),
    );
  }
} 
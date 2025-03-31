import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/quadrant_task.dart';

/// 任务编辑对话框
class TaskEditDialog extends StatefulWidget {
  /// 是否是编辑模式（否则为新建模式）
  final bool isEditing;
  
  /// 要编辑的任务（编辑模式下必须提供）
  final QuadrantTask? task;
  
  /// 默认象限类型（新建模式下可选）
  final QuadrantType? defaultQuadrantType;

  /// 构造函数
  const TaskEditDialog({
    Key? key,
    this.isEditing = false,
    this.task,
    this.defaultQuadrantType,
  }) : super(key: key);

  @override
  State<TaskEditDialog> createState() => _TaskEditDialogState();
}

class _TaskEditDialogState extends State<TaskEditDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _deadlineController;
  late QuadrantType _selectedQuadrantType;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    // 初始化控制器
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _deadlineController = TextEditingController(text: widget.task?.deadline ?? '');
    
    // 初始化选中的象限类型
    _selectedQuadrantType = widget.task?.quadrantType ?? 
                         widget.defaultQuadrantType ?? 
                         QuadrantType.importantUrgent;
    
    // 监听标题输入，验证表单有效性
    _titleController.addListener(_validateForm);
    
    // 初始检查表单有效性
    _validateForm();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _deadlineController.dispose();
    super.dispose();
  }

  /// 验证表单有效性
  void _validateForm() {
    setState(() {
      _isValid = _titleController.text.trim().isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return AlertDialog(
      title: Text(widget.isEditing ? l10n.editTask : l10n.addNewTask),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 任务标题输入
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: l10n.taskTitle,
                border: const OutlineInputBorder(),
              ),
              autofocus: true,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            
            // 截止日期输入
            TextField(
              controller: _deadlineController,
              decoration: InputDecoration(
                labelText: l10n.taskDeadline,
                border: const OutlineInputBorder(),
                hintText: '${l10n.statsToday} / ${l10n.statsThisWeek}',
              ),
            ),
            const SizedBox(height: 16),
            
            // 象限选择
            Text(
              l10n.chooseQuadrant,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            
            // 象限选项列表
            _buildQuadrantOptions(l10n, theme, isDark),
          ],
        ),
      ),
      actions: [
        // 取消按钮
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        
        // 删除按钮（仅编辑模式）
        if (widget.isEditing)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop({'delete': true});
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        
        // 保存按钮
        ElevatedButton(
          onPressed: _isValid
              ? () {
                  final result = {
                    'title': _titleController.text.trim(),
                    'deadline': _deadlineController.text.trim().isEmpty 
                        ? null 
                        : _deadlineController.text.trim(),
                    'quadrantType': _selectedQuadrantType,
                  };
                  Navigator.of(context).pop(result);
                }
              : null,
          child: Text(l10n.save),
        ),
      ],
    );
  }

  /// 构建象限选项
  Widget _buildQuadrantOptions(AppLocalizations l10n, ThemeData theme, bool isDark) {
    return Column(
      children: [
        _buildQuadrantOption(
          l10n.quadrantUrgentImportant,
          QuadrantType.importantUrgent,
          isDark ? Colors.red.shade300 : Colors.red.shade300,
          theme,
        ),
        _buildQuadrantOption(
          l10n.quadrantImportantNotUrgent,
          QuadrantType.importantNotUrgent,
          isDark ? Colors.blue.shade200 : Colors.blue.shade300,
          theme,
        ),
        _buildQuadrantOption(
          l10n.quadrantUrgentNotImportant,
          QuadrantType.urgentNotImportant,
          isDark ? Colors.orange.shade200 : Colors.orange.shade300,
          theme,
        ),
        _buildQuadrantOption(
          l10n.quadrantNotUrgentNotImportant,
          QuadrantType.notImportantNotUrgent,
          isDark ? Colors.green.shade200 : Colors.green.shade300,
          theme,
        ),
      ],
    );
  }

  /// 构建单个象限选项
  Widget _buildQuadrantOption(String title, QuadrantType type, Color color, ThemeData theme) {
    return RadioListTile<QuadrantType>(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          color: _selectedQuadrantType == type ? color : theme.textTheme.bodyMedium?.color,
          fontWeight: _selectedQuadrantType == type ? FontWeight.bold : null,
        ),
      ),
      value: type,
      groupValue: _selectedQuadrantType,
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedQuadrantType = value;
          });
        }
      },
      activeColor: color,
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }
} 
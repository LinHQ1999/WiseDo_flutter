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
        time: l10n.taskTimeDemo,
        priority: l10n.taskPriorityDemo,
        isPriority: true,
      ),
      Task(
        title: l10n.taskTitleReplyEmail,
        deadline: l10n.taskDeadlineEmail,
      ),
    ];
  }
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // 确保任务已初始化
    if (!_initialized) {
      return const Center(child: CircularProgressIndicator()); // 或者其他加载指示器
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HeaderWidget(
            userName: '李明', // 注意：用户名暂时硬编码，可以后续改为动态获取
            dateString: '2025年3月23日 星期日', // 注意：日期信息应动态生成
            weatherInfo: '今天多云转晴，18-24℃', // 注意：天气信息应动态获取
            clothingSuggestion: '建议穿着薄外套出门', // 注意：穿衣建议应动态获取
          ),
          const SizedBox(height: 24),
          _buildPrioritySection(l10n),
          const SizedBox(height: 24),
          _buildTaskSection(l10n),
        ],
      ),
    );
  }

  /// 创建优先建议部分
  Widget _buildPrioritySection(AppLocalizations l10n) {
    final priorityTasks = _tasks.where((task) => task.isPriority).toList();
    
    return SectionCard(
      title: l10n.prioritySuggestion, // 使用本地化字符串
      children: [
        for (int i = 0; i < priorityTasks.length; i++) ...[
          if (i > 0) const Divider(height: 24, thickness: 1),
          TaskItem(
            task: priorityTasks[i],
            onCompletionChanged: (completed) {
              setState(() {
                final index = _tasks.indexWhere(
                  (t) => t.title == priorityTasks[i].title
                );
                if (index != -1) {
                  _tasks[index] = _tasks[index].copyWith(isCompleted: completed);
                }
              });
            },
          ),
        ],
      ],
    );
  }

  /// 创建任务部分
  Widget _buildTaskSection(AppLocalizations l10n) {
    return SectionCard(
      title: l10n.taskSectionTitle, // 使用本地化字符串
      children: [
        for (int i = 0; i < _tasks.length; i++) ...[
          if (i > 0) const Divider(height: 24, thickness: 1),
          TaskItem(
            task: _tasks[i],
            onCompletionChanged: (completed) {
              setState(() {
                _tasks[i] = _tasks[i].copyWith(isCompleted: completed);
              });
            },
          ),
        ],
      ],
    );
  }
} 
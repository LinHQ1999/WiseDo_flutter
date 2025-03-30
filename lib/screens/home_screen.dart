import 'package:flutter/material.dart';
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
  final List<Task> _tasks = [
    Task(
      title: '准备下午的项目演示',
      time: '14:00 - 公司会议室',
      priority: '高优先级',
      isPriority: true,
    ),
    Task(
      title: '回复张总邮件',
      deadline: '今天截止',
    ),
    // 可以添加更多任务...
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HeaderWidget(
            userName: '李明',
            dateString: '2025年3月23日 星期日',
            weatherInfo: '今天多云转晴，18-24℃',
            clothingSuggestion: '建议穿着薄外套出门',
          ),
          const SizedBox(height: 24),
          _buildPrioritySection(),
          const SizedBox(height: 24),
          _buildTaskSection(),
        ],
      ),
    );
  }

  /// 创建优先建议部分
  Widget _buildPrioritySection() {
    final priorityTasks = _tasks.where((task) => task.isPriority).toList();
    
    return SectionCard(
      title: '智能优先建议',
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
  Widget _buildTaskSection() {
    return SectionCard(
      title: '今日任务',
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
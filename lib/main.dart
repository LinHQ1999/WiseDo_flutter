import 'package:flutter/material.dart';
import 'constants/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/quadrant_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/settings_screen.dart';

/// 应用入口
void main() => runApp(const MyApp());

/// 应用主类
class MyApp extends StatefulWidget {
  /// 构造函数
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

/// 应用主类状态
class _MyAppState extends State<MyApp> {
  /// 当前选中的页面索引
  int _currentIndex = 0;
  
  // Track completed state for each task
  final Map<String, bool> _taskCompletion = {
    '准备下午的项目演示': false,
    '回复张总邮件': false,
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '日程助手',
      theme: AppTheme.buildTheme(),
      home: Scaffold(
        appBar: AppBar(title: const Text('日程助手')),
        body: _buildBody(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '首页',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_4x4),
              label: '四象限',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.insert_chart),
              label: '统计',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: '设置',
            ),
          ],
        ),
      ),
    );
  }

  /// 根据当前选中的索引返回对应的页面内容
  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return const HomeScreen();
      case 1:
        return const QuadrantScreen();
      case 2:
        return const StatsScreen();
      case 3:
        return const SettingsScreen();
      default:
        return const HomeScreen();
    }
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '嗨，李明',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          '2025年3月23日 星期日',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.cloud, size: 18),
            const SizedBox(width: 4),
            Text(
              '今天多云转晴，18-24℃',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(width: 8),
            Text(
              '建议穿着薄外套出门',
              style: TextStyle(
                color: Colors.blue[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPrioritySection() {
    return _buildSection(
      title: '智能优先建议',
      children: [
        _buildTaskItem(
          '准备下午的项目演示',
          time: '14:00 - 公司会议室',
        ),
        _buildDivider(),
        _buildTaskItem(
          '回复张总邮件',
          deadline: '今天截止',
        ),
      ],
    );
  }

  Widget _buildTaskSection() {
    return _buildSection(
      title: '今日任务',
      children: [
        _buildTaskItem(
          '准备下午的项目演示',
          time: '14:00 - 公司会议室',
          priority: '高优先级',
          isPriority: true,
        ),
        _buildDivider(),
        _buildTaskItem(
          '回复张总邮件',
          deadline: '今天截止',
        ),
      ],
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Column(children: children),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(String title, {
    String? time,
    String? deadline,
    String? priority,
    bool isPriority = false,
  }) {
    final isCompleted = _taskCompletion[title] ?? false;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: isCompleted,
            onChanged: (value) {
              setState(() {
                _taskCompletion[title] = value ?? false;
              });
            },
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: isPriority ? Colors.red : Colors.black,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (time != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        time,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ],
                if (deadline != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    deadline,
                    style: TextStyle(
                      color: Colors.orange[800],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                if (priority != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    priority,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 24, thickness: 1);
  }
}

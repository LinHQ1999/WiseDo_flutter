import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

/// 四象限屏幕
class QuadrantScreen extends StatelessWidget {
  /// 构造函数
  const QuadrantScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '时间管理四象限',
            style: AppTheme.headerStyle,
          ),
          const SizedBox(height: 16.0),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12.0,
              mainAxisSpacing: 12.0,
              children: [
                _buildQuadrant(
                  '重要且紧急',
                  '立即处理',
                  Colors.red.withOpacity(0.2),
                  const Icon(Icons.priority_high, color: Colors.red),
                ),
                _buildQuadrant(
                  '重要不紧急',
                  '计划处理',
                  Colors.blue.withOpacity(0.2),
                  const Icon(Icons.event, color: Colors.blue),
                ),
                _buildQuadrant(
                  '紧急不重要',
                  '委托他人',
                  Colors.amber.withOpacity(0.2),
                  const Icon(Icons.person_outline, color: Colors.amber),
                ),
                _buildQuadrant(
                  '不重要不紧急',
                  '考虑删除',
                  Colors.grey.withOpacity(0.2),
                  const Icon(Icons.delete_outline, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          const Text('四象限功能完整实现开发中...'),
        ],
      ),
    );
  }

  /// 构建单个象限卡片
  Widget _buildQuadrant(String title, String subtitle, Color color, Icon icon) {
    return Card(
      elevation: 2.0,
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(height: 8.0),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4.0),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12.0,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
} 
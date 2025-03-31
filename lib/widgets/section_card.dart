import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

/// 部分卡片组件
class SectionCard extends StatelessWidget {
  /// 部分标题
  final String title;
  
  /// 子组件列表
  final List<Widget> children;

  /// 构造函数
  const SectionCard({
    Key? key,
    required this.title,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTheme.subHeaderStyle,
            ),
            const SizedBox(height: 12),
            Column(children: children),
          ],
        ),
      ),
    );
  }
} 
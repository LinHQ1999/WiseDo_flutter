import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../constants/app_theme.dart';

/// 四象限屏幕
class QuadrantScreen extends StatelessWidget {
  /// 构造函数
  const QuadrantScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.quadrantTitle,
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
                  context,
                  l10n.quadrantUrgentImportant,
                  l10n.quadrantUrgentImportantAction,
                  Colors.red.withOpacity(0.2),
                  const Icon(Icons.priority_high, color: Colors.red),
                ),
                _buildQuadrant(
                  context,
                  l10n.quadrantImportantNotUrgent,
                  l10n.quadrantImportantNotUrgentAction,
                  Colors.blue.withOpacity(0.2),
                  const Icon(Icons.event, color: Colors.blue),
                ),
                _buildQuadrant(
                  context,
                  l10n.quadrantUrgentNotImportant,
                  l10n.quadrantUrgentNotImportantAction,
                  Colors.amber.withOpacity(0.2),
                  const Icon(Icons.person_outline, color: Colors.amber),
                ),
                _buildQuadrant(
                  context,
                  l10n.quadrantNotUrgentNotImportant,
                  l10n.quadrantNotUrgentNotImportantAction,
                  Colors.grey.withOpacity(0.2),
                  const Icon(Icons.delete_outline, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          Text(l10n.quadrantUnderDevelopment),
        ],
      ),
    );
  }

  /// 构建单个象限卡片
  Widget _buildQuadrant(BuildContext context, String title, String subtitle, Color color, Icon icon) {
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
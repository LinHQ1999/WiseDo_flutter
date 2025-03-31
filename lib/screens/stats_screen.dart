import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../constants/app_theme.dart';

/// 统计屏幕
class StatsScreen extends StatelessWidget {
  /// 构造函数
  const StatsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.statsTitle,
            style: AppTheme.headerStyle,
          ),
          const SizedBox(height: 24),
          _buildStatCard(l10n.statsWeeklyCompleted, '12', Colors.blue),
          const SizedBox(height: 16),
          _buildStatCard(l10n.statsMonthlyCompleted, '45', Colors.green),
          const SizedBox(height: 16),
          _buildStatCard(l10n.statsPending, '5', Colors.orange),
          const SizedBox(height: 24),
          Center(
            child: Text(
              l10n.statsUnderDevelopment,
              style: const TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildCompletionRateCard(context),
        ],
      ),
    );
  }

  /// 构建统计卡片
  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 40,
              color: color,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建完成率卡片
  Widget _buildCompletionRateCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.statsCompletionRate,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildProgressIndicator(l10n.statsToday, 0.75, Colors.blue),
                _buildProgressIndicator(l10n.statsThisWeek, 0.60, Colors.green),
                _buildProgressIndicator(l10n.statsThisMonth, 0.85, Colors.purple),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建圆形进度指示器
  Widget _buildProgressIndicator(String label, double value, Color color) {
    return Column(
      children: [
        SizedBox(
          height: 80,
          width: 80,
          child: Stack(
            children: [
              Center(
                child: SizedBox(
                  height: 80,
                  width: 80,
                  child: CircularProgressIndicator(
                    value: value,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ),
              Center(
                child: Text(
                  '${(value * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }
} 
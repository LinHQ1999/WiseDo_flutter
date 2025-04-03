import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../constants/app_theme.dart';

/// 统计屏幕
class StatsScreen extends StatelessWidget {
  /// 构造函数
  const StatsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(l10n.statsTitle),
        backgroundColor: theme.scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildStatCard(l10n.statsWeeklyCompleted, '12', AppColors.primaryColor),
              const SizedBox(height: 16),
              _buildStatCard(l10n.statsMonthlyCompleted, '45', AppColors.accentColor),
              const SizedBox(height: 16),
              _buildStatCard(l10n.statsPending, '5', AppColors.orangeColor),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  l10n.statsUnderDevelopment,
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildCompletionRateCard(context),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建统计卡片
  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyles.body,
              ),
            ),
            Text(
              value,
              style: TextStyles.title2.copyWith(
                fontWeight: FontWeight.w600,
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
    final theme = Theme.of(context);
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.statsCompletionRate,
              style: TextStyles.headline.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildProgressIndicator(l10n.statsToday, 0.75, AppColors.primaryColor, theme),
                _buildProgressIndicator(l10n.statsThisWeek, 0.60, AppColors.accentColor, theme),
                _buildProgressIndicator(l10n.statsThisMonth, 0.85, AppColors.purpleColor, theme),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建圆形进度指示器
  Widget _buildProgressIndicator(String label, double value, Color color, ThemeData theme) {
    return Column(
      children: [
        SizedBox(
          height: 80,
          width: 80,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 80,
                width: 80,
                child: CircularProgressIndicator(
                  value: value,
                  strokeWidth: 8,
                  backgroundColor: theme.dividerColor.withOpacity(0.5),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Text(
                '${(value * 100).toInt()}%',
                style: TextStyles.subheadline.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyles.caption1.copyWith(
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }
} 
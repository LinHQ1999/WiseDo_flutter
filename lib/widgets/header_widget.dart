import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../constants/app_theme.dart';

/// 头部信息组件
class HeaderWidget extends StatelessWidget {
  /// 用户名称
  final String userName;
  
  /// 日期字符串
  final String dateString;
  
  /// 天气信息
  final String weatherInfo;
  
  /// 穿衣建议
  final String clothingSuggestion;

  /// 构造函数
  const HeaderWidget({
    Key? key,
    required this.userName,
    required this.dateString,
    required this.weatherInfo,
    required this.clothingSuggestion,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // 获取本地化实例
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.helloUser(userName), // 使用本地化字符串
          style: AppTheme.headerStyle,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.dateInfo(dateString), // 使用本地化字符串
          style: AppTheme.subtitleStyle,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.cloud, size: 18),
            const SizedBox(width: 4),
            Text(
              l10n.weatherInfo(weatherInfo), // 使用本地化字符串
              style: AppTheme.subtitleStyle,
            ),
            const SizedBox(width: 8),
            Text(
              l10n.clothingSuggestion(clothingSuggestion), // 使用本地化字符串
              style: AppTheme.highlightStyle,
            ),
          ],
        ),
      ],
    );
  }
} 
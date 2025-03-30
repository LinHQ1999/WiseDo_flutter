import 'package:flutter/material.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '嗨，$userName',
          style: AppTheme.headerStyle,
        ),
        const SizedBox(height: 8),
        Text(
          dateString,
          style: AppTheme.subtitleStyle,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.cloud, size: 18),
            const SizedBox(width: 4),
            Text(
              weatherInfo,
              style: AppTheme.subtitleStyle,
            ),
            const SizedBox(width: 8),
            Text(
              clothingSuggestion,
              style: AppTheme.highlightStyle,
            ),
          ],
        ),
      ],
    );
  }
} 
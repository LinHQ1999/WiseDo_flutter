import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../constants/app_theme.dart';

/// 头部信息组件
class HeaderWidget extends StatelessWidget {
  /// 用户名称
  final String userName;
  
  /// 日期字符串
  final String dateString;

  /// 构造函数
  const HeaderWidget({
    Key? key,
    required this.userName,
    required this.dateString,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // 获取本地化实例
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.helloUser(userName), // 使用本地化字符串
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.titleLarge?.color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.dateInfo(dateString), // 使用本地化字符串
          style: TextStyle(
            fontSize: 14,
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }
} 
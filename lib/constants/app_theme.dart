import 'package:flutter/material.dart';

/// 应用主题相关的常量
class AppTheme {
  // 主题颜色
  static const Color primaryColor = Colors.blue;
  static const Color accentColor = Colors.blueAccent;
  static const Color backgroundColor = Colors.white;
  static const Color cardColor = Colors.white;
  
  // 文本颜色
  static const Color textPrimaryColor = Colors.black;
  static const Color textSecondaryColor = Colors.grey;
  static const Color textHighlightColor = Colors.red;
  
  // 默认字体
  static const String defaultFontFamily = '微软雅黑';
  
  // 文本样式
  static const TextStyle headerStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
  );
  
  static const TextStyle subHeaderStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
  );
  
  static TextStyle subtitleStyle = TextStyle(
    fontSize: 14,
    color: Colors.grey[600],
  );
  
  static TextStyle highlightStyle = TextStyle(
    color: Colors.blue[600],
    fontStyle: FontStyle.italic,
  );
  
  // 创建应用主题
  static ThemeData buildTheme() {
    return ThemeData(
      primaryColor: primaryColor,
      fontFamily: defaultFontFamily,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
} 
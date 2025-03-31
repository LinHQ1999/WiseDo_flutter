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
  
  // 创建浅色主题
  static ThemeData lightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      fontFamily: defaultFontFamily,
      scaffoldBackgroundColor: Colors.grey[50],
      cardColor: Colors.white,
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
  
  // 创建深色主题
  static ThemeData darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      fontFamily: defaultFontFamily,
      scaffoldBackgroundColor: const Color(0xFF121212),
      cardColor: const Color(0xFF1E1E1E),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1F1F1F),
        foregroundColor: Colors.white,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: Colors.lightBlueAccent,
        unselectedItemColor: Colors.grey,
        backgroundColor: Color(0xFF1F1F1F),
      ),
    );
  }
  
  // 兼容旧版本，使用浅色主题
  @deprecated
  static ThemeData buildTheme() {
    return lightTheme();
  }
} 
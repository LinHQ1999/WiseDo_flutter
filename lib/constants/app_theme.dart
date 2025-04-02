import 'package:flutter/material.dart';

/// 尺寸常量 - 用于统一管理应用中的所有尺寸
class Dimens {
  // 字体大小
  static const double fontSizeSmall = 12.0;
  static const double fontSizeRegular = 14.0;
  static const double fontSizeMedium = 16.0;
  static const double fontSizeLarge = 18.0;
  static const double fontSizeXLarge = 24.0;
  static const double fontSizeXXLarge = 32.0;
  
  // 间距
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingRegular = 12.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;
  
  // 圆角
  static const double radiusSmall = 4.0;
  static const double radiusRegular = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;
  
  // 图标尺寸
  static const double iconSizeSmall = 16.0;
  static const double iconSizeRegular = 24.0;
  static const double iconSizeLarge = 32.0;
  
  // 高度
  static const double buttonHeight = 48.0;
  static const double inputHeight = 56.0;
  static const double appBarHeight = 56.0;
  static const double cardElevation = 2.0;
  
  // 其他
  static const double dividerThickness = 0.5;
}

/// 颜色常量 - 统一管理应用中的所有颜色
class AppColors {
  // 主题色
  static const Color primaryColor = Colors.blue;
  static const Color primaryLightColor = Color(0xFF64B5F6); // Colors.blue[300]
  static const Color primaryDarkColor = Color(0xFF1976D2); // Colors.blue[700]
  static const Color accentColor = Colors.blueAccent;
  
  // 背景色
  static const Color backgroundLight = Color(0xFFF5F5F5); // Colors.grey[100]
  static const Color backgroundDark = Color(0xFF121212);
  
  // 卡片色
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF1E1E1E);
  
  // 文本色
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textPrimaryDark = Colors.white;
  static const Color textSecondaryDark = Color(0xFFBDBDBD);
  
  // 功能色
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // 象限颜色
  static const Color importantUrgentLight = Color(0xFFFF5252);
  static const Color importantUrgentDark = Color(0xFFE57373);
  static const Color importantNotUrgentLight = Color(0xFF2196F3);
  static const Color importantNotUrgentDark = Color(0xFF64B5F6);
  static const Color urgentNotImportantLight = Color(0xFFFF9800);
  static const Color urgentNotImportantDark = Color(0xFFFFB74D);
  static const Color notImportantNotUrgentLight = Color(0xFF4CAF50);
  static const Color notImportantNotUrgentDark = Color(0xFF81C784);
}

/// 文本样式常量 - 预定义常用的文本样式
class TextStyles {
  // 标题样式
  static const TextStyle heading1 = TextStyle(
    fontSize: Dimens.fontSizeXXLarge,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle heading2 = TextStyle(
    fontSize: Dimens.fontSizeXLarge,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle heading3 = TextStyle(
    fontSize: Dimens.fontSizeLarge,
    fontWeight: FontWeight.bold,
  );
  
  // 正文样式
  static const TextStyle body1 = TextStyle(
    fontSize: Dimens.fontSizeMedium,
  );
  
  static const TextStyle body2 = TextStyle(
    fontSize: Dimens.fontSizeRegular,
  );
  
  // 次要文本
  static const TextStyle caption = TextStyle(
    fontSize: Dimens.fontSizeSmall,
  );
  
  // 按钮文本
  static const TextStyle button = TextStyle(
    fontSize: Dimens.fontSizeRegular,
    fontWeight: FontWeight.w500,
  );
}

/// 应用主题管理
class AppTheme {
  // 默认字体
  static const String defaultFontFamily = '微软雅黑';
  
  /// 获取文本主题
  static TextTheme _getTextTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final Color primaryTextColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final Color secondaryTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    
    return TextTheme(
      displayLarge: TextStyles.heading1.copyWith(color: primaryTextColor),
      displayMedium: TextStyles.heading2.copyWith(color: primaryTextColor),
      displaySmall: TextStyles.heading3.copyWith(color: primaryTextColor),
      headlineLarge: TextStyles.heading1.copyWith(color: primaryTextColor),
      headlineMedium: TextStyles.heading2.copyWith(color: primaryTextColor),
      headlineSmall: TextStyles.heading3.copyWith(color: primaryTextColor),
      titleLarge: TextStyles.heading3.copyWith(color: primaryTextColor),
      titleMedium: TextStyles.body1.copyWith(color: primaryTextColor),
      titleSmall: TextStyles.body2.copyWith(color: primaryTextColor),
      bodyLarge: TextStyles.body1.copyWith(color: primaryTextColor),
      bodyMedium: TextStyles.body2.copyWith(color: primaryTextColor),
      bodySmall: TextStyles.caption.copyWith(color: secondaryTextColor),
      labelLarge: TextStyles.button.copyWith(color: primaryTextColor),
    );
  }
  
  /// 创建浅色主题
  static ThemeData lightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primaryColor,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryColor,
        secondary: AppColors.accentColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        surface: AppColors.cardLight,
        background: AppColors.backgroundLight,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.backgroundLight,
      cardColor: AppColors.cardLight,
      dividerColor: Colors.grey[300],
      fontFamily: defaultFontFamily,
      textTheme: _getTextTheme(Brightness.light),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: Dimens.cardElevation,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: AppColors.textSecondaryLight,
        backgroundColor: AppColors.cardLight,
        elevation: Dimens.cardElevation,
      ),
      cardTheme: CardTheme(
        elevation: Dimens.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimens.radiusMedium),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimens.radiusRegular),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Dimens.spacingMedium,
          vertical: Dimens.spacingRegular,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(Dimens.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimens.radiusRegular),
          ),
        ),
      ),
    );
  }
  
  /// 创建深色主题
  static ThemeData darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryColor,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryLightColor,
        secondary: AppColors.accentColor,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        surface: AppColors.cardDark,
        background: AppColors.backgroundDark,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      cardColor: AppColors.cardDark,
      dividerColor: Colors.grey[800],
      fontFamily: defaultFontFamily,
      textTheme: _getTextTheme(Brightness.dark),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.cardDark,
        foregroundColor: AppColors.textPrimaryDark,
        elevation: Dimens.cardElevation,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: AppColors.primaryLightColor,
        unselectedItemColor: AppColors.textSecondaryDark,
        backgroundColor: AppColors.cardDark,
        elevation: Dimens.cardElevation,
      ),
      cardTheme: CardTheme(
        elevation: Dimens.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimens.radiusMedium),
        ),
        color: AppColors.cardDark,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimens.radiusRegular),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Dimens.spacingMedium,
          vertical: Dimens.spacingRegular,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(Dimens.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimens.radiusRegular),
          ),
        ),
      ),
    );
  }
  
  /// 获取根据系统设置自动切换的主题模式
  static ThemeMode getThemeMode(bool isDarkMode) {
    return isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }
  
  /// 现有代码兼容方法 (会在未来版本中移除)
  @deprecated
  static ThemeData buildTheme() {
    return lightTheme();
  }
  
  // 兼容旧代码的样式常量，但不推荐使用，请使用 TextStyles 类
  @deprecated
  static const TextStyle headerStyle = TextStyle(
    fontSize: Dimens.fontSizeXLarge,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimaryLight,
  );
  
  @deprecated
  static const TextStyle subHeaderStyle = TextStyle(
    fontSize: Dimens.fontSizeLarge,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimaryLight,
  );
  
  @deprecated
  static TextStyle subtitleStyle = TextStyle(
    fontSize: Dimens.fontSizeRegular,
    color: Colors.grey[600],
  );
  
  @deprecated
  static TextStyle highlightStyle = TextStyle(
    color: Colors.blue[600],
    fontStyle: FontStyle.italic,
  );
} 
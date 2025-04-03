import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

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
  static const double appBarHeight = 44.0; // iOS标准高度
  static const double cardElevation = 0.0; // iOS一般没有阴影
  
  // 其他
  static const double dividerThickness = 0.5;
}

/// 颜色常量 - 统一管理应用中的所有颜色，更新为iOS风格
class AppColors {
  // iOS标准色彩系统
  static const Color primaryColor = Color(0xFF007AFF); // iOS蓝色
  static const Color primaryLightColor = Color(0xFF5AC8FA); // iOS浅蓝色
  static const Color primaryDarkColor = Color(0xFF0062CC); // iOS深蓝色
  static const Color accentColor = Color(0xFF34C759); // iOS绿色
  
  // 辅助色彩
  static const Color redColor = Color(0xFFFF3B30); // iOS红色
  static const Color orangeColor = Color(0xFFFF9500); // iOS橙色
  static const Color yellowColor = Color(0xFFFFCC00); // iOS黄色
  static const Color purpleColor = Color(0xFF5856D6); // iOS紫色
  static const Color pinkColor = Color(0xFFFF2D55); // iOS粉色
  
  // 背景色
  static const Color backgroundLight = Color(0xFFF8F8F8); // iOS浅灰背景
  static const Color backgroundDark = Color(0xFF000000); // iOS深色模式背景
  
  // 卡片色
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF1C1C1E); // iOS深色模式卡片背景
  
  // 文本色
  static const Color textPrimaryLight = Color(0xFF000000);
  static const Color textSecondaryLight = Color(0xFF8E8E93); // iOS次要文本
  static const Color textTertiaryLight = Color(0xFFC7C7CC); // iOS三级文本
  static const Color textPrimaryDark = Colors.white;
  static const Color textSecondaryDark = Color(0xFF8E8E93);
  static const Color textTertiaryDark = Color(0xFF48484A);
  
  // 功能色
  static const Color success = Color(0xFF34C759); // iOS绿色
  static const Color warning = Color(0xFFFF9500); // iOS橙色
  static const Color error = Color(0xFFFF3B30); // iOS红色
  static const Color info = Color(0xFF5AC8FA); // iOS浅蓝色
  
  // 象限颜色
  static const Color importantUrgentLight = Color(0xFFFF3B30); // iOS红色
  static const Color importantUrgentDark = Color(0xFFFF453A);
  static const Color importantNotUrgentLight = Color(0xFF007AFF); // iOS蓝色
  static const Color importantNotUrgentDark = Color(0xFF0A84FF);
  static const Color urgentNotImportantLight = Color(0xFFFF9500); // iOS橙色
  static const Color urgentNotImportantDark = Color(0xFFFF9F0A);
  static const Color notImportantNotUrgentLight = Color(0xFF34C759); // iOS绿色
  static const Color notImportantNotUrgentDark = Color(0xFF30D158);
  
  // 分隔线颜色
  static const Color separatorLight = Color(0xFFE5E5EA); // iOS分隔线
  static const Color separatorDark = Color(0xFF38383A);
}

/// 文本样式常量 - 预定义常用的文本样式，更新为iOS风格
class TextStyles {
  // iOS标题样式
  static const TextStyle largeTitle = TextStyle(
    fontSize: 34.0,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.37,
    height: 1.2,
  );
  
  static const TextStyle title1 = TextStyle(
    fontSize: 28.0,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.36,
    height: 1.2,
  );
  
  static const TextStyle title2 = TextStyle(
    fontSize: 22.0,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.35,
    height: 1.2,
  );
  
  static const TextStyle title3 = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.38,
    height: 1.2,
  );
  
  // 正文样式
  static const TextStyle headline = TextStyle(
    fontSize: 17.0,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.41,
    height: 1.3,
  );
  
  static const TextStyle body = TextStyle(
    fontSize: 17.0,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.24,
    height: 1.3,
  );
  
  static const TextStyle callout = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.32,
    height: 1.3,
  );
  
  static const TextStyle subheadline = TextStyle(
    fontSize: 15.0,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.24,
    height: 1.3,
  );
  
  static const TextStyle footnote = TextStyle(
    fontSize: 13.0,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.08,
    height: 1.2,
  );
  
  static const TextStyle caption1 = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.2,
  );
  
  static const TextStyle caption2 = TextStyle(
    fontSize: 11.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.06,
    height: 1.2,
  );
}

/// 应用主题管理
class AppTheme {
  // 默认字体，使用系统字体
  static const String defaultFontFamily = '.SF Pro Text';
  
  /// 获取文本主题
  static TextTheme _getTextTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final Color primaryTextColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final Color secondaryTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    
    return TextTheme(
      displayLarge: TextStyles.largeTitle.copyWith(color: primaryTextColor),
      displayMedium: TextStyles.title1.copyWith(color: primaryTextColor),
      displaySmall: TextStyles.title2.copyWith(color: primaryTextColor),
      headlineLarge: TextStyles.title1.copyWith(color: primaryTextColor),
      headlineMedium: TextStyles.title2.copyWith(color: primaryTextColor),
      headlineSmall: TextStyles.title3.copyWith(color: primaryTextColor),
      titleLarge: TextStyles.headline.copyWith(color: primaryTextColor),
      titleMedium: TextStyles.body.copyWith(color: primaryTextColor),
      titleSmall: TextStyles.callout.copyWith(color: primaryTextColor),
      bodyLarge: TextStyles.body.copyWith(color: primaryTextColor),
      bodyMedium: TextStyles.callout.copyWith(color: primaryTextColor),
      bodySmall: TextStyles.footnote.copyWith(color: secondaryTextColor),
      labelLarge: TextStyles.subheadline.copyWith(color: primaryTextColor),
    ).apply(
      fontFamily: defaultFontFamily,
    );
  }
  
  /// 创建浅色主题
  static ThemeData lightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primaryColor,
      primarySwatch: Colors.blue,
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
      dividerColor: AppColors.separatorLight,
      indicatorColor: AppColors.primaryColor,
      fontFamily: defaultFontFamily,
      textTheme: _getTextTheme(Brightness.light),
      // iOS风格的AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundLight,
        foregroundColor: AppColors.primaryColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyles.headline.copyWith(
          color: AppColors.textPrimaryLight,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.primaryColor,
        ),
      ),
      // iOS风格的底部导航栏
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: AppColors.textSecondaryLight,
        backgroundColor: AppColors.cardLight,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyles.caption2,
        unselectedLabelStyle: TextStyles.caption2,
      ),
      // 无阴影扁平卡片
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimens.radiusMedium),
          side: const BorderSide(
            color: AppColors.separatorLight,
            width: 0.5,
          ),
        ),
        color: AppColors.cardLight,
        shadowColor: Colors.black.withOpacity(0.1),
      ),
      // iOS风格输入框
      inputDecorationTheme: InputDecorationTheme(
        fillColor: Colors.grey[100],
        filled: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Dimens.spacingMedium,
          vertical: Dimens.spacingRegular,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimens.radiusRegular),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimens.radiusRegular),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimens.radiusRegular),
          borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.0),
        ),
        hintStyle: TextStyles.body.copyWith(
          color: AppColors.textSecondaryLight,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: TextStyles.body.copyWith(
          color: AppColors.primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      // iOS风格按钮
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(Dimens.buttonHeight),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimens.radiusRegular),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: Dimens.spacingMedium,
            vertical: Dimens.spacingRegular,
          ),
          textStyle: TextStyles.body,
        ),
      ),
      // iOS风格文本按钮
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryColor,
          padding: const EdgeInsets.symmetric(
            horizontal: Dimens.spacingMedium,
            vertical: Dimens.spacingRegular,
          ),
          textStyle: TextStyles.body,
        ),
      ),
      // iOS风格滑动组件
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primaryColor,
        inactiveTrackColor: AppColors.primaryColor.withOpacity(0.2),
        thumbColor: AppColors.primaryColor,
        overlayColor: AppColors.primaryColor.withOpacity(0.1),
      ),
      // iOS风格切换开关
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return Colors.white;
          }
          return Colors.white;
        }),
        trackColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.accentColor;
          }
          return Colors.grey[300]!;
        }),
      ),
      // iOS风格进度指示器
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryColor,
      ),
    );
  }
  
  /// 创建深色主题
  static ThemeData darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryColor,
      primarySwatch: Colors.blue,
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
      dividerColor: AppColors.separatorDark,
      indicatorColor: AppColors.primaryLightColor,
      fontFamily: defaultFontFamily,
      textTheme: _getTextTheme(Brightness.dark),
      // iOS风格的AppBar (深色模式)
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.cardDark,
        foregroundColor: AppColors.primaryLightColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyles.headline.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.primaryLightColor,
        ),
      ),
      // iOS风格的底部导航栏 (深色模式)
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: AppColors.primaryLightColor,
        unselectedItemColor: AppColors.textSecondaryDark,
        backgroundColor: AppColors.cardDark,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyles.caption2,
        unselectedLabelStyle: TextStyles.caption2,
      ),
      // 无阴影扁平卡片 (深色模式)
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimens.radiusMedium),
          side: const BorderSide(
            color: AppColors.separatorDark,
            width: 0.5,
          ),
        ),
        color: AppColors.cardDark,
      ),
      // iOS风格输入框 (深色模式)
      inputDecorationTheme: InputDecorationTheme(
        fillColor: Colors.grey[900],
        filled: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Dimens.spacingMedium,
          vertical: Dimens.spacingRegular,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimens.radiusRegular),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimens.radiusRegular),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimens.radiusRegular),
          borderSide: const BorderSide(color: AppColors.primaryLightColor, width: 1.0),
        ),
        hintStyle: TextStyles.body.copyWith(color: AppColors.textSecondaryDark),
      ),
      // iOS风格按钮 (深色模式)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLightColor,
          foregroundColor: Colors.black,
          minimumSize: const Size.fromHeight(Dimens.buttonHeight),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimens.radiusRegular),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: Dimens.spacingMedium,
            vertical: Dimens.spacingRegular,
          ),
          textStyle: TextStyles.body,
        ),
      ),
      // iOS风格文本按钮 (深色模式)
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryLightColor,
          padding: const EdgeInsets.symmetric(
            horizontal: Dimens.spacingMedium,
            vertical: Dimens.spacingRegular,
          ),
          textStyle: TextStyles.body,
        ),
      ),
      // iOS风格滑动组件 (深色模式)
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primaryLightColor,
        inactiveTrackColor: AppColors.primaryLightColor.withOpacity(0.2),
        thumbColor: AppColors.primaryLightColor,
        overlayColor: AppColors.primaryLightColor.withOpacity(0.1),
      ),
      // iOS风格切换开关 (深色模式)
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return Colors.white;
          }
          return Colors.white;
        }),
        trackColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.accentColor;
          }
          return Colors.grey[800]!;
        }),
      ),
      // iOS风格进度指示器 (深色模式)
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryLightColor,
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
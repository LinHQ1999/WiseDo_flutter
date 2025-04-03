import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'services/service_locator.dart';
import 'screens/home_screen.dart';
import 'screens/quadrant_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/settings_screen.dart';
import 'constants/app_theme.dart';

/// 应用入口
void main() async {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();
  
  // 设置系统UI样式（状态栏）
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));
  
  // 优化文本渲染设置
  PaintingBinding.instance.imageCache.maximumSize = 100;
  
  // 初始化服务定位器
  await ServiceLocator.init();
  
  // 运行应用
  runApp(const MyApp());
}

/// 应用主类
class MyApp extends StatefulWidget {
  /// 构造函数
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

/// 应用主类状态
class _MyAppState extends State<MyApp> {
  /// 当前选中的页面索引
  int _currentIndex = 0;
  
  /// 是否正在加载中
  bool _isLoading = true;
  
  /// 当前语言设置
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  /// 初始化应用
  Future<void> _initializeApp() async {
    try {
      // 获取保存的语言设置
      final language = ServiceLocator.preferenceService.language;
      if (language.isNotEmpty) {
        _locale = Locale(language);
      }
      
      // 订阅主题更改
      ServiceLocator.themeService.themeModeStream.listen((mode) {
        setState(() {});
      });
      
      ServiceLocator.themeService.themeDataStream.listen((theme) {
        setState(() {});
      });
      
    } catch (e) {
      debugPrint('初始化应用失败: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CupertinoActivityIndicator()),
        ),
      );
    }
    
    // 获取当前主题设置
    final themeService = ServiceLocator.themeService;
    final isDark = themeService.themeMode == ThemeMode.dark;
    
    return MaterialApp(
      title: 'WiseDo',
      theme: themeService.lightTheme,
      darkTheme: themeService.darkTheme,
      themeMode: themeService.themeMode,
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        // 启用字体缩放以提高清晰度，同时保持合理的大小范围
        final mediaQueryData = MediaQuery.of(context);
        final scale = mediaQueryData.textScaleFactor.clamp(1.0, 1.2);
        
        return MediaQuery(
          data: mediaQueryData.copyWith(
            textScaleFactor: scale,
            boldText: false, // 关闭系统粗体，使用自定义权重
          ),
          child: child!,
        );
      },
      home: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          final theme = Theme.of(context);
          
          // 定义选项卡图标颜色
          final Color activeColor = isDark
              ? theme.primaryColor
              : theme.primaryColor;
          final Color inactiveColor = isDark
              ? theme.textTheme.bodySmall!.color!.withOpacity(0.6)
              : theme.textTheme.bodySmall!.color!.withOpacity(0.6);
          
          return Scaffold(
            body: CupertinoTabScaffold(
              tabBar: CupertinoTabBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
                border: Border(
                  top: BorderSide(
                    color: theme.dividerColor,
                    width: 0.5,
                  ),
                ),
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.home),
                    label: l10n.homeTab,
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.square_grid_2x2),
                    label: l10n.quadrantTab,
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.chart_bar),
                    label: l10n.statsTab,
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.settings),
                    label: l10n.settingsTab,
                  ),
                ],
              ),
              tabBuilder: (context, index) {
                return CupertinoTabView(
                  builder: (context) {
                    return _buildTabContent(index);
                  },
                );
              },
            ),
          );
        }
      ),
    );
  }
  
  /// 构建指定索引的Tab内容
  Widget _buildTabContent(int index) {
    switch (index) {
      case 0:
        return const HomeScreen();
      case 1:
        return const QuadrantScreen();
      case 2:
        return const StatsScreen();
      case 3:
        return SettingsScreen(onLanguageChanged: _changeLanguage);
      default:
        return const HomeScreen();
    }
  }

  /// 更改应用语言
  void _changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
      // 保存语言设置
      ServiceLocator.preferenceService.setLanguage(locale.languageCode);
    });
  }
  
  @override
  void dispose() {
    // 释放所有资源
    super.dispose();
  }
}

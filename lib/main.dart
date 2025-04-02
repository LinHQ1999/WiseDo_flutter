import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'services/service_locator.dart';
import 'screens/home_screen.dart';
import 'screens/quadrant_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/settings_screen.dart';

/// 应用入口
void main() async {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();
  
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
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    
    // 获取当前主题设置
    final themeService = ServiceLocator.themeService;
    
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
      home: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          return Scaffold(
            appBar: AppBar(title: Text(l10n.appTitle)),
            body: _buildBody(),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentIndex,
              type: BottomNavigationBarType.fixed,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home),
                  label: l10n.homeTab,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.grid_4x4),
                  label: l10n.quadrantTab,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.insert_chart),
                  label: l10n.statsTab,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.settings),
                  label: l10n.settingsTab,
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  /// 根据当前选中的索引返回对应的页面内容
  Widget _buildBody() {
    switch (_currentIndex) {
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

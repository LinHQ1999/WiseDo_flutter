import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'constants/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/quadrant_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/settings_screen.dart';

/// 应用入口
void main() => runApp(const MyApp());

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
  /// 当前应用的 Locale
  Locale? _locale;
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Schedule Assistant',
      theme: AppTheme.buildTheme(),
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
    });
  }
}

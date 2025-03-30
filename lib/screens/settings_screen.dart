import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../constants/app_theme.dart';

/// 设置屏幕
class SettingsScreen extends StatefulWidget {
  /// 语言更改回调
  final Function(Locale) onLanguageChanged;

  /// 构造函数
  const SettingsScreen({Key? key, required this.onLanguageChanged}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // 设置项状态
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _soundEnabled = true;
  // 不再需要在本地状态存储语言，改为从 context 获取
  // String _selectedLanguage = 'zh'; 

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = Localizations.localeOf(context); // 获取当前 Locale
    final currentLanguageCode = currentLocale.languageCode; // 获取当前语言代码

    // 支持的语言代码
    final List<String> languageOptions = AppLocalizations.supportedLocales.map((locale) => locale.languageCode).toList();
    
    // 将语言代码映射到显示名称 (确保与 supportedLocales 对应)
    Map<String, String> languageDisplayNames = {
      'zh': '中文',
      'en': 'English',
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.settingsTitle, 
            style: AppTheme.headerStyle,
          ),
          const SizedBox(height: 24),
          _buildSettingsSection(l10n.settingsNotifications, [ 
            _buildSwitchTile(
              l10n.settingsEnableNotifications, 
              l10n.settingsEnableNotificationsDesc, 
              _notificationsEnabled, 
              (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
            _buildSwitchTile(
              l10n.settingsSoundAlerts, 
              l10n.settingsSoundAlertsDesc, 
              _soundEnabled, 
              (value) {
                setState(() {
                  _soundEnabled = value;
                });
              },
            ),
          ]),
          const SizedBox(height: 24),
          _buildSettingsSection(l10n.settingsDisplay, [ 
            _buildSwitchTile(
              l10n.settingsDarkMode, 
              l10n.settingsDarkModeDesc, 
              _darkModeEnabled, 
              (value) {
                setState(() {
                  _darkModeEnabled = value;
                  // TODO: 添加切换主题的逻辑
                });
              },
            ),
            _buildDropdownTile(
              l10n.settingsLanguage, 
              l10n.settingsLanguageDesc, 
              currentLanguageCode, // 使用当前的语言代码
              languageOptions, 
              languageDisplayNames, 
              (value) {
                if (value != null && value != currentLanguageCode) {
                  // 调用回调函数通知 MyApp 更改语言
                  widget.onLanguageChanged(Locale(value)); 
                }
              },
            ),
          ]),
          const SizedBox(height: 24),
          _buildSettingsSection(l10n.settingsAccount, [ // 使用本地化字符串
            _buildActionTile(
              l10n.settingsPersonalInfo, // 使用本地化字符串
              l10n.settingsPersonalInfoDesc, // 使用本地化字符串
              Icons.person, 
              () {
                _showUnderDevelopmentDialog(context); // 传递 context
              },
            ),
            _buildActionTile(
              l10n.settingsSync, // 使用本地化字符串
              l10n.settingsSyncDesc, // 使用本地化字符串
              Icons.sync, 
              () {
                _showUnderDevelopmentDialog(context);
              },
            ),
            _buildActionTile(
              l10n.settingsLogout, // 使用本地化字符串
              l10n.settingsLogoutDesc, // 使用本地化字符串
              Icons.logout, 
              () {
                _showUnderDevelopmentDialog(context);
              },
              color: Colors.red,
            ),
          ]),
          const SizedBox(height: 24),
          Center(
            child: Text(
              l10n.settingsUnderDevelopment, // 使用本地化字符串
              style: const TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              l10n.settingsVersion('1.0.0 (Beta)'), // 使用本地化字符串
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建设置部分
  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Card(
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTheme.subHeaderStyle,
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  /// 构建开关设置项
  Widget _buildSwitchTile(
    String title, 
    String subtitle, 
    bool value, 
    Function(bool) onChanged,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryColor,
      ),
    );
  }
  
  /// 构建下拉选择设置项 
  Widget _buildDropdownTile(
    String title, 
    String subtitle, 
    String value, 
    List<String> options, 
    Map<String, String> displayNames, 
    Function(String?) onChanged,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12),
      ),
      trailing: DropdownButton<String>(
        value: value,
        onChanged: onChanged,
        underline: Container(),
        items: options.map((String optionCode) {
          return DropdownMenuItem<String>(
            value: optionCode,
            child: Text(displayNames[optionCode] ?? optionCode), 
          );
        }).toList(),
      ),
    );
  }

  /// 构建操作设置项
  Widget _buildActionTile(
    String title, 
    String subtitle, 
    IconData icon, 
    VoidCallback onTap, {
    Color? color,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: color ?? AppTheme.primaryColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: color,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  /// 显示"功能开发中"对话框
  void _showUnderDevelopmentDialog(BuildContext context) { 
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.dialogTitleHint), 
        content: Text(l10n.dialogContentUnderDevelopment), 
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.dialogButtonOK), 
          ),
        ],
      ),
    );
  }
} 
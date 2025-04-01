import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
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
  bool _soundEnabled = true;
  // 不再需要在本地状态存储语言，改为从 context 获取
  // String _selectedLanguage = 'zh'; 

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
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
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 24),
          _buildSettingsSection(l10n.settingsNotifications, theme, isDark, [ 
            _buildSwitchTile(
              l10n.settingsEnableNotifications, 
              l10n.settingsEnableNotificationsDesc, 
              _notificationsEnabled,
              theme,
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
              theme,
              (value) {
                setState(() {
                  _soundEnabled = value;
                });
              },
            ),
          ]),
          const SizedBox(height: 24),
          _buildSettingsSection(l10n.settingsDisplay, theme, isDark, [ 
            _buildDropdownTile(
              l10n.settingsLanguage, 
              l10n.settingsLanguageDesc, 
              currentLanguageCode, // 使用当前的语言代码
              languageOptions, 
              languageDisplayNames,
              theme,
              (value) async {
                if (value != null && value != currentLanguageCode) {
                  try {
                    // 保存语言首选项到数据库
                    await DatabaseHelper.instance.setPreference('language', value);
                    // 调用回调函数通知 MyApp 更改语言
                    widget.onLanguageChanged(Locale(value));
                  } catch (e) {
                    debugPrint('保存语言首选项失败: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('保存设置失败，请重试')),
                    );
                  }
                }
              },
            ),
          ]),
          const SizedBox(height: 24),
          _buildSettingsSection(l10n.settingsAccount, theme, isDark, [ // 使用本地化字符串
            _buildActionTile(
              l10n.settingsPersonalInfo, // 使用本地化字符串
              l10n.settingsPersonalInfoDesc, // 使用本地化字符串
              Icons.person,
              theme,
              () {
                _showUnderDevelopmentDialog(context); // 传递 context
              },
            ),
            _buildActionTile(
              l10n.settingsSync, // 使用本地化字符串
              l10n.settingsSyncDesc, // 使用本地化字符串
              Icons.sync,
              theme,
              () {
                _showUnderDevelopmentDialog(context);
              },
            ),
            _buildActionTile(
              l10n.settingsLogout, // 使用本地化字符串
              l10n.settingsLogoutDesc, // 使用本地化字符串
              Icons.logout,
              theme, 
              () {
                _showUnderDevelopmentDialog(context);
              },
              color: isDark ? Colors.red[300] : Colors.red,
            ),
          ]),
          const SizedBox(height: 24),
          Center(
            child: Text(
              l10n.settingsUnderDevelopment, // 使用本地化字符串
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              l10n.settingsVersion('1.0.0 (Beta)'), // 使用本地化字符串
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建设置部分
  Widget _buildSettingsSection(String title, ThemeData theme, bool isDark, List<Widget> children) {
    return Card(
      elevation: 2.0,
      color: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.titleMedium?.color,
              ),
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
    ThemeData theme,
    Function(bool) onChanged,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: TextStyle(color: theme.textTheme.bodyLarge?.color),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: theme.textTheme.bodySmall?.color,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: theme.primaryColor,
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
    ThemeData theme,
    Function(String?) onChanged,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: TextStyle(color: theme.textTheme.bodyLarge?.color),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: theme.textTheme.bodySmall?.color,
        ),
      ),
      trailing: DropdownButton<String>(
        value: value,
        onChanged: onChanged,
        underline: Container(),
        dropdownColor: theme.cardColor,
        items: options.map((String optionCode) {
          return DropdownMenuItem<String>(
            value: optionCode,
            child: Text(
              displayNames[optionCode] ?? optionCode,
              style: TextStyle(color: theme.textTheme.bodyLarge?.color),
            ), 
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
    ThemeData theme,
    VoidCallback onTap, {
    Color? color,
  }) {
    final iconColor = color ?? theme.primaryColor;
    
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: iconColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? theme.textTheme.bodyLarge?.color,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: theme.textTheme.bodySmall?.color,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: theme.iconTheme.color?.withOpacity(0.7),
      ),
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

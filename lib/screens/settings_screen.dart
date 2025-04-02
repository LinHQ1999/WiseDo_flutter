import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../services/service_locator.dart';
import '../services/preference_service.dart';
import '../services/theme_service.dart';

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
  // 偏好设置服务
  final _preferenceService = ServiceLocator.preferenceService;
  
  // 主题服务
  final _themeService = ServiceLocator.themeService;
  
  // 设置项状态
  late bool _notificationsEnabled;
  late bool _soundEnabled;
  late bool _darkModeEnabled;

  @override
  void initState() {
    super.initState();
    // 从偏好设置服务获取当前设置
    _loadPreferences();
    
    // 监听偏好设置变更
    _preferenceService.preferencesStream.listen((_) {
      _loadPreferences();
    });
  }
  
  /// 加载偏好设置
  void _loadPreferences() {
    setState(() {
      _notificationsEnabled = _preferenceService.get<bool>(PreferenceKeys.notificationsEnabled) ?? true;
      _soundEnabled = _preferenceService.get<bool>('soundEnabled') ?? true;
      _darkModeEnabled = _preferenceService.isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentLocale = Localizations.localeOf(context);
    final currentLanguageCode = currentLocale.languageCode;

    // 支持的语言代码
    final List<String> languageOptions = AppLocalizations.supportedLocales.map((locale) => locale.languageCode).toList();
    
    // 将语言代码映射到显示名称
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
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // 通知设置部分
          _buildSettingsSection(
            l10n.settingsNotifications, 
            theme, 
            isDark, 
            [ 
              _buildSwitchTile(
                l10n.settingsEnableNotifications, 
                l10n.settingsEnableNotificationsDesc, 
                _notificationsEnabled,
                theme,
                (value) async {
                  await _preferenceService.set(PreferenceKeys.notificationsEnabled, value);
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
                (value) async {
                  await _preferenceService.set('soundEnabled', value);
                  setState(() {
                    _soundEnabled = value;
                  });
                },
              ),
            ]
          ),
          const SizedBox(height: 24),
          
          // 显示设置部分
          _buildSettingsSection(
            l10n.settingsDisplay, 
            theme, 
            isDark, 
            [ 
              _buildSwitchTile(
                l10n.settingsDarkMode, 
                l10n.settingsDarkModeDesc, 
                _darkModeEnabled,
                theme,
                (value) async {
                  await _themeService.setDarkMode(value);
                  setState(() {
                    _darkModeEnabled = value;
                  });
                },
              ),
              _buildDropdownTile(
                l10n.settingsLanguage, 
                l10n.settingsLanguageDesc, 
                currentLanguageCode,
                languageOptions, 
                languageDisplayNames,
                theme,
                (value) async {
                  if (value != null && value != currentLanguageCode) {
                    await _preferenceService.setLanguage(value);
                    widget.onLanguageChanged(Locale(value));
                  }
                },
              ),
            ]
          ),
          const SizedBox(height: 24),
          
          // 任务设置部分
          _buildSettingsSection(
            l10n.settingsTaskManagement, 
            theme, 
            isDark, 
            [ 
              _buildSwitchTile(
                l10n.settingsShowCompletedTasks, 
                l10n.settingsShowCompletedTasksDesc, 
                _preferenceService.get<bool>(PreferenceKeys.showCompletedTasks) ?? true,
                theme,
                (value) async {
                  await _preferenceService.set(PreferenceKeys.showCompletedTasks, value);
                  setState(() {});
                },
              ),
              _buildSwitchTile(
                l10n.settingsAutoDeleteCompleted, 
                l10n.settingsAutoDeleteCompletedDesc, 
                _preferenceService.get<bool>(PreferenceKeys.autoDeleteCompleted) ?? false,
                theme,
                (value) async {
                  await _preferenceService.set(PreferenceKeys.autoDeleteCompleted, value);
                  setState(() {});
                },
              ),
            ]
          ),
          const SizedBox(height: 24),
          
          // 账户设置部分
          _buildSettingsSection(
            l10n.settingsAccount, 
            theme, 
            isDark, 
            [ 
              _buildActionTile(
                l10n.settingsPersonalInfo, 
                l10n.settingsPersonalInfoDesc, 
                Icons.person,
                theme,
                () {
                  _showUnderDevelopmentDialog(context);
                },
              ),
              _buildActionTile(
                l10n.settingsSync, 
                l10n.settingsSyncDesc, 
                Icons.sync,
                theme,
                () {
                  _showUnderDevelopmentDialog(context);
                },
              ),
              _buildActionTile(
                l10n.settingsLogout, 
                l10n.settingsLogoutDesc, 
                Icons.logout,
                theme, 
                () {
                  _showUnderDevelopmentDialog(context);
                },
                color: isDark ? Colors.red[300] : Colors.red,
              ),
            ]
          ),
          const SizedBox(height: 24),
          
          // 关于部分
          _buildSettingsSection(
            l10n.settingsAbout, 
            theme, 
            isDark, 
            [ 
              _buildActionTile(
                l10n.settingsPrivacyPolicy, 
                l10n.settingsPrivacyPolicyDesc, 
                Icons.privacy_tip,
                theme,
                () {
                  _showUnderDevelopmentDialog(context);
                },
              ),
              _buildActionTile(
                l10n.settingsTermsOfService, 
                l10n.settingsTermsOfServiceDesc, 
                Icons.description,
                theme,
                () {
                  _showUnderDevelopmentDialog(context);
                },
              ),
              _buildActionTile(
                l10n.settingsFeedback, 
                l10n.settingsFeedbackDesc, 
                Icons.feedback,
                theme,
                () {
                  _showUnderDevelopmentDialog(context);
                },
              ),
            ]
          ),
          const SizedBox(height: 24),
          
          // 版本信息
          Center(
            child: Text(
              l10n.settingsUnderDevelopment,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              l10n.settingsVersion('1.0.0 (Beta)'),
              style: theme.textTheme.bodySmall?.copyWith(
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
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
        style: theme.textTheme.bodyLarge,
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall,
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
        style: theme.textTheme.bodyLarge,
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall,
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
              style: theme.textTheme.bodyMedium,
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
        style: theme.textTheme.bodyLarge?.copyWith(
          color: color,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall,
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

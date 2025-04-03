import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../services/service_locator.dart';
import '../services/preference_service.dart';
import '../services/theme_service.dart';
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

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(l10n.settingsTitle),
        backgroundColor: theme.scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          children: [
            const SizedBox(height: 16),
            
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
            
            // 账户设置部分
            _buildSettingsSection(
              l10n.settingsAccount, 
              theme, 
              isDark, 
              [ 
                _buildActionTile(
                  l10n.settingsPersonalInfo, 
                  l10n.settingsPersonalInfoDesc, 
                  CupertinoIcons.person_crop_circle,
                  theme,
                  () {
                    _showUnderDevelopmentDialog(context);
                  },
                ),
                _buildActionTile(
                  l10n.settingsSync, 
                  l10n.settingsSyncDesc, 
                  CupertinoIcons.cloud_upload,
                  theme,
                  () {
                    _showUnderDevelopmentDialog(context);
                  },
                ),
                _buildActionTile(
                  l10n.settingsLogout, 
                  l10n.settingsLogoutDesc, 
                  CupertinoIcons.square_arrow_left,
                  theme, 
                  () {
                    _showUnderDevelopmentDialog(context);
                  },
                  color: AppColors.redColor,
                ),
              ]
            ),
            
            // 关于部分
            _buildSettingsSection(
              l10n.settingsAbout, 
              theme, 
              isDark, 
              [ 
                _buildActionTile(
                  l10n.settingsPrivacyPolicy, 
                  l10n.settingsPrivacyPolicyDesc, 
                  CupertinoIcons.lock_shield,
                  theme,
                  () {
                    _showUnderDevelopmentDialog(context);
                  },
                ),
                _buildActionTile(
                  l10n.settingsTermsOfService, 
                  l10n.settingsTermsOfServiceDesc, 
                  CupertinoIcons.doc_text,
                  theme,
                  () {
                    _showUnderDevelopmentDialog(context);
                  },
                ),
                _buildActionTile(
                  l10n.settingsFeedback, 
                  l10n.settingsFeedbackDesc, 
                  CupertinoIcons.bubble_left_bubble_right,
                  theme,
                  () {
                    _showUnderDevelopmentDialog(context);
                  },
                ),
              ]
            ),
          ]
        )
      ),
    );
  }

  /// 构建设置项分组
  Widget _buildSettingsSection(
    String title,
    ThemeData theme,
    bool isDark,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey[400] : Colors.grey[700],
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
              width: 0.5,
            ),
          ),
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: children.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              indent: 16,
              color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
            ),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: children[index],
              );
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  /// 构建带开关的设置项
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
      trailing: CupertinoSwitch(
        value: value,
        onChanged: onChanged,
        activeColor: theme.colorScheme.secondary, // 使用iOS绿色作为激活颜色
      ),
    );
  }

  /// 构建带下拉菜单的设置项
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
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          showCupertinoModalPopup(
            context: context,
            builder: (context) {
              return Container(
                height: 216,
                padding: const EdgeInsets.only(top: 6.0),
                margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                color: CupertinoColors.systemBackground.resolveFrom(context),
                child: SafeArea(
                  top: false,
                  child: CupertinoPicker(
                    itemExtent: 32.0,
                    scrollController: FixedExtentScrollController(
                      initialItem: options.indexOf(value),
                    ),
                    onSelectedItemChanged: (int index) {
                      onChanged(options[index]);
                    },
                    children: options.map((String optionCode) {
                      return Center(
                        child: Text(
                          displayNames[optionCode] ?? optionCode,
                          style: TextStyle(
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          );
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              displayNames[value] ?? value,
              style: TextStyle(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              CupertinoIcons.right_chevron,
              size: 16,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
            ),
          ],
        ),
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
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 20,
        ),
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
        CupertinoIcons.right_chevron,
        size: 16,
        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
      ),
      onTap: onTap,
    );
  }

  /// 显示"正在开发中"对话框
  void _showUnderDevelopmentDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(l10n.dialogTitleHint),
          content: Text(l10n.dialogContentUnderDevelopment),
          actions: [
            CupertinoDialogAction(
              child: Text(l10n.dialogButtonOK),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }
} 

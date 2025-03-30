import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

/// 设置屏幕
class SettingsScreen extends StatefulWidget {
  /// 构造函数
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // 设置项状态
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _soundEnabled = true;
  String _selectedLanguage = '中文';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '应用设置',
            style: AppTheme.headerStyle,
          ),
          const SizedBox(height: 24),
          _buildSettingsSection('通知设置', [
            _buildSwitchTile(
              '开启通知', 
              '打开后会收到任务提醒',
              _notificationsEnabled, 
              (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
            _buildSwitchTile(
              '声音提醒', 
              '任务提醒时播放声音',
              _soundEnabled, 
              (value) {
                setState(() {
                  _soundEnabled = value;
                });
              },
            ),
          ]),
          const SizedBox(height: 24),
          _buildSettingsSection('显示设置', [
            _buildSwitchTile(
              '深色模式', 
              '使用深色主题',
              _darkModeEnabled, 
              (value) {
                setState(() {
                  _darkModeEnabled = value;
                });
              },
            ),
            _buildDropdownTile(
              '语言设置', 
              '更改应用显示语言',
              _selectedLanguage, 
              ['中文', 'English', '日本語'], 
              (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
              },
            ),
          ]),
          const SizedBox(height: 24),
          _buildSettingsSection('账号设置', [
            _buildActionTile(
              '个人信息', 
              '查看和修改您的个人信息',
              Icons.person, 
              () {
                // 处理个人信息点击
                _showUnderDevelopmentDialog();
              },
            ),
            _buildActionTile(
              '同步设置', 
              '数据同步与备份',
              Icons.sync, 
              () {
                // 处理同步设置点击
                _showUnderDevelopmentDialog();
              },
            ),
            _buildActionTile(
              '注销登录', 
              '退出当前账号',
              Icons.logout, 
              () {
                // 处理注销登录点击
                _showUnderDevelopmentDialog();
              },
              color: Colors.red,
            ),
          ]),
          const SizedBox(height: 24),
          const Center(
            child: Text(
              '设置功能完整实现开发中...',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              '版本：1.0.0 (Beta)',
              style: TextStyle(
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
        items: options.map((String option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option),
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
  void _showUnderDevelopmentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('提示'),
        content: const Text('该功能正在开发中，敬请期待！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
} 
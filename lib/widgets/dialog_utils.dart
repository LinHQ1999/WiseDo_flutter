import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DialogUtils {
  /// 显示iOS风格的确认对话框
  static Future<bool> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = '确认',
    String cancelText = '取消',
  }) async {
    final result = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 17.0, 
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
        ),
        content: Text(
          content,
          style: const TextStyle(
            fontSize: 15.0, 
            fontWeight: FontWeight.w500,
            height: 1.3,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              cancelText,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              confirmText,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// 显示iOS风格的信息对话框
  static Future<void> showInfoDialog({
    required BuildContext context,
    required String title,
    required String content,
    String buttonText = '确定',
  }) async {
    await showCupertinoDialog<void>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 17.0, 
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
        ),
        content: Text(
          content,
          style: const TextStyle(
            fontSize: 15.0, 
            fontWeight: FontWeight.w500,
            height: 1.3,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context),
            child: Text(
              buttonText,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 显示iOS风格的底部菜单
  static Future<T?> showActionSheet<T>({
    required BuildContext context,
    required String title,
    required List<SheetAction<T>> actions,
  }) async {
    return await showCupertinoModalPopup<T>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15.0, 
            fontWeight: FontWeight.w500,
            color: Color(0xFF8E8E93),
            height: 1.3,
          ),
        ),
        actions: actions.map((action) => CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context, action.value),
          isDestructiveAction: action.isDestructive,
          isDefaultAction: action.isDefault,
          child: Text(
            action.text,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: action.isDefault ? FontWeight.w600 : FontWeight.w500,
              color: action.isDestructive ? CupertinoColors.destructiveRed : null,
              height: 1.3,
            ),
          ),
        )).toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            '取消',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
        ),
      ),
    );
  }
}

/// 操作表项
class SheetAction<T> {
  final String text;
  final T value;
  final bool isDestructive;
  final bool isDefault;

  SheetAction({
    required this.text,
    required this.value,
    this.isDestructive = false,
    this.isDefault = false,
  });
} 
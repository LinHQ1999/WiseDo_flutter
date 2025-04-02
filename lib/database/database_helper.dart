import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task.dart';
import '../models/base_model.dart';

/// 数据库常量
class DatabaseConstants {
  // 数据库名称和版本
  static const String databaseName = 'wisedo.db';
  static const int databaseVersion = 2;
  
  // 表名
  static const String tasksTable = 'tasks';
  static const String preferencesTable = 'preferences';
  
  // 任务表的列名
  static const String columnId = 'id';
  static const String columnTitle = 'title';
  static const String columnTime = 'time';
  static const String columnDeadline = 'deadline';
  static const String columnReminderTime = 'reminderTime';
  static const String columnPriority = 'priority';
  static const String columnIsPriority = 'isPriority';
  static const String columnIsCompleted = 'isCompleted';
  static const String columnStatus = 'status';
  static const String columnCreatedAt = 'createdAt';
  static const String columnUpdatedAt = 'updatedAt';
  
  // 偏好表的列名
  static const String prefColumnId = 'id';
  static const String prefColumnKey = 'key';
  static const String prefColumnValue = 'value';
  
  // 一些常用的偏好键
  static const String prefKeyDarkMode = 'darkMode';
  static const String prefKeyLanguage = 'language';
  static const String prefKeyNotification = 'notification';
}

/// 数据库异常
class DatabaseException implements Exception {
  final String message;
  final Exception? cause;
  
  DatabaseException(this.message, [this.cause]);
  
  @override
  String toString() => 'DatabaseException: $message${cause != null ? ' (Cause: $cause)' : ''}';
}

/// 数据库辅助类 - 单例模式
class DatabaseHelper {
  // 单例实例
  static final DatabaseHelper instance = DatabaseHelper._init();
  
  // 数据库实例
  static Database? _database;
  
  // 私有构造函数，确保单例模式
  DatabaseHelper._init();
  
  /// 获取数据库实例 (如果不存在则初始化)
  Future<Database> get database async {
    if (_database != null && _database!.isOpen) return _database!;
    
    try {
      _database = await _initDatabase();
      return _database!;
    } catch (e) {
      debugPrint('数据库初始化失败: $e');
      throw DatabaseException('数据库初始化失败', e is Exception ? e : null);
    }
  }
  
  /// 初始化数据库
  Future<Database> _initDatabase() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, DatabaseConstants.databaseName);
      
      return await openDatabase(
        path,
        version: DatabaseConstants.databaseVersion,
        onCreate: _createDatabase,
        onUpgrade: _upgradeDatabase,
      );
    } catch (e) {
      debugPrint('数据库打开失败: $e');
      throw DatabaseException('数据库打开失败', e is Exception ? e : null);
    }
  }
  
  /// 创建数据库表
  Future<void> _createDatabase(Database db, int version) async {
    try {
      // 创建任务表
      await db.execute('''
        CREATE TABLE ${DatabaseConstants.tasksTable} (
          ${DatabaseConstants.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
          ${DatabaseConstants.columnTitle} TEXT NOT NULL,
          ${DatabaseConstants.columnTime} TEXT,
          ${DatabaseConstants.columnDeadline} TEXT,
          ${DatabaseConstants.columnReminderTime} TEXT,
          ${DatabaseConstants.columnPriority} TEXT,
          ${DatabaseConstants.columnIsPriority} INTEGER DEFAULT 0,
          ${DatabaseConstants.columnIsCompleted} INTEGER DEFAULT 0,
          ${DatabaseConstants.columnStatus} INTEGER DEFAULT 0,
          ${DatabaseConstants.columnCreatedAt} TEXT,
          ${DatabaseConstants.columnUpdatedAt} TEXT
        )
      ''');
      
      // 创建偏好表
      await db.execute('''
        CREATE TABLE ${DatabaseConstants.preferencesTable} (
          ${DatabaseConstants.prefColumnId} INTEGER PRIMARY KEY AUTOINCREMENT,
          ${DatabaseConstants.prefColumnKey} TEXT NOT NULL UNIQUE,
          ${DatabaseConstants.prefColumnValue} TEXT
        )
      ''');
      
      // 创建索引
      await db.execute(
        'CREATE INDEX idx_tasks_completed ON ${DatabaseConstants.tasksTable} (${DatabaseConstants.columnIsCompleted})'
      );
      
      debugPrint('数据库表创建成功');
    } catch (e) {
      debugPrint('创建数据库表失败: $e');
      throw DatabaseException('创建数据库表失败', e is Exception ? e : null);
    }
  }
  
  /// 升级数据库
  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    try {
      debugPrint('数据库升级: 从 $oldVersion 升级到 $newVersion');
      
      if (oldVersion < 2) {
        // 版本1升级到版本2：添加提醒时间列
        await db.execute(
          'ALTER TABLE ${DatabaseConstants.tasksTable} ADD COLUMN ${DatabaseConstants.columnReminderTime} TEXT'
        );
        debugPrint('数据库升级: 已添加提醒时间列');
      }
      
      // 其他版本升级逻辑...
      
    } catch (e) {
      debugPrint('数据库升级失败: $e');
      throw DatabaseException('数据库升级失败', e is Exception ? e : null);
    }
  }
  
  /// 关闭数据库连接
  Future<void> close() async {
    try {
      final db = await instance.database;
      await db.close();
      _database = null;
      debugPrint('数据库连接已关闭');
    } catch (e) {
      debugPrint('关闭数据库连接失败: $e');
    }
  }
  
  // ============================== 任务操作方法 ==============================
  
  /// 创建新任务
  Future<int> createTask(Task task) async {
    try {
      final db = await instance.database;
      
      // 设置创建和更新时间
      final now = DateTime.now().toIso8601String();
      final taskMap = task.toMap();
      taskMap[DatabaseConstants.columnCreatedAt] = now;
      taskMap[DatabaseConstants.columnUpdatedAt] = now;
      
      final id = await db.insert(
        DatabaseConstants.tasksTable, 
        taskMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      debugPrint('任务创建成功: ID=$id');
      return id;
    } catch (e) {
      debugPrint('创建任务失败: $e');
      throw DatabaseException('创建任务失败', e is Exception ? e : null);
    }
  }
  
  /// 获取所有任务
  Future<List<Task>> readAllTasks() async {
    try {
      final db = await instance.database;
      
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseConstants.tasksTable,
        orderBy: '${DatabaseConstants.columnUpdatedAt} DESC',
      );
      
      return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
    } catch (e) {
      debugPrint('读取任务列表失败: $e');
      throw DatabaseException('读取任务列表失败', e is Exception ? e : null);
    }
  }
  
  /// 根据ID获取任务
  Future<Task?> readTask(int id) async {
    try {
      final db = await instance.database;
      
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseConstants.tasksTable,
        where: '${DatabaseConstants.columnId} = ?',
        whereArgs: [id],
        limit: 1,
      );
      
      if (maps.isNotEmpty) {
        return Task.fromMap(maps.first);
      } else {
        debugPrint('未找到任务: ID=$id');
        return null;
      }
    } catch (e) {
      debugPrint('读取任务失败: $e');
      throw DatabaseException('读取任务失败', e is Exception ? e : null);
    }
  }
  
  /// 更新任务
  Future<int> updateTask(Task task) async {
    try {
      if (task.id == null) {
        throw DatabaseException('更新任务失败: 任务ID不能为空');
      }
      
      final db = await instance.database;
      
      // 设置更新时间
      final taskMap = task.toMap();
      taskMap[DatabaseConstants.columnUpdatedAt] = DateTime.now().toIso8601String();
      
      final rowsAffected = await db.update(
        DatabaseConstants.tasksTable,
        taskMap,
        where: '${DatabaseConstants.columnId} = ?',
        whereArgs: [task.id],
      );
      
      debugPrint('任务更新成功: ID=${task.id}, 更新行数=$rowsAffected');
      return rowsAffected;
    } catch (e) {
      debugPrint('更新任务失败: $e');
      throw DatabaseException('更新任务失败', e is Exception ? e : null);
    }
  }
  
  /// 更新任务完成状态
  Future<int> updateTaskCompletion(int id, bool isCompleted) async {
    try {
      final db = await instance.database;
      
      final rowsAffected = await db.update(
        DatabaseConstants.tasksTable,
        {
          DatabaseConstants.columnIsCompleted: dbBoolToInt(isCompleted),
          DatabaseConstants.columnStatus: isCompleted ? TaskStatus.completed.index : TaskStatus.pending.index,
          DatabaseConstants.columnUpdatedAt: DateTime.now().toIso8601String(),
        },
        where: '${DatabaseConstants.columnId} = ?',
        whereArgs: [id],
      );
      
      debugPrint('任务完成状态更新成功: ID=$id, isCompleted=$isCompleted, 更新行数=$rowsAffected');
      return rowsAffected;
    } catch (e) {
      debugPrint('更新任务完成状态失败: $e');
      throw DatabaseException('更新任务完成状态失败', e is Exception ? e : null);
    }
  }
  
  /// 删除任务
  Future<int> deleteTask(int id) async {
    try {
      final db = await instance.database;
      
      final rowsAffected = await db.delete(
        DatabaseConstants.tasksTable,
        where: '${DatabaseConstants.columnId} = ?',
        whereArgs: [id],
      );
      
      debugPrint('任务删除成功: ID=$id, 删除行数=$rowsAffected');
      return rowsAffected;
    } catch (e) {
      debugPrint('删除任务失败: $e');
      throw DatabaseException('删除任务失败', e is Exception ? e : null);
    }
  }
  
  /// 获取已完成的任务
  Future<List<Task>> readCompletedTasks() async {
    try {
      final db = await instance.database;
      
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseConstants.tasksTable,
        where: '${DatabaseConstants.columnIsCompleted} = ?',
        whereArgs: [1],
        orderBy: '${DatabaseConstants.columnUpdatedAt} DESC',
      );
      
      return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
    } catch (e) {
      debugPrint('读取已完成任务列表失败: $e');
      throw DatabaseException('读取已完成任务列表失败', e is Exception ? e : null);
    }
  }
  
  /// 获取待完成的任务
  Future<List<Task>> readPendingTasks() async {
    try {
      final db = await instance.database;
      
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseConstants.tasksTable,
        where: '${DatabaseConstants.columnIsCompleted} = ?',
        whereArgs: [0],
        orderBy: '${DatabaseConstants.columnIsPriority} DESC, ${DatabaseConstants.columnUpdatedAt} DESC',
      );
      
      return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
    } catch (e) {
      debugPrint('读取待完成任务列表失败: $e');
      throw DatabaseException('读取待完成任务列表失败', e is Exception ? e : null);
    }
  }
  
  /// 获取高优先级任务
  Future<List<Task>> readPriorityTasks() async {
    try {
      final db = await instance.database;
      
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseConstants.tasksTable,
        where: '${DatabaseConstants.columnIsPriority} = ? AND ${DatabaseConstants.columnIsCompleted} = ?',
        whereArgs: [1, 0],
        orderBy: '${DatabaseConstants.columnUpdatedAt} DESC',
      );
      
      return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
    } catch (e) {
      debugPrint('读取高优先级任务列表失败: $e');
      throw DatabaseException('读取高优先级任务列表失败', e is Exception ? e : null);
    }
  }
  
  // ============================== 偏好设置操作方法 ==============================
  
  /// 设置偏好
  Future<int> setPreference(String key, String value) async {
    try {
      final db = await instance.database;
      
      final id = await db.insert(
        DatabaseConstants.preferencesTable,
        {
          DatabaseConstants.prefColumnKey: key,
          DatabaseConstants.prefColumnValue: value,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      debugPrint('偏好设置成功: key=$key, value=$value');
      return id;
    } catch (e) {
      debugPrint('设置偏好失败: $e');
      throw DatabaseException('设置偏好失败', e is Exception ? e : null);
    }
  }
  
  /// 获取偏好
  Future<String?> getPreference(String key) async {
    try {
      final db = await instance.database;
      
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseConstants.preferencesTable,
        columns: [DatabaseConstants.prefColumnValue],
        where: '${DatabaseConstants.prefColumnKey} = ?',
        whereArgs: [key],
        limit: 1,
      );
      
      if (maps.isNotEmpty) {
        return maps.first[DatabaseConstants.prefColumnValue] as String?;
      } else {
        debugPrint('未找到偏好: key=$key');
        return null;
      }
    } catch (e) {
      debugPrint('获取偏好失败: $e');
      throw DatabaseException('获取偏好失败', e is Exception ? e : null);
    }
  }
  
  /// 获取所有偏好
  Future<Map<String, String>> getAllPreferences() async {
    try {
      final db = await instance.database;
      
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseConstants.preferencesTable,
      );
      
      final Map<String, String> preferences = {};
      for (var map in maps) {
        final key = map[DatabaseConstants.prefColumnKey] as String;
        final value = map[DatabaseConstants.prefColumnValue] as String?;
        if (value != null) {
          preferences[key] = value;
        }
      }
      
      return preferences;
    } catch (e) {
      debugPrint('获取所有偏好失败: $e');
      throw DatabaseException('获取所有偏好失败', e is Exception ? e : null);
    }
  }
  
  /// 删除偏好
  Future<int> deletePreference(String key) async {
    try {
      final db = await instance.database;
      
      final rowsAffected = await db.delete(
        DatabaseConstants.preferencesTable,
        where: '${DatabaseConstants.prefColumnKey} = ?',
        whereArgs: [key],
      );
      
      debugPrint('偏好删除成功: key=$key, 删除行数=$rowsAffected');
      return rowsAffected;
    } catch (e) {
      debugPrint('删除偏好失败: $e');
      throw DatabaseException('删除偏好失败', e is Exception ? e : null);
    }
  }
  
  // ============================== 统计查询方法 ==============================
  
  /// 获取任务总数
  Future<int> getTaskCount() async {
    try {
      final db = await instance.database;
      
      final List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM ${DatabaseConstants.tasksTable}'
      );
      
      return result.first['count'] as int;
    } catch (e) {
      debugPrint('获取任务总数失败: $e');
      throw DatabaseException('获取任务总数失败', e is Exception ? e : null);
    }
  }
  
  /// 获取已完成任务数
  Future<int> getCompletedTaskCount() async {
    try {
      final db = await instance.database;
      
      final List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM ${DatabaseConstants.tasksTable} WHERE ${DatabaseConstants.columnIsCompleted} = 1'
      );
      
      return result.first['count'] as int;
    } catch (e) {
      debugPrint('获取已完成任务数失败: $e');
      throw DatabaseException('获取已完成任务数失败', e is Exception ? e : null);
    }
  }
  
  /// 获取待完成任务数
  Future<int> getPendingTaskCount() async {
    try {
      final db = await instance.database;
      
      final List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM ${DatabaseConstants.tasksTable} WHERE ${DatabaseConstants.columnIsCompleted} = 0'
      );
      
      return result.first['count'] as int;
    } catch (e) {
      debugPrint('获取待完成任务数失败: $e');
      throw DatabaseException('获取待完成任务数失败', e is Exception ? e : null);
    }
  }
}

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../models/task.dart';
import '../models/quadrant_task.dart';

/// 任务服务类
/// 
/// 负责处理与任务相关的所有业务逻辑，包括任务创建、更新、删除、查询等操作
/// 使用单例模式确保全局只有一个实例
class TaskService {
  // 单例实例
  static final TaskService instance = TaskService._internal();
  
  // 数据库辅助类实例
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  
  // 流控制器，用于任务列表的实时更新
  final _taskStreamController = StreamController<List<Task>>.broadcast();
  
  // 缓存的任务列表
  List<Task> _cachedTasks = [];
  
  // 任务流，可被多个UI组件订阅，实现实时更新
  Stream<List<Task>> get taskStream => _taskStreamController.stream;
  
  // 最近一次更新时间
  DateTime _lastRefreshTime = DateTime.now();
  
  // 私有构造函数，确保单例模式
  TaskService._internal();
  
  /// 初始化服务
  Future<void> init() async {
    try {
      // 加载所有任务到缓存
      await refreshTasks();
      
      debugPrint('任务服务初始化完成');
    } catch (e) {
      debugPrint('初始化任务服务失败: $e');
      // 重新发布一个空列表，防止UI卡住
      _taskStreamController.add([]);
    }
  }
  
  /// 刷新任务列表
  Future<void> refreshTasks() async {
    try {
      _cachedTasks = await _dbHelper.readAllTasks();
      _taskStreamController.add(_cachedTasks);
      _lastRefreshTime = DateTime.now();
      
      debugPrint('任务列表已刷新，共 ${_cachedTasks.length} 个任务');
    } catch (e) {
      debugPrint('刷新任务列表失败: $e');
      // 如果刷新失败但有缓存，则继续使用缓存数据
      if (_cachedTasks.isNotEmpty) {
        _taskStreamController.add(_cachedTasks);
      } else {
        _taskStreamController.add([]);
      }
    }
  }
  
  /// 创建新任务
  Future<Task?> createTask(Task task) async {
    try {
      // 在数据库中创建任务
      final id = await _dbHelper.createTask(task);
      
      // 创建包含ID的任务对象
      final newTask = task.copyWith(id: id);
      
      // 更新缓存和流
      _cachedTasks.add(newTask);
      _taskStreamController.add(_cachedTasks);
      
      debugPrint('创建任务成功: $newTask');
      return newTask;
    } catch (e) {
      debugPrint('创建任务失败: $e');
      return null;
    }
  }
  
  /// 更新任务
  Future<bool> updateTask(Task task) async {
    try {
      // 如果任务没有ID，则无法更新
      if (task.id == null) {
        debugPrint('更新任务失败: 任务ID不能为空');
        return false;
      }
      
      // 在数据库中更新任务
      final rowsAffected = await _dbHelper.updateTask(task);
      
      // 如果没有更新任何行，说明任务不存在
      if (rowsAffected == 0) {
        debugPrint('更新任务失败: 找不到ID为 ${task.id} 的任务');
        return false;
      }
      
      // 更新缓存
      final index = _cachedTasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _cachedTasks[index] = task;
        _taskStreamController.add(_cachedTasks);
      } else {
        // 如果缓存中没有找到，则刷新任务列表
        await refreshTasks();
      }
      
      debugPrint('更新任务成功: $task');
      return true;
    } catch (e) {
      debugPrint('更新任务失败: $e');
      return false;
    }
  }
  
  /// 更新任务完成状态
  Future<bool> updateTaskCompletion(int id, bool isCompleted) async {
    try {
      // 在数据库中更新任务完成状态
      final rowsAffected = await _dbHelper.updateTaskCompletion(id, isCompleted);
      
      // 如果没有更新任何行，说明任务不存在
      if (rowsAffected == 0) {
        debugPrint('更新任务完成状态失败: 找不到ID为 $id 的任务');
        return false;
      }
      
      // 更新缓存
      final index = _cachedTasks.indexWhere((t) => t.id == id);
      if (index != -1) {
        final task = _cachedTasks[index];
        final updatedTask = task.copyWith(
          status: isCompleted ? TaskStatus.completed : TaskStatus.pending,
        );
        _cachedTasks[index] = updatedTask;
        _taskStreamController.add(_cachedTasks);
      } else {
        // 如果缓存中没有找到，则刷新任务列表
        await refreshTasks();
      }
      
      debugPrint('更新任务完成状态成功: ID=$id, isCompleted=$isCompleted');
      return true;
    } catch (e) {
      debugPrint('更新任务完成状态失败: $e');
      return false;
    }
  }
  
  /// 删除任务
  Future<bool> deleteTask(int id) async {
    try {
      // 在数据库中删除任务
      final rowsAffected = await _dbHelper.deleteTask(id);
      
      // 如果没有删除任何行，说明任务不存在
      if (rowsAffected == 0) {
        debugPrint('删除任务失败: 找不到ID为 $id 的任务');
        return false;
      }
      
      // 从缓存中删除任务
      _cachedTasks.removeWhere((t) => t.id == id);
      _taskStreamController.add(_cachedTasks);
      
      debugPrint('删除任务成功: ID=$id');
      return true;
    } catch (e) {
      debugPrint('删除任务失败: $e');
      return false;
    }
  }
  
  /// 获取所有任务
  Future<List<Task>> getAllTasks() async {
    // 检查是否需要刷新缓存（例如，如果自上次刷新已经过去了一段时间）
    final now = DateTime.now();
    if (now.difference(_lastRefreshTime).inMinutes > 5) {
      await refreshTasks();
    }
    
    return _cachedTasks;
  }
  
  /// 获取待完成的任务
  Future<List<Task>> getPendingTasks() async {
    final allTasks = await getAllTasks();
    return allTasks.where((task) => !task.isCompleted).toList();
  }
  
  /// 获取已完成的任务
  Future<List<Task>> getCompletedTasks() async {
    final allTasks = await getAllTasks();
    return allTasks.where((task) => task.isCompleted).toList();
  }
  
  /// 获取高优先级任务
  Future<List<Task>> getPriorityTasks() async {
    final allTasks = await getAllTasks();
    return allTasks.where((task) => task.isPriority && !task.isCompleted).toList();
  }
  
  /// 获取按象限分类的任务
  Future<Map<QuadrantType, List<Task>>> getTasksByQuadrant() async {
    final pendingTasks = await getPendingTasks();
    final Map<QuadrantType, List<Task>> result = {
      QuadrantType.importantUrgent: [],
      QuadrantType.importantNotUrgent: [],
      QuadrantType.urgentNotImportant: [],
      QuadrantType.notImportantNotUrgent: [],
    };
    
    for (var task in pendingTasks) {
      QuadrantType quadrantType;
      
      if (task.isPriority) {
        // 高优先级任务对应"重要且紧急"象限
        quadrantType = QuadrantType.importantUrgent;
      } else {
        // 根据任务的优先级级别确定象限
        switch (task.priorityLevel) {
          case PriorityLevel.high:
            quadrantType = QuadrantType.importantUrgent;
            break;
          case PriorityLevel.medium:
            // 如果有截止日期且即将到期（2天内），则视为"紧急不重要"
            if (task.deadline != null) {
              // 将deadline字符串转换为DateTime对象
              DateTime? deadlineDate = _parseDeadline(task.deadline!);
              if (deadlineDate != null) {
                final daysUntilDeadline = deadlineDate.difference(DateTime.now()).inDays;
                if (daysUntilDeadline <= 2) {
                  quadrantType = QuadrantType.urgentNotImportant;
                } else {
                  quadrantType = QuadrantType.importantNotUrgent;
                }
              } else {
                quadrantType = QuadrantType.importantNotUrgent;
              }
            } else {
              quadrantType = QuadrantType.importantNotUrgent;
            }
            break;
          case PriorityLevel.low:
            // 如果有截止日期且即将到期（2天内），则视为"紧急不重要"
            if (task.deadline != null) {
              // 将deadline字符串转换为DateTime对象
              DateTime? deadlineDate = _parseDeadline(task.deadline!);
              if (deadlineDate != null) {
                final daysUntilDeadline = deadlineDate.difference(DateTime.now()).inDays;
                if (daysUntilDeadline <= 2) {
                  quadrantType = QuadrantType.urgentNotImportant;
                } else {
                  quadrantType = QuadrantType.notImportantNotUrgent;
                }
              } else {
                quadrantType = QuadrantType.notImportantNotUrgent;
              }
            } else {
              quadrantType = QuadrantType.notImportantNotUrgent;
            }
            break;
          default:
            quadrantType = QuadrantType.notImportantNotUrgent;
        }
      }
      
      result[quadrantType]!.add(task);
    }
    
    return result;
  }
  
  /// 解析截止日期字符串为DateTime对象
  DateTime? _parseDeadline(String deadlineStr) {
    try {
      // 尝试直接解析ISO 8601格式
      return DateTime.parse(deadlineStr);
    } catch (e) {
      // 如果不是标准格式，尝试自定义格式
      try {
        // 假设格式为 "yyyy-MM-dd HH:mm"
        final parts = deadlineStr.split(' ');
        if (parts.length >= 1) {
          final dateParts = parts[0].split('-');
          if (dateParts.length == 3) {
            final year = int.tryParse(dateParts[0]) ?? DateTime.now().year;
            final month = int.tryParse(dateParts[1]) ?? 1;
            final day = int.tryParse(dateParts[2]) ?? 1;
            
            if (parts.length > 1) {
              final timeParts = parts[1].split(':');
              if (timeParts.length == 2) {
                final hour = int.tryParse(timeParts[0]) ?? 0;
                final minute = int.tryParse(timeParts[1]) ?? 0;
                return DateTime(year, month, day, hour, minute);
              }
            }
            
            return DateTime(year, month, day);
          }
        }
      } catch (_) {
        // 解析失败，返回null
      }
      debugPrint('无法解析截止日期: $deadlineStr');
      return null;
    }
  }
  
  /// 获取任务统计数据
  Future<Map<String, int>> getTaskStatistics() async {
    try {
      final totalCount = await _dbHelper.getTaskCount();
      final completedCount = await _dbHelper.getCompletedTaskCount();
      final pendingCount = await _dbHelper.getPendingTaskCount();
      
      // 计算任务完成率
      final completionRate = totalCount > 0 ? (completedCount / totalCount * 100).round() : 0;
      
      return {
        'total': totalCount,
        'completed': completedCount,
        'pending': pendingCount,
        'completionRate': completionRate,
      };
    } catch (e) {
      debugPrint('获取任务统计数据失败: $e');
      return {
        'total': 0,
        'completed': 0,
        'pending': 0,
        'completionRate': 0,
      };
    }
  }
  
  /// 搜索任务
  Future<List<Task>> searchTasks(String query) async {
    try {
      if (query.isEmpty) {
        return _cachedTasks;
      }
      
      final lowerQuery = query.toLowerCase();
      return _cachedTasks.where((task) => 
        task.title.toLowerCase().contains(lowerQuery)
      ).toList();
    } catch (e) {
      debugPrint('搜索任务失败: $e');
      return [];
    }
  }
  
  /// 关闭服务，释放资源
  void dispose() {
    _taskStreamController.close();
    debugPrint('任务服务已关闭');
  }
} 
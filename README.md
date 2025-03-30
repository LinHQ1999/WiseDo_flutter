# WiseDo - 日程助手

一个基于Flutter开发的日程管理应用，帮助用户高效管理日常任务。

## 项目特点

- 任务管理：记录、跟踪和完成日常任务
- 四象限视图：基于重要性和紧急性的任务分类
- 任务统计：直观展示任务完成情况
- 个性化设置：自定义应用使用体验

## 项目结构

项目采用了清晰的分层架构，结构如下：

```
lib/
  ├── constants/        # 常量定义
  │   └── app_theme.dart  # 应用主题相关常量
  │
  ├── models/           # 数据模型
  │   └── task.dart       # 任务模型
  │
  ├── screens/          # 页面组件
  │   ├── home_screen.dart      # 首页
  │   ├── quadrant_screen.dart  # 四象限页面
  │   ├── stats_screen.dart     # 统计页面
  │   └── settings_screen.dart  # 设置页面
  │
  ├── widgets/          # 可复用组件
  │   ├── header_widget.dart    # 头部信息组件
  │   ├── section_card.dart     # 部分卡片组件
  │   └── task_item.dart        # 任务项组件
  │
  ├── utils/            # 工具类
  │
  └── main.dart         # 应用入口
```

## 如何运行

1. 确保已安装Flutter开发环境（Flutter 3.0+）
2. 克隆项目到本地
   ```
   git clone <项目仓库地址>
   ```
3. 进入项目目录
   ```
   cd WiseDo_flutter
   ```
4. 安装依赖
   ```
   flutter pub get
   ```
5. 运行应用
   ```
   flutter run
   ```

## 未来计划

- [ ] 实现本地数据持久化
- [ ] 添加云同步功能
- [ ] 增加提醒通知功能
- [ ] 支持多语言
- [ ] 添加更多个性化选项

## 贡献指南

欢迎提交问题报告和代码贡献！

## 许可证

MIT

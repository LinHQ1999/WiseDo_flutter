# WiseDo Flutter 应用

WiseDo是一款基于四象限时间管理法的任务管理应用，帮助用户提高工作效率和时间管理能力。

*English version follows the Chinese version*

## 项目架构

该项目采用了清晰的分层架构，以提高代码的可维护性和可扩展性：

### 数据层 (Data Layer)
- `lib/database/` - 包含数据库访问逻辑
  - `database_helper.dart` - SQLite数据库操作的辅助类

### 模型层 (Model Layer)
- `lib/models/` - 包含应用的核心数据模型
  - `base_model.dart` - 所有模型的基类
  - `task.dart` - 任务模型
  - `quadrant_task.dart` - 四象限任务模型

### 服务层 (Service Layer)
- `lib/services/` - 包含业务逻辑和服务
  - `service_locator.dart` - 服务定位器，管理全局服务实例
  - `task_service.dart` - 任务相关业务逻辑
  - `preference_service.dart` - 用户偏好设置管理
  - `theme_service.dart` - 主题相关业务逻辑

### 表示层 (Presentation Layer)
- `lib/screens/` - 包含应用的主要页面
  - `home_screen.dart` - 首页
  - `quadrant_screen.dart` - 四象限页面
  - `stats_screen.dart` - 统计页面
  - `settings_screen.dart` - 设置页面
- `lib/widgets/` - 包含可重用的UI组件
  - `task_edit_dialog.dart` - 任务编辑对话框
  - `quadrant_section.dart` - 四象限部分UI

### 常量和资源 (Constants & Resources)
- `lib/constants/` - 包含应用常量
  - `app_theme.dart` - 主题相关常量
- `lib/l10n/` - 包含国际化资源
  - `app_en.arb` - 英文本地化字符串
  - `app_zh.arb` - 中文本地化字符串

## 项目重构

### 第一阶段：架构优化
1. **创建了基类**：实现了`BaseModel`基类，提高了代码复用性
2. **服务层**：引入服务层架构，将业务逻辑与UI分离
3. **依赖注入**：使用`GetIt`库实现依赖注入，便于测试和解耦
4. **常量管理**：引入了常量类，避免硬编码
5. **错误处理**：增强了异常处理机制

### 第二阶段：UI组件优化
1. **主题支持**：改进了深色模式和动态主题支持
2. **响应式设计**：使用Stream和Provider提高了UI响应性
3. **国际化**：扩展了国际化支持，添加更多本地化字符串

## 技术栈
- Flutter
- SQLite (sqflite)
- GetIt (依赖注入)
- Provider (状态管理)
- Intl (国际化)

## 如何运行

1. 确保已安装 Flutter SDK
2. 克隆仓库
```bash
git clone https://github.com/yourusername/wisedo_flutter.git
```
3. 获取依赖
```bash
flutter pub get
```
4. 运行应用
```bash
flutter run
```

## 后续计划
- 添加用户认证功能
- 实现云同步
- 添加更多统计分析功能
- 优化性能和用户体验

## 项目特点
- 四象限时间管理：基于重要性和紧急性划分任务
- 智能任务提醒：根据任务优先级智能提醒
- 任务统计：直观展示任务完成情况
- 个性化设置：自定义应用使用体验

## 贡献指南
欢迎贡献代码或提出建议！请遵循以下步骤：
1. Fork 项目
2. 创建特性分支 (`git checkout -b feature/amazing-feature`)
3. 提交更改 (`git commit -m 'Add some amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 创建 Pull Request

## 许可证
MIT 许可证 - 详见 LICENSE 文件

---

# WiseDo Flutter App

WiseDo is a task management application based on the four-quadrant time management method, helping users improve work efficiency and time management abilities.

## Project Architecture

The project adopts a clear layered architecture to improve code maintainability and extensibility:

### Data Layer
- `lib/database/` - Contains database access logic
  - `database_helper.dart` - Helper class for SQLite database operations

### Model Layer
- `lib/models/` - Contains the core data models
  - `base_model.dart` - Base class for all models
  - `task.dart` - Task model
  - `quadrant_task.dart` - Four-quadrant task model

### Service Layer
- `lib/services/` - Contains business logic and services
  - `service_locator.dart` - Service locator, manages global service instances
  - `task_service.dart` - Task-related business logic
  - `preference_service.dart` - User preference management
  - `theme_service.dart` - Theme-related business logic

### Presentation Layer
- `lib/screens/` - Contains the main pages
  - `home_screen.dart` - Home page
  - `quadrant_screen.dart` - Four-quadrant page
  - `stats_screen.dart` - Statistics page
  - `settings_screen.dart` - Settings page
- `lib/widgets/` - Contains reusable UI components
  - `task_edit_dialog.dart` - Task editing dialog
  - `quadrant_section.dart` - Four-quadrant section UI

### Constants & Resources
- `lib/constants/` - Contains application constants
  - `app_theme.dart` - Theme-related constants
- `lib/l10n/` - Contains internationalization resources
  - `app_en.arb` - English localization strings
  - `app_zh.arb` - Chinese localization strings

## Project Refactoring

### Phase 1: Architecture Optimization
1. **Base Class Creation**: Implemented `BaseModel` base class to improve code reusability
2. **Service Layer**: Introduced service layer architecture to separate business logic from UI
3. **Dependency Injection**: Used `GetIt` library for dependency injection, facilitating testing and decoupling
4. **Constants Management**: Introduced constant classes to avoid hardcoding
5. **Error Handling**: Enhanced exception handling mechanisms

### Phase 2: UI Component Optimization
1. **Theme Support**: Improved dark mode and dynamic theme support
2. **Responsive Design**: Used Stream and Provider to enhance UI responsiveness
3. **Internationalization**: Extended internationalization support, adding more localized strings

## Tech Stack
- Flutter
- SQLite (sqflite)
- GetIt (dependency injection)
- Provider (state management)
- Intl (internationalization)

## How to Run

1. Ensure Flutter SDK is installed
2. Clone the repository
```bash
git clone https://github.com/yourusername/wisedo_flutter.git
```
3. Get dependencies
```bash
flutter pub get
```
4. Run the app
```bash
flutter run
```

## Future Plans
- Add user authentication
- Implement cloud synchronization
- Add more statistical analysis features
- Optimize performance and user experience

## Project Features
- Four-quadrant time management: Categorize tasks based on importance and urgency
- Smart task reminders: Intelligent reminders based on task priority
- Task statistics: Visual representation of task completion
- Personalized settings: Customize application experience

## Contribution Guidelines
Contributions of code or suggestions are welcome! Please follow these steps:
1. Fork the project
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Create a Pull Request

## License
MIT License - See LICENSE file for details

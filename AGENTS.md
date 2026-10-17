# 协作者指南

## 项目概况

这是一个 Flutter 插件。公开入口位于 `lib/network_capture.dart`：应用包装组件在 `lib/view/`，Dio 拦截器在 `lib/http/`，本地 SQLite 数据访问在 `lib/db/`，通用辅助代码在 `lib/util/`。`example/` 是依赖本地插件的演示应用，`test/` 存放插件测试。

抓包数据从 `CaptureDioInterceptor` 流入 SQLite，再由列表和详情界面读取。涉及这条链路时，检查请求成功、请求错误、数据大小限制和本地持久化行为，避免无意改变现有 API 或收集范围。

## 开发约定

- 遵循仓库 `analysis_options.yaml` 的 lint 规则和 Dart/Flutter 现有风格；使用单引号、类型明确的 API，并保持改动聚焦。
- 修改公开行为时同步更新根目录 `README.md`，需要示例时在 `example/` 中验证。
- 不要把凭据、个人数据或真实抓包内容提交到仓库。捕获内容当前未脱敏。
- 未经任务要求，不修改生成文件、依赖版本或平台工程配置。

## 常用检查

在仓库根目录运行：

```sh
flutter pub get
flutter test
flutter analyze
```

运行演示应用时，在 `example/` 目录执行 `flutter run`。根据改动范围运行相关检查，并在交付说明中报告未能执行的检查。

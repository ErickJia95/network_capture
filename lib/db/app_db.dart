import 'dart:io';

import 'package:network_capture/db/table/network_history_table.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// createTime: 2023/10/20 on 21:26
/// desc:
///
/// @author azhon
class AppDb {
  final String _dbName = 'networkCapture.db';
  late String _path;
  late Database _db;

  factory AppDb() => _getInstance();

  static AppDb get instance => _getInstance();
  static AppDb? _instance;

  static AppDb _getInstance() {
    _instance ??= AppDb._internal();
    return _instance!;
  }

  AppDb._internal();

  /// 初始化数据库。
  Future<bool> init() async {
    await _initDatabaseFactory();
    _path = await _resolveDatabasePath();
    _db = await open();
    return true;
  }

  /// 打开抓包数据库。
  Future<Database> open() async {
    return databaseFactory.openDatabase(
      _path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          /// 创建抓包历史表。
          await db.execute(NetworkHistoryTable.createTable());
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          final batch = db.batch();
          await db.execute(NetworkHistoryTable.drop());
          await batch.commit();
        },
      ),
    );
  }

  /// 插入一条抓包记录。
  Future<int> insert(String table, Map<String, Object?> values) {
    return _db.insert(table, values);
  }

  /// 删除抓包记录。
  Future<int> delete(String table, {String? where, List<Object?>? whereArgs}) {
    return _db.delete(table, where: where, whereArgs: whereArgs);
  }

  /// 查询抓包记录。
  Future<List<Map<String, Object?>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) {
    return _db.query(
      table,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  /// 根据平台初始化数据库工厂，桌面端切换到 ffi 实现。
  Future<void> _initDatabaseFactory() async {
    if (_isDesktopPlatform) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  /// 解析数据库文件路径，桌面端使用应用文档目录以保证兼容性。
  Future<String> _resolveDatabasePath() async {
    if (_isDesktopPlatform) {
      final directory = await getApplicationDocumentsDirectory();
      return p.join(directory.path, _dbName);
    }

    final databasesPath = await getDatabasesPath();
    return p.join(databasesPath, _dbName);
  }

  /// 判断当前是否为桌面平台。
  bool get _isDesktopPlatform =>
      Platform.isWindows || Platform.isLinux || Platform.isMacOS;
}

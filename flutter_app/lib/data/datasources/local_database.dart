import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/download_item.dart';

class LocalDatabase {
  static final LocalDatabase _instance = LocalDatabase._internal();
  factory LocalDatabase() => _instance;
  LocalDatabase._internal();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'downloads.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            job_id TEXT NOT NULL,
            url TEXT NOT NULL,
            title TEXT,
            thumbnail TEXT,
            download_type TEXT,
            quality TEXT,
            status TEXT,
            progress REAL,
            speed TEXT,
            eta TEXT,
            filename TEXT,
            file_path TEXT,
            file_size INTEGER,
            duration INTEGER,
            error TEXT,
            created_at TEXT,
            completed_at TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertItem(DownloadItem item) async {
    final database = await db;
    final data = item.toJson();
    data.remove('id'); // let SQLite auto-increment
    return await database.insert('history', data);
  }

  Future<void> updateItem(DownloadItem item) async {
    final database = await db;
    if (item.id != null) {
      await database.update(
        'history',
        item.toJson(),
        where: 'id = ?',
        whereArgs: [item.id],
      );
    } else {
      await database.update(
        'history',
        item.toJson(),
        where: 'job_id = ?',
        whereArgs: [item.jobId],
      );
    }
  }

  Future<List<DownloadItem>> getHistory({String? search, String? type}) async {
    final database = await db;
    String where = '1=1';
    List<dynamic> whereArgs = [];

    if (search != null && search.isNotEmpty) {
      where += ' AND title LIKE ?';
      whereArgs.add('%$search%');
    }
    if (type != null && type.isNotEmpty) {
      where += ' AND download_type = ?';
      whereArgs.add(type);
    }

    final List<Map<String, dynamic>> maps = await database.query(
      'history',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) => DownloadItem.fromJson(maps[i]));
  }

  Future<void> deleteItem(int id) async {
    final database = await db;
    await database.delete('history', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearHistory() async {
    final database = await db;
    await database.delete('history');
  }

  Future<List<DownloadItem>> getActiveDownloads() async {
    final database = await db;
    final List<Map<String, dynamic>> maps = await database.query(
      'history',
      where: 'status IN (?, ?, ?)',
      whereArgs: ['queued', 'downloading', 'processing'],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => DownloadItem.fromJson(maps[i]));
  }
}

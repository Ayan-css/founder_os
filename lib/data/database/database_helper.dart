import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const String _dbName = 'founder_os.db';
  static const int _dbVersion = 1;

  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<String> _getDatabasePath() async {
    if (Platform.isAndroid || Platform.isIOS) {
      return join(await getDatabasesPath(), _dbName);
    }
    final dir = await getApplicationDocumentsDirectory();
    final appDir = Directory(join(dir.path, 'FounderOS'));
    if (!await appDir.exists()) await appDir.create(recursive: true);
    return join(appDir.path, _dbName);
  }

  Future<Database> _initDatabase() async {
    final path = await _getDatabasePath();
    return openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    final b = db.batch();

    b.execute('''
      CREATE TABLE tasks (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        title        TEXT    NOT NULL,
        is_completed INTEGER NOT NULL DEFAULT 0,
        date         TEXT    NOT NULL,
        position     INTEGER NOT NULL,
        created_at   TEXT    NOT NULL,
        completed_at TEXT
      )
    ''');

    b.execute('''
      CREATE TABLE captures (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        content    TEXT NOT NULL,
        type       TEXT NOT NULL DEFAULT 'thought',
        created_at TEXT NOT NULL
      )
    ''');

    b.execute('''
      CREATE TABLE reflections (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        date        TEXT NOT NULL UNIQUE,
        distraction TEXT,
        forward     TEXT,
        improvement TEXT,
        created_at  TEXT NOT NULL
      )
    ''');

    b.execute('''
      CREATE TABLE content_items (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        title      TEXT NOT NULL,
        stage      TEXT NOT NULL DEFAULT 'idea',
        notes      TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    b.execute('''
      CREATE TABLE clients (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        name          TEXT NOT NULL,
        status        TEXT NOT NULL DEFAULT 'active',
        payment_state TEXT NOT NULL DEFAULT 'pending',
        deliverables  TEXT,
        notes         TEXT,
        created_at    TEXT NOT NULL,
        updated_at    TEXT NOT NULL
      )
    ''');

    b.execute('''
      CREATE TABLE daily_logs (
        id               INTEGER PRIMARY KEY AUTOINCREMENT,
        date             TEXT    NOT NULL UNIQUE,
        tasks_completed  INTEGER NOT NULL DEFAULT 0,
        tasks_total      INTEGER NOT NULL DEFAULT 0,
        focus_sessions   INTEGER NOT NULL DEFAULT 0,
        created_at       TEXT    NOT NULL
      )
    ''');

    b.execute('CREATE INDEX idx_tasks_date      ON tasks(date)');
    b.execute('CREATE INDEX idx_tasks_date_pos  ON tasks(date, position)');
    b.execute('CREATE INDEX idx_daily_logs_date ON daily_logs(date)');

    await b.commit(noResult: true);
  }
}

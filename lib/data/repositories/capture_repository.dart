import '../../data/database/database_helper.dart';
import '../../domain/models/capture.dart';

class CaptureRepository {
  final _db = DatabaseHelper.instance;

  Future<List<Capture>> getAll({CaptureType? filterType}) async {
    final db   = await _db.database;
    final maps = await db.query(
      'captures',
      where:     filterType != null ? 'type = ?' : null,
      whereArgs: filterType != null ? [filterType.dbValue] : null,
      orderBy:   'created_at DESC',
    );
    return maps.map(Capture.fromMap).toList();
  }

  Future<Capture> insert(Capture capture) async {
    final db = await _db.database;
    final id = await db.insert('captures', capture.toMap());
    return capture.copyWith(id: id);
  }

  Future<void> delete(int id) async {
    final db = await _db.database;
    await db.delete('captures', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> update(Capture capture) async {
    assert(capture.id != null);
    final db = await _db.database;
    await db.update('captures', capture.toMap(),
        where: 'id = ?', whereArgs: [capture.id]);
  }

  Future<int> getTodayCount() async {
    final db  = await _db.database;
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).toIso8601String();
    final end   = DateTime(now.year, now.month, now.day, 23, 59, 59)
        .toIso8601String();
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count FROM captures
      WHERE created_at >= ? AND created_at <= ?
    ''', [start, end]);
    return (result.first['count'] as int?) ?? 0;
  }
}

import '../../core/utils/app_date_utils.dart';
import '../../data/database/database_helper.dart';
import '../../domain/models/reflection.dart';

class ReflectionRepository {
  final _db = DatabaseHelper.instance;

  Future<Reflection?> getForDate(String date) async {
    final db   = await _db.database;
    final maps = await db.query('reflections',
        where: 'date = ?', whereArgs: [date], limit: 1);
    return maps.isEmpty ? null : Reflection.fromMap(maps.first);
  }

  Future<Reflection?> getTodayReflection() =>
      getForDate(AppDateUtils.todayDbDate());

  Future<List<Reflection>> getAll() async {
    final db   = await _db.database;
    final maps = await db.query('reflections', orderBy: 'date DESC');
    return maps.map(Reflection.fromMap).toList();
  }

  Future<Reflection> upsert({
    String? distraction,
    String? forward,
    String? improvement,
  }) async {
    final db       = await _db.database;
    final today    = AppDateUtils.todayDbDate();
    final existing = await getTodayReflection();

    if (existing != null) {
      final updated = existing.copyWith(
        distraction:      distraction,
        forward:          forward,
        improvement:      improvement,
        clearDistraction: distraction == null,
        clearForward:     forward     == null,
        clearImprovement: improvement == null,
      );
      await db.update('reflections', updated.toMap(),
          where: 'id = ?', whereArgs: [existing.id]);
      return updated;
    }

    final reflection = Reflection(
      date:        today,
      distraction: distraction,
      forward:     forward,
      improvement: improvement,
      createdAt:   DateTime.now(),
    );
    final id = await db.insert('reflections', reflection.toMap());
    return reflection.copyWith(id: id);
  }
}

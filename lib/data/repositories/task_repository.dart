import '../../data/database/database_helper.dart';
import '../../domain/models/task.dart';

class TaskRepository {
  final _db = DatabaseHelper.instance;

  Future<List<Task>> getTasksForDate(String date) async {
    final db = await _db.database;
    final maps = await db.query(
      'tasks',
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'position ASC',
    );
    return maps.map(Task.fromMap).toList();
  }

  Future<Task> insertTask(Task task) async {
    final db = await _db.database;
    final id = await db.insert('tasks', task.toMap());
    return task.copyWith(id: id);
  }

  Future<void> updateTask(Task task) async {
    assert(task.id != null);
    final db = await _db.database;
    await db
        .update('tasks', task.toMap(), where: 'id = ?', whereArgs: [task.id]);
  }

  Future<void> deleteTask(int id) async {
    final db = await _db.database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<Task> toggleCompletion(Task task) async {
    final updated = task.copyWith(
      isCompleted: !task.isCompleted,
      completedAt: !task.isCompleted ? DateTime.now() : null,
      clearCompletedAt: task.isCompleted,
    );
    await updateTask(updated);
    return updated;
  }

  Future<List<String>> getDatesWithCompletedTasks() async {
    final db = await _db.database;
    final result = await db.rawQuery('''
      SELECT DISTINCT date FROM tasks
      WHERE is_completed = 1
      ORDER BY date DESC
    ''');
    return result.map((r) => r['date'] as String).toList();
  }
}

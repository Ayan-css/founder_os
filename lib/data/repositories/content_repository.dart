import '../../data/database/database_helper.dart';
import '../../domain/models/content_item.dart';

class ContentRepository {
  final _db = DatabaseHelper.instance;

  Future<List<ContentItem>> getAll() async {
    final db = await _db.database;
    final maps = await db.query('content_items', orderBy: 'updated_at DESC');
    return maps.map(ContentItem.fromMap).toList();
  }

  Future<ContentItem> insert(ContentItem item) async {
    final db = await _db.database;
    final id = await db.insert('content_items', item.toMap());
    return item.copyWith(id: id);
  }

  Future<void> update(ContentItem item) async {
    assert(item.id != null);
    final db = await _db.database;
    await db.update('content_items', item.toMap(),
        where: 'id = ?', whereArgs: [item.id]);
  }

  Future<void> delete(int id) async {
    final db = await _db.database;
    await db.delete('content_items', where: 'id = ?', whereArgs: [id]);
  }

  Future<ContentItem> moveToStage(ContentItem item, ContentStage stage) async {
    final updated = item.copyWith(stage: stage, updatedAt: DateTime.now());
    await update(updated);
    return updated;
  }
}

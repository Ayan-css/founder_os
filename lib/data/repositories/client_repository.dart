import '../../data/database/database_helper.dart';
import '../../domain/models/client.dart';

class ClientRepository {
  final _db = DatabaseHelper.instance;

  Future<List<Client>> getAll() async {
    final db   = await _db.database;
    final maps = await db.query(
      'clients',
      orderBy: '''
        CASE payment_state
          WHEN 'overdue'  THEN 0
          WHEN 'partial'  THEN 1
          WHEN 'pending'  THEN 2
          WHEN 'paid'     THEN 3
          ELSE 4
        END ASC,
        CASE status
          WHEN 'active'   THEN 0
          WHEN 'paused'   THEN 1
          WHEN 'prospect' THEN 2
          WHEN 'churned'  THEN 3
          ELSE 4
        END ASC,
        updated_at DESC
      ''',
    );
    return maps.map(Client.fromMap).toList();
  }

  Future<Client?> getById(int id) async {
    final db   = await _db.database;
    final maps = await db.query('clients',
        where: 'id = ?', whereArgs: [id], limit: 1);
    return maps.isEmpty ? null : Client.fromMap(maps.first);
  }

  Future<Client> insert(Client client) async {
    final db = await _db.database;
    final id = await db.insert('clients', client.toMap());
    return client.copyWith(id: id);
  }

  Future<void> update(Client client) async {
    assert(client.id != null);
    final db = await _db.database;
    await db.update('clients', client.toMap(),
        where: 'id = ?', whereArgs: [client.id]);
  }

  Future<void> delete(int id) async {
    final db = await _db.database;
    await db.delete('clients', where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, int>> getSummaryCounts() async {
    final db     = await _db.database;
    final result = await db.rawQuery('''
      SELECT
        COUNT(*)                                                         AS total,
        SUM(CASE WHEN status = 'active'                    THEN 1 ELSE 0 END) AS active,
        SUM(CASE WHEN payment_state = 'overdue'            THEN 1 ELSE 0 END) AS overdue,
        SUM(CASE WHEN payment_state IN ('pending','partial')
                  AND status = 'active'                    THEN 1 ELSE 0 END) AS awaiting
      FROM clients
      WHERE status != 'churned'
    ''');
    final row = result.first;
    return {
      'total':    (row['total']    as int?) ?? 0,
      'active':   (row['active']   as int?) ?? 0,
      'overdue':  (row['overdue']  as int?) ?? 0,
      'awaiting': (row['awaiting'] as int?) ?? 0,
    };
  }
}

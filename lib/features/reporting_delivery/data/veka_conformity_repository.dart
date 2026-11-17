import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';

enum VekaConformity {
  appliance('stooktoestel_conform'),
  flue('rookgasafvoerkanaal_conform'),
  room('stookplaats_conform');

  final String column;
  const VekaConformity(this.column);
}

class VekaConformityRepository {
  final Future<Database> Function() _database;

  VekaConformityRepository({Future<Database> Function()? database})
      : _database = database ?? (() => AppDatabase.instance.database);

  Future<Map<VekaConformity, String?>> load(int visitId) async {
    final rows = await (await _database()).query('maintenance_visits',
        columns: VekaConformity.values.map((field) => field.column).toList(),
        where: 'id = ? AND is_draft = 1',
        whereArgs: [visitId]);
    return {
      for (final field in VekaConformity.values)
        field: rows.single[field.column] as String?
    };
  }

  Future<void> save(int visitId, Map<VekaConformity, String?> values) async {
    final count = await (await _database()).update('maintenance_visits',
        {for (final entry in values.entries) entry.key.column: entry.value},
        where: 'id = ? AND is_draft = 1', whereArgs: [visitId]);
    if (count != 1) throw StateError('Missing draft');
  }
}

import 'package:sqflite/sqflite.dart';
import '../../../core/database/app_database.dart';
import '../domain/technician_profile.dart';

/// SQLite persistence service for the singleton Company and Technician profile.
class TechnicianProfileRepository {
  final AppDatabase _appDatabase;

  TechnicianProfileRepository({AppDatabase? appDatabase})
      : _appDatabase = appDatabase ?? AppDatabase.instance;

  /// Loads the saved singleton technician/company profile, or creates an initial record.
  Future<TechnicianProfile> getProfile({Database? dbOverride}) async {
    final db = dbOverride ?? await _appDatabase.database;

    final rows = await db.query(
      'technician_profile',
      orderBy: 'id ASC',
      limit: 1,
    );

    if (rows.isNotEmpty) {
      return TechnicianProfile.fromMap(rows.first);
    }

    // Default empty profile
    return const TechnicianProfile();
  }

  /// Upserts the singleton company and technician profile into SQLite.
  Future<void> saveProfile(
    TechnicianProfile profile, {
    Database? dbOverride,
  }) async {
    final db = dbOverride ?? await _appDatabase.database;

    final rows = await db.query(
      'technician_profile',
      orderBy: 'id ASC',
      limit: 1,
    );

    final data = profile.toMap();

    if (rows.isNotEmpty) {
      final existingId = rows.first['id'] as int;
      await db.update(
        'technician_profile',
        data,
        where: 'id = ?',
        whereArgs: [existingId],
      );
    } else {
      data['created_at'] = DateTime.now().toIso8601String();
      await db.insert('technician_profile', data);
    }
  }
}

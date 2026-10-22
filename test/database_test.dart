import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/core/database/app_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // Initialize FFI for running SQLite in desktop unit test environment
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;

  setUp(() async {
    // Open a fresh in-memory database with schema for each test
    db = await AppDatabase.instance.initDatabase(
      customPath: inMemoryDatabasePath,
    );
    AppDatabase.instance.setDatabaseForTesting(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Slice 1.4 — SQLite Database Core', () {
    test('Initializes database and creates all 6 core tables', () async {
      final List<Map<String, Object?>> tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name;",
      );

      final tableNames = tables.map((t) => t['name'] as String).toList();

      expect(tableNames, contains('technician_profile'));
      expect(tableNames, contains('customers'));
      expect(tableNames, contains('service_locations'));
      expect(tableNames, contains('boilers'));
      expect(tableNames, contains('maintenance_visits'));
      expect(tableNames, contains('measurement_captures'));
    });

    test('Enforces foreign key constraints', () async {
      final foreignKeysPragma = await db.rawQuery('PRAGMA foreign_keys;');
      expect(foreignKeysPragma.first.values.first, 1);

      // Attempting to insert a service_location with a non-existent customer_id should fail
      expect(
        () async {
          await db.insert('service_locations', {
            'customer_id': 99999,
            'role': 'owner',
            'street': 'Kerkstraat',
            'house_number': '10',
            'postal_code': '9000',
            'municipality': 'Gent',
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });
        },
        throwsA(isA<DatabaseException>()),
      );
    });

    test(
        'Relational cascade: deleting a customer cascades to service_locations and boilers',
        () async {
      // 1. Insert customer
      final customerId = await db.insert('customers', {
        'last_name': 'Vermeulen',
        'first_name': 'Jan',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // 2. Insert service location
      final locationId = await db.insert('service_locations', {
        'customer_id': customerId,
        'role': 'owner',
        'street': 'Kerkstraat',
        'house_number': '10',
        'postal_code': '9000',
        'municipality': 'Gent',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // 3. Insert boiler
      final boilerId = await db.insert('boilers', {
        'service_location_id': locationId,
        'boiler_brand': 'Vaillant',
        'fuel_type': 'gas',
        'fuel_subtype': 'aardgas',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      expect(customerId, isPositive);
      expect(locationId, isPositive);
      expect(boilerId, isPositive);

      // 4. Delete customer -> should cascade to location and boiler
      await db.delete('customers', where: 'id = ?', whereArgs: [customerId]);

      final remainingLocations = await db.query('service_locations');
      final remainingBoilers = await db.query('boilers');

      expect(remainingLocations, isEmpty);
      expect(remainingBoilers, isEmpty);
    });

    test('Technician profile singleton can be inserted and queried', () async {
      await db.insert('technician_profile', {
        'company_name': 'HVAC Solutions BV',
        'kbo_number': '0123.456.789',
        'technician_first_name': 'Luc',
        'technician_last_name': 'Peeters',
        'gv_number': 'GV12345',
        'tv_number': 'TV67890',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      final profiles = await db.query('technician_profile');
      expect(profiles.length, 1);
      expect(profiles.first['company_name'], 'HVAC Solutions BV');
      expect(profiles.first['gv_number'], 'GV12345');
    });
  });
}

import 'dart:convert';
import 'dart:io';

import 'package:hvac_app/core/database/app_database.dart';
import 'package:hvac_app/features/reporting_delivery/data/veka_report.dart';
import 'package:hvac_app/features/reporting_delivery/data/veka_report_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Runs submission and restart cases against a clean, on-disk SQLite database.
class VekaApiFixture {
  static const visitId = 1;
  static const visitTable = 'maintenance_visits';
  static const _stamp = {
    'created_at': '2025-01-01',
    'updated_at': '2025-01-01'
  };

  final Directory _directory;
  late Database db;

  VekaApiFixture._(this._directory);

  VekaReportRepository get reports =>
      VekaReportRepository(database: () async => db);

  static Future<VekaApiFixture> create() async {
    final fixture = VekaApiFixture._(
      await Directory.systemTemp.createTemp('hvac_veka_api_'),
    );
    await fixture._open();
    await fixture._seed();
    return fixture;
  }

  Future<void> _open() async {
    db = await AppDatabase.instance.initDatabase(
      customPath: '${_directory.path}/veka_api.sqlite',
    );
  }

  Future<void> reopen() async {
    await db.close();
    await _open();
  }

  Future<Database> openSecondConnection() => databaseFactoryFfi.openDatabase(
        '${_directory.path}/veka_api.sqlite',
        options: OpenDatabaseOptions(singleInstance: false),
      );

  Future<void> close() async {
    await db.close();
    await _directory.delete(recursive: true);
  }

  Future<VekaReport> review() => reports.preview(visitId);

  Future<Map<String, Object?>> visit() async =>
      (await db.query(visitTable, where: 'id = ?', whereArgs: [visitId]))
          .single;

  Future<void> changeAddress(String number) => db.update(
        'service_locations',
        {'house_number': number},
        where: 'id = ?',
        whereArgs: [1],
      );

  Future<void> finalize() async {
    final snapshot = {
      'format_version': 1,
      'visit': await visit(),
      'profile': (await db.query('technician_profile')).single,
      'location': (await db.query('service_locations')).single,
      'boiler': (await db.query('boilers')).single,
    };
    await db.update(visitTable, {
      'is_draft': 0,
      'pdf_status': 'ready',
      'snapshot_json': jsonEncode(snapshot),
    });
  }

  Future<void> _seed() async {
    await db.insert('customers', {..._stamp, 'last_name': 'Voorbeeld'});
    await db.insert('service_locations', {
      ..._stamp,
      'customer_id': 1,
      'street': 'Kerkstraat',
      'house_number': '15',
      'box_number': '0001',
      'postal_code': '9000',
      'municipality': 'Gent',
      'adres_id': '12345',
      'gebouw_id': '67890',
      'gebouweenheid_id': '67891',
      'verification_status': 'verified',
    });
    await db.insert('boilers', {
      ..._stamp,
      'is_central': 1,
      'fuel_type': 'gas',
      'fuel_subtype': 'aardgas',
      'heating_type': 'individueel',
      'boiler_operation': 'condenserend',
      'burner_technology': 'premix',
      'boiler_brand': 'Voorbeeldmerk',
      'boiler_model': 'Voorbeeldmodel',
      'boiler_serial_number': 'TEST-12345',
      'boiler_construction_year': 2022,
      'boiler_nominal_power_kw': 32.0,
    });
    await db.insert('technician_profile', {
      ..._stamp,
      'company_name': 'Voorbeeld',
      'kbo_number': 'BE 0123.456.789',
      'technician_first_name': 'Jan',
      'technician_last_name': 'Voorbeeld',
      'gv_number': 'gv 12345',
    });
    await db.insert(visitTable, {
      ..._stamp,
      'attest_number': 'ATTEST-42',
      'visit_date': '2025-01-01',
      'activity_type': 'onderhoud',
      'customer_id': 1,
      'service_location_id': 1,
      'boiler_id': 1,
      'stooktoestel_conform': 'OK',
      'rookgasafvoerkanaal_conform': 'OK',
      'stookplaats_conform': 'OK',
      'verbrandingscontrole': 'OK',
      'toestel_werking_goed': 'Goed',
      'toestel_werking_veilig': 'Veilig',
    });
  }
}

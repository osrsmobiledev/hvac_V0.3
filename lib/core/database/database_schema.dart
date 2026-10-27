import 'package:sqflite/sqflite.dart';

/// Database schema definitions for HVAC Field Service (hvac_V0.3).
///
/// Contains table creation DDL statements for the 6 core relational entities:
/// 1. technician_profile (Singleton reusable company/technician data)
/// 2. customers (Client directory)
/// 3. service_locations (Installation addresses & Basisregisters IDs)
/// 4. boilers (Appliance, burner, and authoritative fuel specification)
/// 5. maintenance_visits (Attest draft, measurements, assessments, PDF & VEKA state)
/// 6. measurement_captures (Flue gas data captured manually or via Eurolyzer QR)
abstract final class DatabaseSchema {
  static const int version = 3;
  static const String databaseName = 'hvac_service.db';

  /// Executes all CREATE TABLE and CREATE INDEX statements on database initialization.
  static Future<void> createAllTables(Database db) async {
    // 1. technician_profile (Singleton)
    await db.execute('''
      CREATE TABLE technician_profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        company_name TEXT NOT NULL,
        kbo_number TEXT NOT NULL,
        street TEXT,
        house_number TEXT,
        box_number TEXT,
        postal_code TEXT,
        city TEXT,
        phone TEXT,
        email TEXT,
        technician_first_name TEXT,
        technician_last_name TEXT,
        gv_number TEXT,
        tv_number TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      );
    ''');

    // 2. customers
    await db.execute('''
      CREATE TABLE customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        first_name TEXT,
        last_name TEXT NOT NULL,
        company_name TEXT,
        email TEXT,
        phone TEXT,
        street TEXT,
        house_number TEXT,
        box_number TEXT,
        postal_code TEXT,
        city TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      );
    ''');

    // 3. service_locations
    await db.execute('''
      CREATE TABLE service_locations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_id INTEGER NOT NULL,
        role TEXT NOT NULL DEFAULT 'owner',
        street TEXT NOT NULL,
        house_number TEXT NOT NULL,
        box_number TEXT,
        postal_code TEXT NOT NULL,
        municipality TEXT NOT NULL,
        adres_id TEXT,
        gebouw_id TEXT,
        gebouweenheid_id TEXT,
        verification_status TEXT NOT NULL DEFAULT 'unverified',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (customer_id) REFERENCES customers (id) ON DELETE CASCADE
      );
    ''');

    // 4. boilers
    await db.execute('''
      CREATE TABLE boilers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        service_location_id INTEGER,
        is_central INTEGER NOT NULL DEFAULT 1,
        centraal_type TEXT,
        type_b_text TEXT,
        type_c_text TEXT,
        heating_type TEXT DEFAULT 'individueel',
        boiler_operation TEXT DEFAULT 'condenserend',
        fuel_type TEXT NOT NULL DEFAULT 'gas',
        fuel_subtype TEXT DEFAULT 'aardgas',
        fuel_other_text TEXT,
        burner_technology TEXT DEFAULT 'premix',
        boiler_brand TEXT,
        boiler_brand_unknown INTEGER NOT NULL DEFAULT 0,
        boiler_model TEXT,
        boiler_model_unknown INTEGER NOT NULL DEFAULT 0,
        boiler_serial_number TEXT,
        boiler_serial_number_unknown INTEGER NOT NULL DEFAULT 0,
        boiler_construction_year INTEGER,
        boiler_construction_year_unknown INTEGER NOT NULL DEFAULT 0,
        boiler_nominal_power_kw REAL,
        boiler_type TEXT,
        burner_brand TEXT,
        burner_model TEXT,
        burner_serial_number TEXT,
        burner_construction_year INTEGER,
        burner_type TEXT,
        burner_flow_rate TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (service_location_id) REFERENCES service_locations (id) ON DELETE CASCADE
      );
    ''');

    // 5. maintenance_visits
    await db.execute('''
      CREATE TABLE maintenance_visits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_id INTEGER,
        service_location_id INTEGER,
        boiler_id INTEGER,
        activity_type TEXT NOT NULL DEFAULT 'onderhoud',
        attest_number TEXT,
        visit_date TEXT NOT NULL,
        start_time TEXT,
        end_time TEXT,
        operating_pressure_bar REAL,
        operating_temp_celsius REAL,
        safety_valve_ok INTEGER,
        air_supply_ok INTEGER,
        flue_gas_discharge_ok INTEGER,
        ventilation_ok INTEGER,
        overall_assessment TEXT,
        safety_conclusion TEXT,
        next_inspection_date TEXT,
        defects_notes TEXT,
        general_remarks TEXT,
        technician_signature_path TEXT,
        customer_signature_path TEXT,
        customer_signature_name TEXT,
        snapshot_json TEXT,
        pdf_status TEXT NOT NULL DEFAULT 'draft',
        pdf_path TEXT,
        email_customer_status TEXT NOT NULL DEFAULT 'not_queued',
        email_technician_status TEXT NOT NULL DEFAULT 'not_queued',
        veka_status TEXT NOT NULL DEFAULT 'not_submitted',
        veka_meldingsnummer TEXT,
        veka_manual_note TEXT,
        is_draft INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (customer_id) REFERENCES customers (id) ON DELETE SET NULL,
        FOREIGN KEY (service_location_id) REFERENCES service_locations (id) ON DELETE SET NULL,
        FOREIGN KEY (boiler_id) REFERENCES boilers (id) ON DELETE SET NULL
      );
    ''');

    // 6. measurement_captures
    await db.execute('''
      CREATE TABLE measurement_captures (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        visit_id INTEGER NOT NULL,
        slot TEXT NOT NULL,
        raw_qr_payload TEXT,
        reported_fuel TEXT,
        o2_percent REAL,
        co2_percent REAL,
        co_ppm REAL,
        co_corrected_ppm REAL,
        flue_temp_celsius REAL,
        ambient_temp_celsius REAL,
        net_temp_celsius REAL,
        combustion_efficiency_hi REAL,
        combustion_efficiency_hs REAL,
        flue_pressure_pa REAL,
        excess_air REAL,
        losses_percent REAL,
        dew_point_celsius REAL,
        no_ppm REAL,
        so2_ppm REAL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (visit_id) REFERENCES maintenance_visits (id) ON DELETE CASCADE
      );
    ''');

    // Relational Indexing
    await db.execute(
        'CREATE INDEX idx_loc_cust ON service_locations (customer_id);');
    await db
        .execute('CREATE INDEX idx_boil_loc ON boilers (service_location_id);');
    await db.execute(
        'CREATE INDEX idx_vis_date ON maintenance_visits (visit_date);');
    await db.execute(
        'CREATE INDEX idx_vis_cust ON maintenance_visits (customer_id);');
    await db.execute(
        'CREATE INDEX idx_meas_vis ON measurement_captures (visit_id);');
  }
}

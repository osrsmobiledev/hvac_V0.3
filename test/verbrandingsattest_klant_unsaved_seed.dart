import 'dart:convert';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> seedValidDraftWithPendingKlantEdit(
  Database db,
  String sigPath,
) async {
  const now = '2026-11-25T10:00:00.000';
  await db.insert('technician_profile', {
    'id': 1,
    'company_name': 'HVAC BV',
    'kbo_number': 'BE 0400.378.485',
    'street': 'Kerkstraat',
    'house_number': '1',
    'postal_code': '9000',
    'city': 'Gent',
    'phone': '+32 470 12 34 56',
    'email': 'info@hvac.be',
    'technician_first_name': 'Jan',
    'technician_last_name': 'Peeters',
    'gv_number': 'GV12345',
    'created_at': now,
    'updated_at': now,
  });
  await db.insert('customers', {
    'id': 1,
    'first_name': 'Piet',
    'last_name': 'Janssens',
    'email': 'piet@example.com',
    'street': 'Dorpstraat',
    'house_number': '10',
    'postal_code': '9000',
    'city': 'Gent',
    'created_at': now,
    'updated_at': now,
  });
  await db.insert('service_locations', {
    'id': 1,
    'customer_id': 1,
    'role': 'owner',
    'street': 'Dorpstraat',
    'house_number': '10',
    'postal_code': '9000',
    'municipality': 'Gent',
    'created_at': now,
    'updated_at': now,
  });
  await db.insert('boilers', {
    'id': 1,
    'service_location_id': 1,
    'is_central': 1,
    'centraal_type': 'centraal',
    'heating_type': 'water',
    'boiler_operation': 'condenserend',
    'fuel_type': 'gas',
    'fuel_subtype': 'aardgas',
    'burner_technology': 'atmosferisch',
    'boiler_brand': 'Vaillant',
    'boiler_model': 'ecoTEC',
    'boiler_serial_number': 'SN12345',
    'boiler_nominal_power_kw': 24.0,
    'boiler_construction_year': 2020,
    'boiler_type': 'Type C',
    'created_at': now,
    'updated_at': now,
  });
  final undoJson = jsonEncode({
    'draftId': 1,
    'initialCustomerId': 1,
    'initialLocationId': 1,
    'activeCustomerId': 1,
    'activeLocationId': 1,
    'createdCustomerIds': <int>[],
    'createdLocationIds': <int>[],
  });
  await db.insert('maintenance_visits', {
    'id': 1,
    'customer_id': 1,
    'service_location_id': 1,
    'boiler_id': 1,
    'activity_type': 'onderhoud',
    'attest_number': 'ATTEST-001',
    'visit_date': '2026-11-25',
    'start_time': '08:00',
    'end_time': '09:00',
    'operating_pressure_bar': 1.5,
    'operating_temp_celsius': 65.0,
    'gas_pressure_meter_mbar': 20.0,
    'gas_pressure_block_mbar': 19.5,
    'gas_pressure_burner_bed_mbar': 10.0,
    'flue_pressure_ok': 1,
    'ventilation_ok': 1,
    'fuel_supply_tightness_ok': 1,
    'flue_tightness_ok': 1,
    'air_supply_ok': 1,
    'flue_gas_discharge_ok': 1,
    'safety_valve_ok': 1,
    'toestel_werking_goed': 'Goed',
    'toestel_werking_veilig': 'Veilig',
    'technician_signature_path': sigPath,
    'customer_signature_exception': 'absent',
    'klant_undo_json': undoJson,
    'is_draft': 1,
    'created_at': now,
    'updated_at': now,
  });
  for (final slot in ['proef1', 'proef2_laaglast']) {
    await db.insert('measurement_captures', {
      'visit_id': 1,
      'slot': slot,
      'o2_percent': 4.5,
      'co2_percent': 9.2,
      'co_mg_kwh': 12.0,
      'flue_temp_celsius': 55.0,
      'ambient_temp_celsius': 20.0,
      'net_temp_celsius': 35.0,
      'flue_pressure_pa': -10.0,
      'combustion_efficiency_hi': 96.5,
      'created_at': now,
    });
  }
}

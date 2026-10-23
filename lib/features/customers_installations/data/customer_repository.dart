import 'package:sqflite/sqflite.dart';
import '../../../core/database/app_database.dart';
import '../domain/customer.dart';
import '../domain/service_location.dart';

/// Repository for persistent SQLite customer and service location management.
///
/// Ensures clean in-place updates, avoids duplicate records, and preserves
/// relational cascade deletion between customers and their locations.
class CustomerRepository {
  final AppDatabase _database;

  CustomerRepository([AppDatabase? database])
      : _database = database ?? AppDatabase.instance;

  Future<Database> get _db => _database.database;

  /// Searches customers matching [query] across name, company, city, and phone.
  Future<List<Customer>> searchCustomers(String query) async {
    final db = await _db;
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return getAllCustomers();
    }

    final likePattern = '%$trimmed%';
    final results = await db.query(
      'customers',
      where: '''
        last_name LIKE ? OR 
        first_name LIKE ? OR 
        company_name LIKE ? OR 
        city LIKE ? OR 
        street LIKE ? OR 
        phone LIKE ?
      ''',
      whereArgs: [
        likePattern,
        likePattern,
        likePattern,
        likePattern,
        likePattern,
        likePattern,
      ],
      orderBy: 'updated_at DESC',
      limit: 50,
    );

    return results.map(Customer.fromMap).toList();
  }

  /// Fetches recent customers ordered by last updated date.
  Future<List<Customer>> getAllCustomers({int limit = 50}) async {
    final db = await _db;
    final results = await db.query(
      'customers',
      orderBy: 'updated_at DESC',
      limit: limit,
    );
    return results.map(Customer.fromMap).toList();
  }

  /// Fetches a single customer by [id].
  Future<Customer?> getCustomerById(int id) async {
    final db = await _db;
    final results = await db.query(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return Customer.fromMap(results.first);
  }

  /// Inserts or updates [customer] in place to prevent ghost duplicate records.
  Future<Customer> saveCustomer(Customer customer) async {
    final db = await _db;
    final now = DateTime.now();

    if (customer.id == null) {
      final map = customer.toMap();
      map['created_at'] = now.toIso8601String();
      map['updated_at'] = now.toIso8601String();
      final id = await db.insert('customers', map);
      return customer.copyWith(id: id, createdAt: now, updatedAt: now);
    } else {
      final map = customer.toMap();
      map['updated_at'] = now.toIso8601String();
      await db.update(
        'customers',
        map,
        where: 'id = ?',
        whereArgs: [customer.id],
      );
      return customer.copyWith(updatedAt: now);
    }
  }

  /// Deletes a customer by [id], which cascades to their service locations.
  Future<int> deleteCustomer(int id) async {
    final db = await _db;
    return db.delete('customers', where: 'id = ?', whereArgs: [id]);
  }

  /// Fetches all service locations registered for [customerId].
  Future<List<ServiceLocation>> getLocationsForCustomer(int customerId) async {
    final db = await _db;
    final results = await db.query(
      'service_locations',
      where: 'customer_id = ?',
      whereArgs: [customerId],
      orderBy: 'updated_at DESC',
    );
    return results.map(ServiceLocation.fromMap).toList();
  }

  /// Fetches the primary/latest service location for [customerId].
  Future<ServiceLocation?> getPrimaryLocationForCustomer(int customerId) async {
    final locations = await getLocationsForCustomer(customerId);
    return locations.isEmpty ? null : locations.first;
  }

  /// Inserts or updates a [location] in SQLite.
  Future<ServiceLocation> saveServiceLocation(ServiceLocation location) async {
    final db = await _db;
    final now = DateTime.now();

    if (location.id == null) {
      final map = location.toMap();
      map['created_at'] = now.toIso8601String();
      map['updated_at'] = now.toIso8601String();
      final id = await db.insert('service_locations', map);
      return location.copyWith(id: id, createdAt: now, updatedAt: now);
    } else {
      final map = location.toMap();
      map['updated_at'] = now.toIso8601String();
      await db.update(
        'service_locations',
        map,
        where: 'id = ?',
        whereArgs: [location.id],
      );
      return location.copyWith(updatedAt: now);
    }
  }

  /// Atomically saves [customer], their [location], and links them to draft [visitId].
  Future<({Customer customer, ServiceLocation location})>
      saveCustomerWithLocation({
    required Customer customer,
    required ServiceLocation location,
    required int visitId,
  }) async {
    final db = await _db;
    final now = DateTime.now();

    return await db.transaction((txn) async {
      int customerId;
      Customer savedCustomer;
      if (customer.id == null) {
        final custMap = customer.toMap();
        custMap['created_at'] = now.toIso8601String();
        custMap['updated_at'] = now.toIso8601String();
        customerId = await txn.insert('customers', custMap);
        savedCustomer = customer.copyWith(
          id: customerId,
          createdAt: now,
          updatedAt: now,
        );
      } else {
        customerId = customer.id!;
        final custMap = customer.toMap();
        custMap['updated_at'] = now.toIso8601String();
        await txn.update(
          'customers',
          custMap,
          where: 'id = ?',
          whereArgs: [customerId],
        );
        savedCustomer = customer.copyWith(updatedAt: now);
      }

      int locationId;
      ServiceLocation savedLocation;
      final locMap = location.copyWith(customerId: customerId).toMap();
      if (location.id == null) {
        locMap['created_at'] = now.toIso8601String();
        locMap['updated_at'] = now.toIso8601String();
        locationId = await txn.insert('service_locations', locMap);
        savedLocation = location.copyWith(
          id: locationId,
          customerId: customerId,
          createdAt: now,
          updatedAt: now,
        );
      } else {
        locationId = location.id!;
        locMap['updated_at'] = now.toIso8601String();
        await txn.update(
          'service_locations',
          locMap,
          where: 'id = ?',
          whereArgs: [locationId],
        );
        savedLocation = location.copyWith(updatedAt: now);
      }

      await txn.update(
        'maintenance_visits',
        {
          'customer_id': customerId,
          'service_location_id': locationId,
          'updated_at': now.toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [visitId],
      );

      return (customer: savedCustomer, location: savedLocation);
    });
  }
}

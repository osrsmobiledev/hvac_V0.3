import 'package:hvac_app/features/email_delivery/data/email_delivery_coordinator.dart';
import 'package:hvac_app/features/email_delivery/data/email_settings_model.dart';
import 'package:sqflite/sqflite.dart';

/// Test mock of [EmailDeliveryCoordinator] recording actions and mocking settings.
class MockEmailDeliveryCoordinator extends EmailDeliveryCoordinator {
  int manualProcessCalls = 0;
  int? lastCorrectJobId, lastRetryJobId, lastResolveJobId;
  String? lastCorrectEmail, lastResolveNotes;
  final Database? db;

  MockEmailDeliveryCoordinator({this.db});

  @override
  Future<EmailSettings> loadSettings() async {
    final rows =
        db != null ? await db!.query('technician_profile', limit: 1) : null;
    return rows != null && rows.isNotEmpty
        ? EmailSettings.fromMap(rows.first, hasPassword: true)
        : const EmailSettings(smtpState: 'configured');
  }

  @override
  Future<OutboxDispatchResult> processOutbox({bool forceManual = false}) async {
    if (forceManual) manualProcessCalls++;
    return OutboxDispatchResult.success;
  }

  @override
  Future<bool> correctRecipientEmail(int jobId, String newEmail) async {
    lastCorrectJobId = jobId;
    lastCorrectEmail = newEmail;
    return true;
  }

  @override
  Future<bool> retryJob(int jobId) async {
    lastRetryJobId = jobId;
    return true;
  }

  @override
  Future<bool> resolveJobManually(int jobId, {required String notes}) async {
    lastResolveJobId = jobId;
    lastResolveNotes = notes;
    return true;
  }
}

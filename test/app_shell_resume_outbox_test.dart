import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/shell/app_shell_screen.dart';
import 'package:hvac_app/core/database/app_database.dart';
import 'package:hvac_app/core/services/app_warmup_service.dart';
import 'package:hvac_app/features/email_delivery/data/email_delivery_coordinator.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class _MockDeliveryCoordinator extends EmailDeliveryCoordinator {
  int processCalls = 0;
  final List<bool> forceManualLog = [];

  @override
  Future<OutboxDispatchResult> processOutbox({bool forceManual = false}) async {
    processCalls++;
    forceManualLog.add(forceManual);
    return OutboxDispatchResult.success;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;

  setUp(() async {
    db = await AppDatabase.instance.initDatabase(
      customPath: inMemoryDatabasePath,
    );
    AppDatabase.instance.setDatabaseForTesting(db);
    await AppWarmupService.instance.warmup();
  });

  tearDown(() async {
    await AppDatabase.instance.close();
  });

  testWidgets(
      'AppShellScreen registers observer, triggers outbox on mount, resume, and unregisters on dispose',
      (tester) async {
    final coordinator = _MockDeliveryCoordinator();

    await tester.pumpWidget(
      MaterialApp(
        home: AppShellScreen(
          deliveryCoordinator: coordinator,
        ),
      ),
    );
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 60)));
    await tester.pumpAndSettle();

    // 1. Initial check on mount
    expect(coordinator.processCalls, 1);
    expect(coordinator.forceManualLog.first, isFalse);

    // 2. Valid transition: resumed -> inactive -> hidden -> paused
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    expect(coordinator.processCalls, 1);

    // 3. Resume: paused -> hidden -> inactive -> resumed
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(coordinator.processCalls, 2);
    expect(coordinator.forceManualLog.last, isFalse);

    // 4. Dispose unregisters observer
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    // Transition again after dispose:
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    // Process calls remain at 2 because observer was unregistered
    expect(coordinator.processCalls, 2);
  });
}

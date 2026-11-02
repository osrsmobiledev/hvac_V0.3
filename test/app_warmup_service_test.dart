// File: test/app_warmup_service_test.dart
// Responsibility: Unit tests for AppWarmupService (engine pre-warming & cache).

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:hvac_app/core/database/app_database.dart';
import 'package:hvac_app/core/services/app_warmup_service.dart';
import 'package:hvac_app/features/certificate_draft/data/draft_repository.dart';
import 'package:hvac_app/features/certificate_draft/data/technician_profile_repository.dart';
import 'package:hvac_app/features/certificate_draft/domain/draft_visit.dart';
import 'package:hvac_app/features/certificate_draft/domain/technician_profile.dart';

class FakeDatabase implements Database {
  @override
  bool get isOpen => true;

  @override
  Future<List<Map<String, Object?>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    return [];
  }

  @override
  Future<List<Map<String, Object?>>> rawQuery(String sql,
      [List<Object?>? arguments]) async {
    return [];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeAppDatabase implements AppDatabase {
  final FakeDatabase _db = FakeDatabase();

  @override
  Future<Database> get database async => _db;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeDraftRepository implements DraftRepository {
  int callCount = 0;

  @override
  Future<DraftVisit> getOrCreateActiveDraft({Database? dbOverride}) async {
    callCount++;
    return const DraftVisit(
      id: 42,
      activityType: 'onderhoud',
      attestNumber: 'TEST-001',
      visitDate: '2026-10-31',
      startTime: '',
      endTime: '',
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeTechnicianProfileRepository implements TechnicianProfileRepository {
  int callCount = 0;

  @override
  Future<TechnicianProfile> getProfile({Database? dbOverride}) async {
    callCount++;
    return const TechnicianProfile(
      technicianFirstName: 'Bob',
      technicianLastName: 'Builder',
      companyName: 'HVAC Solutions BV',
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(() {
    AppWarmupService.instance.resetForTesting();
  });

  group('AppWarmupService Unit Tests', () {
    test('Cold boot executes parallel pre-warm tasks and caches result',
        () async {
      final fakeDb = FakeAppDatabase();
      final fakeDraftRepo = FakeDraftRepository();
      final fakeProfileRepo = FakeTechnicianProfileRepository();

      expect(AppWarmupService.instance.isWarmedUp, isFalse);
      expect(AppWarmupService.instance.cachedResult, isNull);

      final result = await AppWarmupService.instance.warmup(
        databaseOverride: fakeDb,
        draftRepoOverride: fakeDraftRepo,
        profileRepoOverride: fakeProfileRepo,
      );

      expect(AppWarmupService.instance.isWarmedUp, isTrue);
      expect(result.activeDraft?.id, 42);
      expect(result.profile?.technicianLastName, 'Builder');
      expect(fakeDraftRepo.callCount, 1);
      expect(fakeProfileRepo.callCount, 1);
    });

    test('Warm boot returns cached result immediately without redundant queries',
        () async {
      final fakeDb = FakeAppDatabase();
      final fakeDraftRepo = FakeDraftRepository();
      final fakeProfileRepo = FakeTechnicianProfileRepository();

      // First run (cold)
      await AppWarmupService.instance.warmup(
        databaseOverride: fakeDb,
        draftRepoOverride: fakeDraftRepo,
        profileRepoOverride: fakeProfileRepo,
      );

      // Second run (warm)
      final secondResult = await AppWarmupService.instance.warmup(
        databaseOverride: fakeDb,
        draftRepoOverride: fakeDraftRepo,
        profileRepoOverride: fakeProfileRepo,
      );

      expect(secondResult.activeDraft?.id, 42);
      // Calls must NOT increase because cached result was returned
      expect(fakeDraftRepo.callCount, 1);
      expect(fakeProfileRepo.callCount, 1);
    });
  });
}

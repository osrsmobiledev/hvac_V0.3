import 'package:flutter/foundation.dart';
import '../../../core/utils/debouncer.dart';
import '../data/boiler_draft_repository.dart';
import '../domain/boiler_draft.dart';

/// State holder for the active boiler draft across the certificate workflow.
///
/// Follows the official Flutter Architecture Guide (UI Layer + Data Layer):
/// - Holds the active [BoilerDraft] in memory for instantaneous (0ms) reactive UI updates.
/// - Debounces SQLite persistence asynchronously in the background without blocking the UI.
class BoilerDraftNotifier extends ChangeNotifier {
  final BoilerDraftRepository _repository;

  BoilerDraft _draft = BoilerDraft.initial();
  bool _isLoading = true;
  bool _isDisposed = false;
  final _debouncer = Debouncer();

  BoilerDraftNotifier({BoilerDraftRepository? repository})
      : _repository = repository ?? BoilerDraftRepository();

  BoilerDraft get draft => _draft;
  bool get isLoading => _isLoading;

  /// Loads the initial boiler draft from SQLite when entering the certificate.
  Future<void> loadInitial() async {
    try {
      final loaded = await _repository.getOrCreateActiveBoiler();
      if (_isDisposed) return;
      _draft = loaded;
      _isLoading = false;
      notifyListeners();
    } catch (e, stack) {
      if (_isDisposed) return;
      debugPrint('[BoilerDraftNotifier] loadInitial error: $e\n$stack');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Synchronously updates the in-memory draft (0ms lag) and queues an async SQLite write.
  void updateDraft(BoilerDraft updated, {bool immediateSave = false}) {
    if (_isDisposed) return;
    _draft = updated;
    _isLoading = false;
    notifyListeners();

    if (immediateSave) {
      _debouncer.cancel();
      _saveToDb();
    } else {
      _debouncer.run(_saveToDb);
    }
  }

  Future<void> _saveToDb() async {
    try {
      await _repository.saveBoilerDraft(_draft);
    } catch (e, stack) {
      debugPrint('[BoilerDraftNotifier] _saveToDb error: $e\n$stack');
    }
  }

  /// Flushes any pending debounced save to SQLite immediately.
  void flush() {
    _debouncer.flush();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _debouncer.dispose();
    super.dispose();
  }
}

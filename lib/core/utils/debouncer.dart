import 'dart:async';
import 'package:flutter/foundation.dart';

/// Lightweight, reusable debouncer that enforces Golden Rule 1 (Offline-First Draft Safety).
///
/// Features:
/// - Delays high-frequency callbacks (e.g. text inputs) by a configurable [duration]
///   before persisting to the local SQLite database.
/// - [flush]: Immediately triggers any pending action if active, cancelling the timer.
/// - [dispose]: Automatically flushes any pending draft save before unmounting or tab-switching,
///   guaranteeing that unsaved keystrokes are never lost.
/// - [cancel]: Clears the timer and pending action without executing it.
class Debouncer {
  final Duration duration;
  Timer? _timer;
  VoidCallback? _pendingAction;

  Debouncer({this.duration = const Duration(milliseconds: 300)});

  /// Whether a debounced action is currently scheduled and waiting to run.
  bool get isPending => _timer?.isActive ?? false;

  /// Runs or reschedules [action] after [duration].
  void run(VoidCallback action) {
    _timer?.cancel();
    _pendingAction = action;
    _timer = Timer(duration, () {
      final act = _pendingAction;
      _pendingAction = null;
      _timer = null;
      act?.call();
    });
  }

  /// Immediately executes the pending action if scheduled, cancelling the timer.
  void flush() {
    if (isPending && _pendingAction != null) {
      _timer?.cancel();
      _timer = null;
      final action = _pendingAction;
      _pendingAction = null;
      action?.call();
    }
  }

  /// Cancels any scheduled action without executing it.
  void cancel() {
    _timer?.cancel();
    _timer = null;
    _pendingAction = null;
  }

  /// Flushes any pending action to persistent storage and cleans up resources.
  void dispose() {
    flush();
    cancel();
  }
}

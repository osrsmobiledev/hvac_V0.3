import 'dart:async';

import 'package:flutter/foundation.dart';

/// Debounces edits and serializes their asynchronous writes.
class Debouncer {
  final Duration duration;
  Timer? _timer;
  FutureOr<void> Function()? _pendingAction;
  FutureOr<void> Function()? _retry;
  Future<void> _tail = Future.value();
  int _inFlight = 0;
  bool Function()? saveBlocked;
  VoidCallback? onDispose;

  Debouncer({this.duration = const Duration(milliseconds: 300)});

  bool get isPending => _timer?.isActive ?? false;

  void run(FutureOr<void> Function() action) {
    _timer?.cancel();
    _pendingAction = action;
    _timer = Timer(duration, flush);
  }

  void runNow(FutureOr<void> Function() action) {
    cancel();
    _enqueue(action);
  }

  void _enqueue(FutureOr<void> Function() action) {
    Future<void> write() async {
      try {
        await action();
        _retry = null;
      } catch (error, stack) {
        _retry = action;
        debugPrint('Draft save failed: $error\n$stack');
      } finally {
        _inFlight--;
      }
    }

    final idle = _inFlight++ == 0;
    _tail = idle ? write() : _tail.then((_) => write());
  }

  void flush() {
    final action = _pendingAction;
    cancel();
    if (action != null) _enqueue(action);
  }

  Future<void> settle({bool ignoreFailure = false}) async {
    flush();
    while (_inFlight != 0) {
      await _tail;
    }
    final retry = _retry;
    if (retry != null) {
      _enqueue(retry);
      while (_inFlight != 0) {
        await _tail;
      }
    }
    if (_retry != null && !ignoreFailure) throw StateError('Draft save failed');
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
    _pendingAction = null;
  }

  void dispose() {
    flush();
    onDispose?.call();
  }
}

import 'package:flutter/widgets.dart';

import '../../../core/utils/debouncer.dart';
import '../../reporting_delivery/data/veka_report_repository.dart';

/// Shares the mounted draft's save boundary with the reporting screen.
class DraftSaveScope extends InheritedWidget {
  final Set<Debouncer> saves;

  const DraftSaveScope({super.key, required this.saves, required super.child});

  static DraftSaveScope? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<DraftSaveScope>();

  void register(Debouncer debouncer) {
    if (saves.add(debouncer)) {
      debouncer.onDispose = () => saves.remove(debouncer);
    }
  }

  /// Returns true when any registered debouncer blocks persistence (e.g. active Klant edit).
  static bool hasBlocked(Iterable<Debouncer> saves) =>
      saves.any((save) => save.saveBlocked?.call() ?? false);

  bool get isBlocked => hasBlocked(saves);

  Future<void> settle() async {
    if (isBlocked) {
      throw const VekaException(VekaIssue.customerEditing);
    }
    for (final save in saves.toList()) {
      await save.settle();
    }
    if (isBlocked) {
      throw const VekaException(VekaIssue.customerEditing);
    }
  }

  @override
  bool updateShouldNotify(DraftSaveScope oldWidget) => saves != oldWidget.saves;
}

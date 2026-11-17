import 'dart:math';

/// One random identifier per saved report or API attempt.
String newVekaReference() {
  final random = Random.secure();
  return List.generate(
      16, (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
}

import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/core/utils/debouncer.dart';

void main() {
  group('Debouncer Unit Tests', () {
    test('Executes action after specified duration', () async {
      final debouncer = Debouncer(duration: const Duration(milliseconds: 50));
      int callCount = 0;

      debouncer.run(() => callCount++);
      expect(debouncer.isPending, isTrue);
      expect(callCount, equals(0));

      await Future<void>.delayed(const Duration(milliseconds: 70));
      expect(callCount, equals(1));
      expect(debouncer.isPending, isFalse);
    });

    test('Multiple calls within duration only execute the last action once',
        () async {
      final debouncer = Debouncer(duration: const Duration(milliseconds: 50));
      String lastValue = '';

      debouncer.run(() => lastValue = 'first');
      debouncer.run(() => lastValue = 'second');
      debouncer.run(() => lastValue = 'third');

      expect(lastValue, equals(''));

      await Future<void>.delayed(const Duration(milliseconds: 70));
      expect(lastValue, equals('third'));
    });

    test('flush() immediately triggers pending action and cancels timer',
        () async {
      final debouncer = Debouncer(duration: const Duration(milliseconds: 200));
      int counter = 0;

      debouncer.run(() => counter = 42);
      expect(counter, equals(0));
      expect(debouncer.isPending, isTrue);

      debouncer.flush();
      expect(counter, equals(42));
      expect(debouncer.isPending, isFalse);

      // Verify timer does not fire a second time later
      await Future<void>.delayed(const Duration(milliseconds: 220));
      expect(counter, equals(42));
    });

    test('dispose() flushes pending action automatically', () async {
      final debouncer = Debouncer(duration: const Duration(milliseconds: 200));
      bool saved = false;

      debouncer.run(() => saved = true);
      expect(saved, isFalse);

      debouncer.dispose();
      expect(saved, isTrue);
      expect(debouncer.isPending, isFalse);
    });

    test('cancel() drops pending action without executing', () async {
      final debouncer = Debouncer(duration: const Duration(milliseconds: 50));
      bool executed = false;

      debouncer.run(() => executed = true);
      debouncer.cancel();

      expect(debouncer.isPending, isFalse);
      await Future<void>.delayed(const Duration(milliseconds: 70));
      expect(executed, isFalse);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/features/certificate_draft/domain/boiler_draft.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/stooktoestel/fuel_category_memory.dart';

void main() {
  group('FuelCategoryMemory Unit Tests', () {
    test('Starts empty with no pre-selections', () {
      final memory = FuelCategoryMemory();
      final (gasSub, gasOther) = memory.resolveForCategory('gas');
      final (solidSub, solidOther) = memory.resolveForCategory('vast');
      final (liquidSub, liquidOther) = memory.resolveForCategory('vloeibaar');

      expect(gasSub, isEmpty);
      expect(gasOther, isEmpty);
      expect(solidSub, isEmpty);
      expect(solidOther, isEmpty);
      expect(liquidSub, isEmpty);
      expect(liquidOther, isEmpty);
    });

    test('Remembers gas and solid choices independently', () {
      final memory = FuelCategoryMemory();

      memory.onSubtype('gas', 'aardgas');
      memory.onOtherText('gas', 'Stadsgas');
      memory.onSubtype('vast', 'houtpellets');

      expect(memory.resolveForCategory('gas'), ('aardgas', 'Stadsgas'));
      expect(memory.resolveForCategory('vast'), ('houtpellets', ''));
      expect(memory.resolveForCategory('vloeibaar'), ('', ''));
    });

    test('Pre-warms from existing BoilerDraft', () {
      final memory = FuelCategoryMemory();
      const draft = BoilerDraft(
        fuelCategory: 'gas',
        fuelSubtype: 'LPG',
      );
      memory.populateFrom(draft);

      expect(memory.resolveForCategory('gas'), ('LPG', ''));
      expect(memory.resolveForCategory('vast'), ('', ''));
    });
  });
}

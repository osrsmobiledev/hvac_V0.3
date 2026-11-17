import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/core/widgets/tactical_dialog_button.dart';
import 'package:hvac_app/features/certificate_draft/data/basisregisters_models.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/klant/address_lookup_dialog.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/klant/klant_form_controllers.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/klant/klant_tab_state_data.dart';

const _first = AddressMatch(
  adresId: '101',
  volledigAdres: 'Kerkstraat 10 bus 0101',
  straatNaam: 'Kerkstraat',
  huisNummer: '10',
  busNummer: '0101',
  postcode: '9000',
  gemeenteNaam: 'Gent',
);
const _second = AddressMatch(
  adresId: '102',
  volledigAdres: 'Kerkstraat 10 bus 0102',
  straatNaam: 'Kerkstraat',
  huisNummer: '10',
  busNummer: '0102',
  postcode: '9000',
  gemeenteNaam: 'Gent',
);

Future<void> _open(
  WidgetTester tester, {
  required AddressSearch search,
  required ValueChanged<AddressMatch?> onResult,
  Future<AddressMatch> Function(AddressMatch)? verify,
  String bus = '',
}) async {
  await tester.pumpWidget(MaterialApp(
      home: Scaffold(
          body: Builder(
    builder: (context) => TextButton(
      onPressed: () async => onResult(await showDialog<AddressMatch>(
        context: context,
        builder: (_) => AddressLookupDialog(
          initialStreet: 'Kerkstraat',
          initialHouseNumber: '10',
          initialPostcode: '9000',
          initialMunicipality: 'Gent',
          initialBus: bus,
          search: search,
          verifyInstallation: verify,
        ),
      )),
      child: const Text('Open'),
    ),
  ))));
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

void main() {
  test('billing result changes only customer address fields', () {
    final controllers = KlantFormControllers();
    addTearDown(controllers.dispose);
    final state = KlantTabStateData()..isSameAsCustomer = false;
    final verified =
        _second.withVekaIds(gebouwId: '501', gebouweenheidId: '402');
    state.applyLookup(AddressLookupTarget.installation, verified, controllers);
    state.applyLookup(AddressLookupTarget.billing, _first, controllers);

    final location = controllers.toLocation(
      customerId: 1,
      role: 'owner',
      isSameAsCustomer: false,
    );
    expect(controllers.boxNumber.text, '0101');
    expect(location.boxNumber, '0102');
    expect(location.adresId, '102');
    expect(location.gebouweenheidId, '402');
  });

  testWidgets(
      'multiple buses need a choice and only the chosen unit is verified',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final verified = <String>[];
    AddressMatch? result;
    await _open(
      tester,
      search: (
              {required straat,
              required huisNummer,
              gemeente,
              postcode,
              bus}) async =>
          const BasisregistersResult.success([_first, _second]),
      onResult: (match) => result = match,
      verify: (match) async {
        verified.add(match.adresId);
        return match.withVekaIds(gebouwId: '501', gebouweenheidId: '402');
      },
    );
    final actions = find.byType(TacticalDialogActions);
    expect(tester.widget<TacticalDialogActions>(actions).onConfirm, isNull);
    expect(verified, isEmpty);

    expect(find.text(_first.volledigAdres), findsOneWidget);
    expect(find.text('9000 Gent'), findsNWidgets(2));
    final second = find.text(_second.volledigAdres);
    await tester.ensureVisible(second);
    await tester.tap(second);
    await tester.pumpAndSettle();
    expect(verified, isEmpty);
    await tester.tap(find.text(BasisregistersDictionary.lookupBtnConfirm));
    await tester.pumpAndSettle();
    expect(verified, ['102']);
    expect(result?.gebouweenheidId, '402');
    expect(result?.busNummer, '0102');
  });

  testWidgets('retry without bus keeps typed text and offers official bus',
      (tester) async {
    final queries = <String?>[];
    AddressMatch? result;
    await _open(
      tester,
      bus: '1',
      onResult: (match) => result = match,
      search: (
          {required straat,
          required huisNummer,
          gemeente,
          postcode,
          bus}) async {
        expect(gemeente, 'Gent');
        queries.add(bus);
        return (bus ?? '').isEmpty
            ? const BasisregistersResult.success([_first])
            : const BasisregistersResult.failure(
                'Geen adresresultaten gevonden.');
      },
    );
    await tester
        .tap(find.text(BasisregistersDictionary.lookupBtnSearchWithoutBus));
    await tester.pumpAndSettle();
    expect(queries, ['1', '']);
    expect(find.text('1'), findsOneWidget);
    await tester.tap(find.text(BasisregistersDictionary.lookupBtnConfirm));
    await tester.pumpAndSettle();
    expect(result?.busNummer, '0101');
    expect(result?.gebouweenheidId, isNull);
  });

  testWidgets('cancel discards late verification without popping the parent',
      (tester) async {
    final verification = Completer<AddressMatch>();
    AddressMatch? result = _second;
    await _open(
      tester,
      search: (
              {required straat,
              required huisNummer,
              gemeente,
              postcode,
              bus}) async =>
          const BasisregistersResult.success([_first]),
      onResult: (match) => result = match,
      verify: (_) => verification.future,
    );
    await tester.tap(find.text(BasisregistersDictionary.lookupBtnConfirm));
    await tester.pump();
    await tester.tap(find.text(AppDictionary.btnCancel));
    await tester.pumpAndSettle();
    verification.complete(_first);
    await tester.pumpAndSettle();
    expect(result, isNull);
    expect(find.text('Open'), findsOneWidget);
  });
}

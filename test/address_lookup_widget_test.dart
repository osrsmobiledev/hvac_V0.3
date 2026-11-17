import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/core/services/basisregisters_service.dart';
import 'package:hvac_app/features/certificate_draft/data/basisregisters_models.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/klant/address_lookup_dialog.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/klant/address_verification_badge.dart';

void main() {
  Widget buildTestApp(Widget child) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(body: child),
    );
  }

  group('AddressVerificationBadge Widget Tests', () {
    testWidgets('renders full match scenario badge in green', (tester) async {
      final fullMatch = const AddressMatch(
        adresId: '1',
        volledigAdres: 'Test 1',
        straatNaam: 'Test',
        huisNummer: '1',
        postcode: '1000',
        gemeenteNaam: 'Brussel',
      ).withVekaIds(gebouwId: '10', gebouweenheidId: '20');

      await tester.pumpWidget(
        buildTestApp(
            AddressVerificationBadge(status: fullMatch.verificationStatus)),
      );
      await tester.pumpAndSettle();

      expect(
        find.text(BasisregistersDictionary.lookupStatusFullMatch),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.verified_outlined), findsOneWidget);
    });

    testWidgets(
        'renders amber partial badge when buildingId is missing but unit is present',
        (tester) async {
      final partialMatch = const AddressMatch(
        adresId: '1',
        volledigAdres: 'Test 1',
        straatNaam: 'Test',
        huisNummer: '1',
        postcode: '1000',
        gemeenteNaam: 'Brussel',
      ).withVekaIds(gebouwId: null, gebouweenheidId: '20');

      await tester.pumpWidget(
        buildTestApp(
            AddressVerificationBadge(status: partialMatch.verificationStatus)),
      );
      await tester.pumpAndSettle();

      expect(
        find.text(BasisregistersDictionary.lookupStatusPartialMatch),
        findsOneWidget,
      );
    });

    testWidgets('renders partial match scenario badge in amber',
        (tester) async {
      final partialMatch = const AddressMatch(
        adresId: '1',
        volledigAdres: 'Test 1',
        straatNaam: 'Test',
        huisNummer: '1',
        postcode: '1000',
        gemeenteNaam: 'Brussel',
      ).withVekaIds(gebouwId: '10', gebouweenheidId: null);

      await tester.pumpWidget(
        buildTestApp(
            AddressVerificationBadge(status: partialMatch.verificationStatus)),
      );
      await tester.pumpAndSettle();

      expect(
        find.text(BasisregistersDictionary.lookupStatusPartialMatch),
        findsOneWidget,
      );
    });
  });

  group('AddressLookupDialog Widget Tests', () {
    tearDown(() {
      BasisregistersService.mockZoekAdres = null;
    });

    testWidgets('renders initial inputs pre-filled and buttons',
        (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          const AddressLookupDialog(
            initialStreet: 'Veldstraat',
            initialHouseNumber: '42',
            initialPostcode: '9000',
            initialBus: 'A',
            autoSearch:
                false, // suppress auto-search; no mock set for this test
            search: BasisregistersService.searchCandidates,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text(BasisregistersDictionary.lookupDialogTitle),
        findsOneWidget,
      );
      expect(find.text('Veldstraat'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
      expect(find.text('9000'), findsOneWidget);
      expect(find.text('A'), findsOneWidget);
      expect(
        find.text(BasisregistersDictionary.lookupBtnSearch),
        findsOneWidget,
      );
      expect(find.text(AppDictionary.btnCancel), findsOneWidget);
    });

    testWidgets(
        'shows validation error when street, number or postcode is blank',
        (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          const AddressLookupDialog(
            initialStreet: '',
            initialHouseNumber: '10',
            initialPostcode: '',
            initialBus: '',
            search: BasisregistersService.searchCandidates,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final searchBtn = find.text(BasisregistersDictionary.lookupBtnSearch);
      await tester.tap(searchBtn);
      await tester.pumpAndSettle();

      expect(
        find.text(BasisregistersDictionary.lookupValidationRequiredFields),
        findsOneWidget,
      );
    });

    testWidgets('editing query while search is in-flight drops stale results',
        (tester) async {
      final completer = Completer<BasisregistersResult>();
      BasisregistersService.mockZoekAdres = ({
        required String straat,
        required String huisNummer,
        String? gemeente,
        String? postcode,
        String? bus,
      }) =>
          completer.future;

      await tester.pumpWidget(
        buildTestApp(
          const AddressLookupDialog(
            initialStreet: 'Kerkstraat',
            initialHouseNumber: '10',
            initialPostcode: '9000',
            initialBus: '',
            autoSearch: false, // test controls search manually via button
            search: BasisregistersService.searchCandidates,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Start search for house number 10
      await tester.tap(find.text(BasisregistersDictionary.lookupBtnSearch));
      await tester.pump();

      // While request is in-flight, edit house number from 10 to 11
      final numberField = find.widgetWithText(TextField, '10');
      await tester.enterText(numberField, '11');
      await tester.pump();

      // Complete in-flight response for house number 10
      completer.complete(
        const BasisregistersResult.success([
          AddressMatch(
            adresId: '123',
            volledigAdres: 'Kerkstraat 10, 9000 Gent',
            straatNaam: 'Kerkstraat',
            huisNummer: '10',
            postcode: '9000',
            gemeenteNaam: 'Gent',
          ),
        ]),
      );
      await tester.pumpAndSettle();

      // The stale result for 10 must NOT appear
      expect(find.text('Kerkstraat 10, 9000 Gent'), findsNothing);
    });

    testWidgets('tapping cancel pops the dialog without selection',
        (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          const AddressLookupDialog(
            initialStreet: 'Veldstraat',
            initialHouseNumber: '42',
            initialPostcode: '9000',
            initialBus: '',
            autoSearch:
                false, // suppress auto-search; no mock set for this test
            search: BasisregistersService.searchCandidates,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final cancelBtn = find.text(AppDictionary.btnCancel);
      await tester.tap(cancelBtn);
      await tester.pumpAndSettle();
    });
  });
}

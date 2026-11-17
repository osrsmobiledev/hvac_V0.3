part of 'handtekeningen_card_test.dart';

void _validationTests() {
  group('HandtekeningenCard progressive disclosure & pre-flight validation',
      () {
    testWidgets('Unsigned fields fail validation and illuminate in errorRed',
        (tester) async {
      final formKey = GlobalKey<FormState>();
      EindbeoordelingDraft draft = const EindbeoordelingDraft();

      await tester.pumpWidget(buildTestWidget(
        draft: draft,
        onDraftChanged: (d) => draft = d,
        formKey: formKey,
      ));
      await tester.pumpAndSettle();

      // Initially no error
      var tiles = tester.widgetList<SignatureTile>(find.byType(SignatureTile));
      expect(tiles.first.isError, isFalse);
      expect(tiles.last.isError, isFalse);

      // Validate fails
      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();

      // Both technician and customer signature tiles show isError: true
      tiles = tester.widgetList<SignatureTile>(find.byType(SignatureTile));
      expect(tiles.first.isError, isTrue);
      expect(tiles.last.isError, isTrue);

      // Verify red border on container
      final technicianContainer = tester.widget<Container>(find
          .descendant(
            of: find.byKey(const ValueKey('signature_technician_field')),
            matching: find.byType(Container),
          )
          .first);
      final techBorder = technicianContainer.decoration as BoxDecoration;
      expect(techBorder.border?.top.color, AppColors.errorRed);
    });

    testWidgets('Signing technician clears technician error outline',
        (tester) async {
      final formKey = GlobalKey<FormState>();
      EindbeoordelingDraft draft = const EindbeoordelingDraft(
        technicianSignaturePath: 'data:image/png;base64,sample',
      );

      await tester.pumpWidget(buildTestWidget(
        draft: draft,
        onDraftChanged: (d) => draft = d,
        formKey: formKey,
      ));
      await tester.pumpAndSettle();

      expect(
          formKey.currentState!.validate(), isFalse); // Customer still missing
      await tester.pump();

      final tiles =
          tester.widgetList<SignatureTile>(find.byType(SignatureTile));
      expect(tiles.first.isError, isFalse); // Tech is signed
      expect(tiles.last.isError, isTrue); // Customer still missing
    });

    testWidgets(
        'Signed customer hides exception controls completely (foolproof)',
        (tester) async {
      EindbeoordelingDraft draft = const EindbeoordelingDraft(
        technicianSignaturePath: 'data:image/png;base64,sampleTech',
        customerSignaturePath: 'data:image/png;base64,sampleCust',
      );

      await tester.pumpWidget(buildTestWidget(
        draft: draft,
        onDraftChanged: (d) => draft = d,
      ));
      await tester.pumpAndSettle();

      // Exception trigger is completely hidden when customer has already signed
      expect(find.text(EindbeoordelingDictionary.lblKlantKanNietTekenen),
          findsNothing);
      expect(
          find.text(EindbeoordelingDictionary.btnKlantWeigert), findsNothing);
      expect(
          find.text(EindbeoordelingDictionary.btnKlantAfwezig), findsNothing);
    });

    testWidgets('Customer exception starts expanded and satisfies pre-flight',
        (tester) async {
      final formKey = GlobalKey<FormState>();
      EindbeoordelingDraft draft = const EindbeoordelingDraft(
        technicianSignaturePath: 'data:image/png;base64,sample',
        customerSignatureException: 'refused',
      );

      await tester.pumpWidget(buildTestWidget(
        draft: draft,
        onDraftChanged: (d) => draft = d,
        formKey: formKey,
      ));
      await tester.pumpAndSettle();

      // When exception is active, buttons are visible
      expect(
          find.text(EindbeoordelingDictionary.btnKlantWeigert), findsOneWidget);
      expect(
          find.text(EindbeoordelingDictionary.btnKlantAfwezig), findsOneWidget);

      // Both technician signed and customer exception provided -> passes!
      expect(formKey.currentState!.validate(), isTrue);
      await tester.pump();

      final tiles =
          tester.widgetList<SignatureTile>(find.byType(SignatureTile));
      expect(tiles.first.isError, isFalse);
      expect(tiles.last.isError, isFalse);
    });

    testWidgets(
        'Progressive disclosure: Tapping trigger expands buttons and selecting exception updates validation',
        (tester) async {
      final formKey = GlobalKey<FormState>();
      EindbeoordelingDraft draft = const EindbeoordelingDraft(
        technicianSignaturePath: 'data:image/png;base64,sample',
      );

      await tester.pumpWidget(StatefulBuilder(
        builder: (context, setState) {
          return buildTestWidget(
            draft: draft,
            onDraftChanged: (d) => setState(() => draft = d),
            formKey: formKey,
          );
        },
      ));
      await tester.pumpAndSettle();

      // Initially, exception trigger is visible but buttons are collapsed
      expect(find.text(EindbeoordelingDictionary.lblKlantKanNietTekenen),
          findsOneWidget);
      expect(
          find.text(EindbeoordelingDictionary.btnKlantWeigert), findsNothing);

      // Fails because customer signature is missing
      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();

      var tiles = tester.widgetList<SignatureTile>(find.byType(SignatureTile));
      expect(tiles.last.isError, isTrue);

      // Tap "Klant kan niet ondertekenen? ▾" to expand options
      await tester
          .tap(find.text(EindbeoordelingDictionary.lblKlantKanNietTekenen));
      await tester.pumpAndSettle();

      // Now buttons are revealed
      expect(
          find.text(EindbeoordelingDictionary.btnKlantWeigert), findsOneWidget);
      expect(
          find.text(EindbeoordelingDictionary.btnKlantAfwezig), findsOneWidget);

      // Tap [ Weigert ] button
      await tester.tap(find.text(EindbeoordelingDictionary.btnKlantWeigert));
      await tester.pumpAndSettle();

      // Customer tile now displays exception banner and isError is cleared
      tiles = tester.widgetList<SignatureTile>(find.byType(SignatureTile));
      expect(tiles.last.isError, isFalse);
      expect(find.text(EindbeoordelingDictionary.statusKlantWeigert),
          findsOneWidget);

      // Now validation succeeds!
      expect(formKey.currentState!.validate(), isTrue);
    });
  });
}

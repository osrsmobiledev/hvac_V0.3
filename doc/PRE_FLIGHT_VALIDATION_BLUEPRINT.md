# Pure Flutter Pre-Flight Validation Blueprint
**Architecture Guide for Flemish Combustion Certificate (`Verbrandingsattest Vlaanderen`)**

This guide documents the official, clean Flutter architectural pattern used for pre-flight form validation across all tabs of the `Verbrandingsattest` workflow in `hvac_V0.3`.

---

## 1. Core Architecture & Philosophy

### Why Pure Flutter `Form` instead of Database Scans?
1. **Zero Database Delays or Stale Caches:**
   - Previous implementations queried SQLite tables (`draft_repository`, `technician_profile`) to validate drafts.
   - Because user input is debounced (e.g. 300ms) before saving to SQLite, querying the database on button press often read stale data or showed false validation errors.
   - Pure Flutter `Form` + `GlobalKey<FormState>` validates **in-memory, live controller state** synchronously.
2. **Instant Visual Feedback (`AutovalidateMode.onUserInteraction`):**
   - The user sees red helper/error text directly underneath the input box as soon as they interact with or leave the field.
   - Deleting a single digit from a phone number immediately turns the field red.
3. **Single Gatekeeper ("Teleportation"):**
   - When the user presses **"Verbrandingsattest Voltooien"** on Tab 7, the coordinator (`VerbrandingsattestScreen`) checks each tab's form key:
     ```dart
     final tab2Valid = _tab2FormKey?.currentState?.validate() ?? false;
     ```
   - If invalid, the coordinator immediately calls `_tabController.animateTo(tabIndex)` and shows a standard Dutch `SnackBar`.
   - The failing tab is brought into view, and all invalid fields on that tab are highlighted in red.

---

## 2. Standard Pattern for Every Tab

Every tab (`Tab 2` through `Tab 7`) follows this identical 4-part pattern:

### Part 1: Add `onFormKeyReady` to the Tab Widget
```dart
class TabNameTab extends StatefulWidget {
  final int? visitId;
  /// Callback exposing the tab's [GlobalKey<FormState>] to the parent coordinator.
  final ValueChanged<GlobalKey<FormState>>? onFormKeyReady;

  const TabNameTab({
    super.key,
    this.visitId,
    this.onFormKeyReady,
  });
  // ...
}
```

### Part 2: Maintain `_formKey` in `_TabNameTabState`
```dart
class _TabNameTabState extends State<TabNameTab> with AutomaticKeepAliveClientMixin {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Notify parent coordinator after first layout frame
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => widget.onFormKeyReady?.call(_formKey),
    );
  }
}
```

### Part 3: Wrap Tab Contents in a `Form`
```dart
@override
Widget build(BuildContext context) {
  super.build(context);
  return Form(
    key: _formKey,
    child: WorkflowTabContainer(
      scrollKey: 'tab_name_scroll',
      children: [
        // Tab Bento sections and fields...
      ],
    ),
  );
}
```

### Part 4: Add `validator` to Input Fields
- For text fields, use standard `validator: (v) => ...`:
  ```dart
  FirmaField(
    label: AppDictionary.lblCompanyName,
    controller: nameController,
    validator: (v) => v!.trim().isEmpty ? 'Naam firma is verplicht' : null,
    onChanged: onChanged,
  )
  ```
- For custom selection tiles (e.g. Activity radio, Fuel selector), use a zero-height `FormField<T>`:
  ```dart
  FormField<String>(
    initialValue: _selectedOption,
    validator: (_) => _selectedOption.isEmpty ? 'Kies een optie' : null,
    builder: (field) => field.hasError
        ? Text(field.errorText!, style: TextStyle(color: Theme.of(context).colorScheme.error))
        : const SizedBox.shrink(),
  )
  ```

---

## 3. Coordinator Gatekeeper (`VerbrandingsattestScreen`)

In `lib/features/certificate_draft/ui/verbrandingsattest_screen.dart`:

```dart
GlobalKey<FormState>? _tab2FormKey,
    _tab3FormKey,
    _tab4FormKey,
    _tab5FormKey,
    _tab6FormKey,
    _tab7FormKey;

void _handleFinalizeAttempt() {
  final t2Valid = _tab2FormKey?.currentState?.validate() ?? false;
  final t3Valid = _tab3FormKey?.currentState?.validate() ?? false;
  final t4Valid = _tab4FormKey?.currentState?.validate() ?? false;
  final t5Valid = _tab5FormKey?.currentState?.validate() ?? false;
  final t6Valid = _tab6FormKey?.currentState?.validate() ?? false;
  final t7Valid = _tab7FormKey?.currentState?.validate() ?? false;

  void notify(int idx, String msg, GlobalKey<FormState>? key) {
    _tabController.animateTo(idx);
    TacticalFeedback.showError(context, msg);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FormScrollHelper.scrollToFirstInvalid(key?.currentContext);
    });
  }

  if (!t2Valid) return notify(1, 'Vul alle verplichte velden in op Tab 2: Start', _tab2FormKey);
  if (!t3Valid) return notify(2, 'Vul alle verplichte velden in op Tab 3: Firma - Technicus', _tab3FormKey);
  if (!t4Valid) return notify(3, 'Vul alle verplichte velden in op Tab 4: Klant', _tab4FormKey);
  if (!t5Valid) return notify(4, 'Vul alle verplichte velden in op Tab 5: Stooktoestel', _tab5FormKey);
  if (!t6Valid) return notify(5, 'Vul alle verplichte velden in op Tab 6: Meting', _tab6FormKey);
  if (!t7Valid) return notify(6, 'Vul alle verplichte velden in op Tab 7: Eindbeoordeling', _tab7FormKey);

  TacticalFeedback.showSuccess(context, 'Alle velden zijn geldig. PDF-generatie volgt in Milestone 4.');
}
```

---

## 4. Statutory Belgian Validation Rules Reference

Centralized in `lib/core/utils/belgian_formatters.dart`:

| Field | Rule | Validator Method | Error Message |
| :--- | :--- | :--- | :--- |
| **Telefoon (GSM)** | Exactly 9 digits (starts with `4`) after `+32` | `BelgianFormatters.validatePhone` | `"Ongeldig telefoonnummer (bv. 470 12 34 56)"` |
| **Telefoon (Vast)** | Exactly 8 digits (starts with `1,2,3,5,6,7,8,9`) | `BelgianFormatters.validatePhone` | `"Ongeldig telefoonnummer (bv. 470 12 34 56)"` |
| **KBO / Ondernemingsnr** | 10 digits with statutory Modulo 97 check: `97 - (first8 % 97) == checksum` | `BelgianFormatters.validateKbo` | `"Ongeldig controlegetal (Modulo 97)"` |
| **E-mailadres** | Optional or required RFC regex: `r'^[^@\s]+@[^@\s]+\.[^@\s]+$'` | `BelgianFormatters.validateEmail` | `"Vul een geldig e-mailadres in (bv. info@firma.be)"` |

---

## 5. Audit & Roadmap for Remaining Tabs (Tabs 4 to 7)

### Tab 4 (`KlantTab`)
- **Required fields:**
  - Klantnaam (`customer_name`): non-empty.
  - Straat & Huisnummer: non-empty.
  - Postcode: 4 digits (Belgian postcode range 1000–9999).
  - Gemeente: non-empty.
  - If `locatieAfwijkend == true`: Location Straat, Nr, Postcode, Gemeente must also be valid.

### Tab 5 (`StooktoestelTab`)
- **Required fields:**
  - Brandstof (`fuelCategory`): must be selected (`gasvormig`, `vloeibaar`, `vast`).
  - Ketel merk (`boiler_brand`): non-empty.
  - Ketel type / model: non-empty.
  - Nominaal vermogen (`boiler_power`): positive numeric value.
  - Bouwjaar (`boiler_year`): 4 digits (e.g. 1970–2030).
  - If separate burner: Brander merk & model.

### Tab 6 (`MetingTab`)
- **Single Form Key (`_formKey`):** Covers all 3 Bento cards simultaneously.
- **Card 1 (Goede staat van werking):**
  - Keteltemperatuur (°C): required for all fuels.
  - Gas: Gasdruk teller, gasblok, branderbed (mbar).
  - Vloeibaar (Stookolie): Sproeier merk/type, debiet, hoek, pompdruk, Bacharach rookindex (0–2).
  - Vast (Hout/Pellets): Only keteltemperatuur.
- **Card 2 (Rookgasmetingen):**
  - Statutory required fields: O2 (%), CO2 (%), Rookgastemp Tg (°C), Verbrandingsluchttemp Ta (°C), Rendement Hi (%), CO (mg/kWh).
  - **Multi-slot IndexedStack Architecture:** Keeps `Proef I`, `Proef II (Laaglast)`, and `Proef II (Hooglast)` mounted in memory simultaneously.
  - **Both Tests Mandatory:** Both `Proef I` (initiële meting vóór onderhoud) and `Proef II: Laaglast` (eindmeting na onderhoud) are strictly validated as mandatory for the attest.
  - **Optional Hooglast:** `Proef II: Hooglast` is treated as optional under VEKA rules (`isSlotRequired: false`), never showing error borders when empty.
  - Formatted with `NumericCombustionField` and `StatutoryCombustionField` using standard empty checks.
  - Switching between Proef I and Proef II preserves all validated red borders without clearing or losing error state.
  - Net temperature display updates safely in post-frame callback to avoid `setState()` during layout.
- **Card 3 (Veilige staat van werking):**
  - Wrapped with `_ValidatedCheckRow` (`FormField<bool?>`).
  - Highlights with high-visibility red border (`AppColors.errorRed`) if left unanswered (`null`).
  - Statutorily filtered by fuel & boiler type:
    - All: Druk rookgaskanaal, Verluchting & ventilatie stooklokaal.
    - Gas: Dichtheid brandstoftoevoerleiding.
    - Type C: Dichtheid rookgasafvoer.
    - Type B: Geen ongewenste condensvorming.
    - Vloeibaar: Geen zichtbaar oliespoor.
    - Vast: Zelden hinderlijke/milieuverontreinigende rook.

### Tab 7 (`EindbeoordelingTab`)
- **Form Key (`_formKey`):** Exposed via `onFormKeyReady` and registered as `_tab7FormKey` in `VerbrandingsattestScreen`.
- **Card 1 (Staat van werking & Veiligheid):**
  - `toestelWerkingGoed`: must be `'Goed'` or `'Niet goed'`.
  - `toestelWerkingVeilig`: must be `'Veilig'` or `'Niet veilig'`.
  - Wrapped with `_ValidatedBinaryCheck` (`FormField<bool?>`), turning red on submission if unanswered.
- **Card 3 (Handtekeningen):**
  - `technicianSignaturePath`: required before finalization. Wrapped with `FormField<String>` and turns `SignatureTile` border red with red "Tik om te tekenen" prompt if missing.
  - `customerSignaturePath` / `customerSignatureException`: must have either customer signature or exception (`'refused'` / `'absent'`). Wrapped with `FormField<String>` and illuminates customer signature tile in red if neither is provided. Selecting `[ 🚫 Weigert ]` or `[ 👤 Afwezig ]` or drawing a signature immediately clears the error state with zero layout shift.

---

## 6. Non-Negotiable Development Constraints
1. **Max 250 Lines per File:** Split tabs and sections if they approach 240 lines.
2. **Zero Fake Defaults:** Never pre-fill dummy data or fake compliance checks.
3. **Run Checks Before Handoff:**
   ```powershell
   flutter analyze   # Must be 0 errors
   flutter test      # Must be 100% green
   ```

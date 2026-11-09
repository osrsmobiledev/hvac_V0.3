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
GlobalKey<FormState>? _tab2FormKey;
GlobalKey<FormState>? _tab3FormKey;
GlobalKey<FormState>? _tab4FormKey;
// ...

void _handleFinalizeAttempt() {
  final tab2Valid = _tab2FormKey?.currentState?.validate() ?? false;
  final tab3Valid = _tab3FormKey?.currentState?.validate() ?? false;
  final tab4Valid = _tab4FormKey?.currentState?.validate() ?? false;

  void notify(int tabIndex, String msg) {
    _tabController.animateTo(tabIndex);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 3)),
    );
  }

  if (!tab2Valid) return notify(1, 'Vul alle verplichte velden in op Tab 2: Start');
  if (!tab3Valid) return notify(2, 'Vul alle verplichte velden in op Tab 3: Firma - Technicus');
  if (!tab4Valid) return notify(3, 'Vul alle verplichte velden in op Tab 4: Klant');

  // All valid -> proceed to PDF generation
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
- **Required fields:**
  - At least one active measurement slot completed (e.g. `Na onderhoud`).
  - Required statutory values: O2 or CO2 (%), Rookgastemperatuur (°C), CO (mg/kWh or ppm).
  - Safety checks: Verluchtingsopeningen, Rookgasafvoer.

### Tab 7 (`EindbeoordelingTab`)
- **Required fields:**
  - `toestelWerkingGoed`: must be `'Goed'` or `'Niet goed'`.
  - `toestelWerkingVeilig`: must be `'Veilig'` or `'Niet veilig'`.
  - `technicianSignature`: must have at least one stroke drawn.
  - `customerSignature`: must have at least one stroke drawn.

---

## 6. Non-Negotiable Development Constraints
1. **Max 250 Lines per File:** Split tabs and sections if they approach 240 lines.
2. **Zero Fake Defaults:** Never pre-fill dummy data or fake compliance checks.
3. **Run Checks Before Handoff:**
   ```powershell
   flutter analyze   # Must be 0 errors
   flutter test      # Must be 100% green
   ```

# Verbrandingsattest Vlaanderen — 7-Tab Workflow Audit & Findings

> **Date:** November 20, 2026  
> **Status:** Read-Only Audit Complete (Milestone 6 post-slice reference)  
> **Target:** Post-Milestone 6 UI/UX & Form Polish Pass  
> **Scope:** Tabs 0 through 6 of `VerbrandingsattestScreen` (`lib/features/certificate_draft/ui/tabs/`)

---

## 1. Executive Summary

This audit evaluates all 7 form tabs in the HVAC Maintenance App against the architectural standards in [`ARCHITECTURE.md`](file:///c:/Users/Admin/Documents/hvac_V0.3/ARCHITECTURE.md), the working rules in [`AGENTS.md`](file:///c:/Users/Admin/Documents/hvac_V0.3/AGENTS.md), and official Flutter best practices:

- **Current Health:**
  - **430 / 430 tests passing**.
  - **0 compiler warnings, 0 linter errors**.
  - All Dart files strictly comply with the $\le 250$ lines limit.
  - All tabs use [`WorkflowTabContainer`](file:///c:/Users/Admin/Documents/hvac_V0.3/lib/core/widgets/workflow_tab_container.dart) with responsive 600px tablet width constraints and scroll persistence (`PageStorageKey`).
  - Draft safety is universal: all form edits auto-save to SQLite via debouncers registered in [`DraftSaveScope`](file:///c:/Users/Admin/Documents/hvac_V0.3/lib/features/certificate_draft/ui/draft_save_scope.dart).
- **Audit Objective:**
  Identify subtle UX frictions, keyboard traps, missing input formatters, hardcoded validation strings, and incomplete feature hooks so they can be addressed cleanly in a single focused polish pass after Milestone 6 is accepted.

---

## 2. Cross-Tab / Global Findings

### G-1. Tap-to-Dismiss Keyboard on Whitespace
- **Current Behavior:** [`WorkflowTabContainer`](file:///c:/Users/Admin/Documents/hvac_V0.3/lib/core/widgets/workflow_tab_container.dart#L36) sets `keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag`. The keyboard dismisses when the user drags the screen, but tapping on empty padding or whitespace between cards does not close the keyboard.
- **Rule Reference:** `AGENTS.md` Section 3 ("Wrap form screens in a `GestureDetector(onTap: () => FocusScope.of(context).unfocus())` so tapping outside dismisses the phone keyboard").
- **Fix:** Wrap the inner `Align`/`SingleChildScrollView` of `WorkflowTabContainer` with a `GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => FocusScope.of(context).unfocus())`.

### G-2. Trailing Colon in Error Snackbar for Zero-Jump Fields
- **Current Behavior:** In [`verbrandingsattest_screen.dart`](file:///c:/Users/Admin/Documents/hvac_V0.3/lib/features/certificate_draft/ui/verbrandingsattest_screen.dart#L105-L109):
  ```dart
  final detail = FormScrollHelper.findFirstError(key?.currentContext);
  final msg = detail != null
      ? '$tabTitle: $detail'
      : VisitHistoryDictionary.checkTab(tabTitle);
  ```
  On tabs where validators return `''` (empty string) to trigger red borders without jumping error text (e.g. Tab 4 Stooktoestel, Tab 6 Handtekeningen), `detail` is `""`. Because `detail != null` evaluates to `true`, the toast message reads: `"Stooktoestel: "` with a trailing colon and no error text.
- **Fix:** Update condition to: `detail != null && detail.trim().isNotEmpty`.

### G-3. Hardcoded Dutch Validation Messages
- **Current Behavior:** Several tabs have inline strings like `'Voornaam is verplicht'`, `'Straat is verplicht'`, `'Huisnummer is verplicht'` directly in `validator:` callbacks rather than pulling from [`AppDictionary`](file:///c:/Users/Admin/Documents/hvac_V0.3/lib/app/localization/app_dictionary.dart).
- **Rule Reference:** `AGENTS.md` Section 3 ("All user-facing app text, labels, buttons, validation messages, and PDF outputs must be in Dutch (Flemish), centralized in `app_dictionary.dart` or feature-scoped dictionaries").
- **Fix:** Centralize recurring required-field error messages into `AppDictionary` (e.g. `AppDictionary.errRequiredField(fieldName)` or explicit constants).

---

## 3. Tab-by-Tab Detailed Findings

### Tab 0: Data (`DataTab`)
- **Files:** [`data_tab.dart`](file:///c:/Users/Admin/Documents/hvac_V0.3/lib/features/certificate_draft/ui/tabs/data_tab.dart) (156 lines), [`meetgegevens_card.dart`](file:///c:/Users/Admin/Documents/hvac_V0.3/lib/features/certificate_draft/ui/tabs/data/meetgegevens_card.dart), [`rookgassen_card.dart`](file:///c:/Users/Admin/Documents/hvac_V0.3/lib/features/certificate_draft/ui/tabs/data/rookgassen_card.dart).
- **Role:** Live/incoming flue gas telemetry display, Eurolyzer QR import, telemetry reset.
- **Audit Results:**
  - **Keyboard:** Read-only telemetry cards; no text input fields; no keyboard conflicts.
  - **Scanning:** Fully wired to [`EurolyzerScannerModal.scan`](file:///c:/Users/Admin/Documents/hvac_V0.3/lib/features/certificate_draft/ui/tabs/meting/eurolyzer_scanner_modal.dart).
  - **Safety:** Overwrite confirmation dialog guards against accidental loss of existing data.
  - **Findings:** Clean. No functional or UX defects found.

---

### Tab 1: Start (`StartTab`)
- **Files:** [`start_tab.dart`](file:///c:/Users/Admin/Documents/hvac_V0.3/lib/features/certificate_draft/ui/tabs/start_tab.dart) (225 lines), [`activity_option_tile.dart`](file:///c:/Users/Admin/Documents/hvac_V0.3/lib/features/certificate_draft/ui/tabs/start/activity_option_tile.dart).
- **Role:** Maintenance vs Commissioning selection, certificate sequence number.
- **Audit Results:**
  - **Keyboard:** `TextInputAction.done` on sequence number.
  - **Findings:**
    1. **Hardcoded Strings:** Line 159 (`'Kies een activiteitstype (Onderhoud of Eerste ingebruikname)'`) and Line 212 (`'Volgnummer attest is verplicht'`) are hardcoded.
    2. **Input Formatting:** Attest sequence number uses `TextInputType.text` with a `#` prefix. Missing `LengthLimitingTextInputFormatter` or uppercase formatter if technicians use alphanumeric codes (e.g. `2026-001A`).

---

### Tab 2: Firma & Technicus (`FirmaTechnicusTab`)
- **Files:** [`firma_technicus_tab.dart`](file:///c:/Users/Admin/Documents/hvac_V0.3/lib/features/certificate_draft/ui/tabs/firma_technicus_tab.dart) (204 lines), [`company_section.dart`](file:///c:/Users/Admin/Documents/hvac_V0.3/lib/features/certificate_draft/ui/tabs/firma_technicus/company_section.dart) (191 lines), [`technician_section.dart`](file:///c:/Users/Admin/Documents/hvac_V0.3/lib/features/certificate_draft/ui/tabs/firma_technicus/technician_section.dart) (178 lines).
- **Role:** Reusable company profile, technician credentials (GV/TV numbers), analyzer serial, visit date/times.
- **Audit Results:**
  - **Formatters:** High quality. Uses [`CapitalizeWordsInputFormatter`](file:///c:/Users/Admin/Documents/hvac_V0.3/lib/core/utils/name_capitalization_formatter.dart), [`BelgianFormatters`](file:///c:/Users/Admin/Documents/hvac_V0.3/lib/core/utils/belgian_formatters.dart) for phone/KBO/postal code, and [`TechnicianRecognitionFormatters`](file:///c:/Users/Admin/Documents/hvac_V0.3/lib/core/utils/technician_recognition_formatters.dart) for GV/TV numbers.
  - **Fuel Parity:** Dynamic GV vs TV requirements adapt automatically to `boilerNotifier.draft.fuelCategory`.
  - **Findings:**
    1. **Hardcoded Strings:** Lines 63, 77, 93, 139 in `company_section.dart` and lines 78, 92 in `technician_section.dart` contain hardcoded `'... is verplicht'` strings.
    2. **Analyzer Brand:** Does not have `CapitalizeWordsInputFormatter` (serial correctly has `TextCapitalization.characters`).

---

### Tab 3: Klant & Installatieadres (`KlantTab`)
- **Files:** [`klant_tab.dart`](file:///c:/Users/Admin/Documents/hvac_V0.3/lib/features/certificate_draft/ui/tabs/klant_tab.dart) (250 lines), [`customer_details_card.dart`](file:///c:/Users/Admin/Documents/hvac_V0.3/lib/features/certificate_draft/ui/tabs/klant/customer_details_card.dart) (244 lines), [`installation_location_card.dart`](file:///c:/Users/Admin/Documents/hvac_V0.3/lib/features/certificate_draft/ui/tabs/klant/installation_location_card.dart) (217 lines).
- **Role:** Customer lookup, billing address, "Waar staat het toestel?" toggle, installation address, Basisregisters integration.
- **Audit Results:**
  - **Address Lookup:** Flemish Basisregisters candidate lookup and enrichment works seamlessly.
  - **Findings:**
    1. **Inconsistency with Tab 2 Formatters:** Unlike Tab 2, Customer `firstName`, `lastName`, `street`, `city`, and installation `locStreet`, `locMunicipality` do **not** use `CapitalizeWordsInputFormatter` or `textCapitalization: TextCapitalization.words`. Names and streets can be entered all lowercase.
    2. **Hardcoded Strings:** Five hardcoded validation strings in `customer_details_card.dart` and three in `installation_location_card.dart`.
    3. **File Length Warning:** `klant_tab.dart` is at exactly 250 lines and `customer_details_card.dart` is at 244 lines. Must be kept modular.

---

### Tab 4: Stooktoestel & Brander (`StooktoestelTab`)
- **Files:** [`stooktoestel_tab.dart`](file:///c:/Users/Admin/Documents/hvac_V0.3/lib/features/certificate_draft/ui/tabs/stooktoestel_tab.dart) (244 lines), [`toestel_card.dart`](file:///c:/Users/Admin/Documents/hvac_V0.3/lib/features/certificate_draft/ui/tabs/stooktoestel/toestel_card.dart) (173 lines), [`brander_card.dart`](file:///c:/Users/Admin/Documents/hvac_V0.3/lib/features/certificate_draft/ui/tabs/stooktoestel/brander_card.dart) (201 lines), [`kenmerken_card.dart`](file:///c:/Users/Admin/Documents/hvac_V0.3/lib/features/certificate_draft/ui/tabs/stooktoestel/kenmerken_card.dart) (99 lines).
- **Role:** Appliance type (NBN B/C), single fuel selector, boiler details, separate burner form.
- **Audit Results:**
  - **Fuel Memory:** [`FuelCategoryMemory`](file:///c:/Users/Admin/Documents/hvac_V0.3/lib/features/certificate_draft/ui/tabs/stooktoestel/fuel_category_memory.dart) cleanly preserves sub-type selections when switching between Gas and Mazout (compliant with Golden Rule #3).
  - **Unknown Chips:** "Onbekend" toggle for year and serial works well.
  - **Findings:**
    1. **UNWIRED FEATURE (Camera Barcode Scanner):**
       In `stooktoestel_tab.dart` line 191:
       ```dart
       void _scanBarcode() => TacticalFeedback.showInfo(
           context, AppDictionary.barcodeScannerPlaceholder);
       ```
       The camera scanner is currently a placeholder toast! [`BarcodeScannerModal.scan`](file:///c:/Users/Admin/Documents/hvac_V0.3/lib/features/certificate_draft/ui/tabs/stooktoestel/barcode_scanner_modal.dart) is already fully implemented, but was never wired to the callback.
    2. **Burner Debiet Keypad:** In `brander_card.dart` line 187, `flowRateController` uses `keyboardType: TextInputType.text` instead of `TextInputType.numberWithOptions(decimal: true)`.
    3. **Nominal Power Input Filtering:** Power (kW) accepts decimal input and parses commas to dots, but does not have `FilteringTextInputFormatter` to block accidental letters or symbols while typing.

---

### Tab 5: Meting (`MetingTab`)
- **Files:** [`meting_tab.dart`](file:///c:/Users/Admin/Documents/hvac_V0.3/lib/features/certificate_draft/ui/tabs/meting_tab.dart) (238 lines), [`measurement_slots_card.dart`](file:///c:/Users/Admin/Documents/hvac_V0.3/lib/features/certificate_draft/ui/tabs/meting/measurement_slots_card.dart), [`numeric_combustion_field.dart`](file:///c:/Users/Admin/Documents/hvac_V0.3/lib/features/certificate_draft/ui/tabs/meting/numeric_combustion_field.dart) (39 lines), [`safety_checks_card.dart`](file:///c:/Users/Admin/Documents/hvac_V0.3/lib/features/certificate_draft/ui/tabs/meting/safety_checks_card.dart).
- **Role:** Operating conditions, measurement slots (proef 1, proef 2 hoog/laag), live statutory limit calculations (CO $\le 150\text{ mg/kWh}$, $\eta \ge 90\%$), safety checklist.
- **Audit Results:**
  - **Calculations & Limits:** Automatically updates compliance based on fuel type (Gas vs Mazout) via [`MeasurementAssessmentNotifier`](file:///c:/Users/Admin/Documents/hvac_V0.3/lib/features/certificate_draft/ui/measurement_assessment_notifier.dart).
  - **Findings:**
    1. **Input Formatters in `NumericCombustionField`:** Uses [`UnitSuffixFormatter`](file:///c:/Users/Admin/Documents/hvac_V0.3/lib/features/certificate_draft/ui/widgets/dark_text_field.dart#L165) to show ` %` or ` °C`, but lacks `FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))`. On devices where custom third-party keypads allow non-numeric input, invalid characters could be typed.

---

### Tab 6: Eindbeoordeling & Ondertekening (`EindbeoordelingTab`)
- **Files:** [`eindbeoordeling_tab.dart`](file:///c:/Users/Admin/Documents/hvac_V0.3/lib/features/certificate_draft/ui/tabs/eindbeoordeling_tab.dart) (245 lines), [`handtekeningen_card.dart`](file:///c:/Users/Admin/Documents/hvac_V0.3/lib/features/certificate_draft/ui/tabs/eindbeoordeling/handtekeningen_card.dart) (125 lines), [`customer_signature_section.dart`](file:///c:/Users/Admin/Documents/hvac_V0.3/lib/features/certificate_draft/ui/tabs/eindbeoordeling/customer_signature_section.dart).
- **Role:** Final verdict (Goed/Veilig), statutory next inspection date auto-fill (1 yr oil / 2 yr gas), technician signature, customer signature exception, PDF export, VEKA tracker.
- **Audit Results:**
  - **Independence:** Generates PDF and outbox email queue independently of VEKA (Golden Rule #5).
  - **Statutory Dates:** Accurately calculates 1-year vs 2-year maintenance based on fuel type and visit date.
  - **Findings:**
    1. **Multi-line Text Fields:** `defectsController` and `remarksController` could benefit from `textCapitalization: TextCapitalization.sentences` so the first letter of each defect note is automatically capitalized.
    2. **File Length Warning:** `eindbeoordeling_tab.dart` is at 245 lines.

---

## 4. Prioritized Post-Milestone 6 Action Plan

When Milestone 6 is accepted, execute this punch-list in a single clean slice:

| Item | Priority | Target File(s) | Description |
| :--- | :--- | :--- | :--- |
| **P1** | **High** | `stooktoestel_tab.dart` | Wire up `BarcodeScannerModal.scan` to replace `_scanBarcode` placeholder toast. |
| **P2** | **High** | `verbrandingsattest_screen.dart` | Fix trailing colon on error snackbar by checking `detail != null && detail.trim().isNotEmpty`. |
| **P3** | **High** | `workflow_tab_container.dart` | Add `GestureDetector` with `FocusScope.unfocus()` to dismiss keyboard on whitespace tap across all tabs. |
| **P4** | **Medium** | `klant_tab_body.dart` / cards | Add `CapitalizeWordsInputFormatter` and `TextCapitalization.words` to Customer name and address fields. |
| **P5** | **Medium** | `brander_card.dart` | Change `flowRateController` (Debiet) keyboard to `TextInputType.numberWithOptions(decimal: true)`. |
| **P6** | **Medium** | `numeric_combustion_field.dart` | Add regex filter `[0-9.,]` to combustion number fields. |
| **P7** | **Low** | All tabs & dictionaries | Centralize hardcoded Dutch validator strings into `AppDictionary`. |
| **P8** | **Low** | `gebreken_opmerkingen_card.dart` | Set `textCapitalization: TextCapitalization.sentences` on defects and general remarks. |

---

## 5. Verification Gate for the Polish Slice
Once implemented, verify with:
1. `.\tool\check_gates.ps1` (Gate 1 formatting & $\le 250$ lines, Gate 2 static analysis, Gate 3 full test pass).
2. Physical/emulator scan test for barcode scanning on Tab 4.
3. Tap-outside keyboard dismissal verification across all 7 tabs.

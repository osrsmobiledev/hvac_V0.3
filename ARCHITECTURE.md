# HVAC App Architecture & Technical Decisions (hvac_V0.3)

## 1. Selected Tech Stack (Locked Baseline)
Do not introduce heavy enterprise frameworks (`Freezed`, `Dartz`, `GetIt`, `build_runner`, or 3-layer Clean Architecture). Use this lean, official-Flutter-aligned stack:

| Responsibility | Selected Tool / Package | Why |
| :--- | :--- | :--- |
| **State Management** | Native Flutter `ChangeNotifier` / `ValueNotifier` (with `ListenableBuilder` or `provider`) | Zero code-generation, simple to read and debug, follows official Flutter MVVM guide. |
| **Local Database** | `sqflite` + `path` | Rock-solid relational SQLite storage for offline drafts, customers, boilers, and visits. |
| **PDF Generation** | `pdf` + `printing` + `path_provider` | Matches the owner's working `references/legacy/code/pdf/` builders and supports cross-platform file storage/sharing. |
| **Camera Scanning** | `mobile_scanner` | Handles both 2D QR codes (Eurolyzer flue-gas readings) and 1D/2D barcodes (boiler/burner serial numbers). |
| **HTTP / API** | `http` or `dio` | For public Basisregisters Vlaanderen address lookups and VEKA API reporting. |

## 2. Folder Structure (2-Layer Feature Organization)
Keep the codebase flat and approachable. Create folders only when a slice needs them:

```text
lib/
  main.dart
  app/
    theme/                   # Adapted from references/legacy/code/theme/
    localization/            # Adapted from references/legacy/code/localization/
  core/
    database/                # SQLite setup, schema migrations, base tables
    widgets/                 # Shared UI (including adapted bo2_time_spinner.dart)
  features/
    technician_profile/      # Reusable Firma & Technicus settings
    customers_installations/ # Customers, Owners/Tenants, Locations (Basisregisters), Boilers
    certificate_draft/       # The 7-tab Verbrandingsattest workflow & controller
    scanner/                 # Eurolyzer QR parser & Serial barcode scanner
    pdf_export/              # Re-wired PDF builders from references/legacy/code/pdf/
    reporting_delivery/      # Independent Email queue & VEKA API / Manual portal tracker
```

Inside each feature, separate **UI** (screens/widgets + controller) from **Data** (repository + SQLite/API calls).

## 3. Core Data Entities & Relationships (SQLite)

Keep these entities in distinct tables with stable internal IDs (UUID or integer primary keys) so editing a customer never duplicates records:

1. **`technician_profile`**: Singleton reusable record (company details, KBO, technician name, GV/TV numbers). Preserved across visit resets.
2. **`customers`**: Contact details (`name`, `forename`, `street`, `number`, `postcode`, `city`, `phone`, `email`, custom label).
3. **`service_locations`**: Installation address (`street`, `number`, `postcode`, `municipality`) + official Basisregisters IDs (`adres_id`, `gebouw_id`, `gebouweenheid_id`, `verification_status`). Linked to customer with role (`owner` or `tenant`).
4. **`boilers`**: Linked to `service_location_id`. Stores appliance (`toestel`) and burner (`brander`) details, serial numbers (scanned via barcode or typed), appliance type (`B`/`C`), and the **single authoritative fuel choice** (`liquid`, `gas`, `solid` + subtype).
5. **`maintenance_visits`**: The active draft or finalized certificate. Links to `customer_id`, `service_location_id`, and `boiler_id`. Stores:
   * `activity_type` (`onderhoud` vs `eerste_ingebruikname`), `attest_number`, `maintenance_date` (defaults to today on creation), `start_time`, `end_time`.
   * Operating pressures/temperatures, safety OK/Niet OK assessments, final conclusion (`goed`/`niet_goed`, `veilig`/`niet_veilig`), `next_control_date`, `defects`, `remarks`, and signature image paths.
   * `snapshot_json`: Frozen copy of profile/customer/boiler data saved at the moment of finalization so later edits never alter historical certificates.
6. **`measurement_captures`**: Linked to `visit_id`. Stores raw QR payload, reported QR fuel, parsed values (`O2`, `CO2`, `CO`, `tg`, `ta`, `net_temp`, `Hi`, `Hs`, `pressure`), and assigned slot (`initial`, `final_low`, `final_high`). Changing fuel in `Stooktoestel` hides inapplicable UI fields but **never deletes** stored capture rows.

## 4. Independent Completion State Machines

Never use a single `isCompleted` boolean. Track delivery and government reporting separately on each finalized visit:

* **PDF State:** `draft` → `generating` → `ready` (saved locally via `path_provider`) → `failed`
* **Email Delivery State (per recipient: Customer & Technician):** `not_queued` → `queued_offline` → `sending` → `sent` → `failed`
* **Government Reporting State (VEKA):**
  * `not_submitted` → `queued` → `sending` → `accepted_api` (stores `meldingsnummer`)
  * Fallback / error states: `rejected_api`, `timeout_uncertain` (requires check before retry to prevent duplicate `externeReferte`), or `reported_manually_portal` (stores date, actor, and portal reference/note).

## 5. Re-Wiring Guide for `references/legacy/code/` (Keep Layout, Fix Wiring)

The owner is happy with the visual look of the legacy components. Do NOT redesign their visual appearance—only fix their broken data wiring:

### A. Time Spinner (`bo2_time_spinner.dart`)

* **Keep:** The 24-hour hour/minute wheel UI and dark/gold styling.
* **Fix during adaptation:**
  1. Translate hardcoded English (`Set Time`, `HOURS`, `MINUTES`, `Cancel`) into Dutch via `app_dictionary.dart`.
  2. Return the selected time (or trigger an `onTimeSaved` callback) that immediately persists to the `maintenance_visits` SQLite draft, rather than only mutating an unsaved `TextEditingController`.
  3. Add safe bounds checking when parsing existing `HH:mm` strings so malformed text defaults gracefully instead of silently failing.

### B. PDF Generator & Builders (`references/legacy/code/pdf/`)

* **Keep:** `pdf_components.dart` and the visual box/row geometry of `pdf_header_builder.dart`, `pdf_firma_builder.dart`, `pdf_klant_builder.dart`, `pdf_toestel_builder.dart`, and `pdf_meting_builder.dart`.
* **Fix during adaptation:**
  1. **Re-wire Inputs:** Replace the missing legacy classes (`StartProfile`, `FirmProfile`, `KlantProfile`, `ToestelProfile`, `MetingProfile`, `BesluitProfile`) by mapping directly from our finalized `MaintenanceVisit` snapshot model.
  2. **Add Missing Bottom Section (`Besluit` & Signatures):** `combustion_pdf_generator.dart` currently accepts `BesluitProfile` but never renders it on the page. Create/connect `pdf_besluit_builder.dart` at the bottom of the page to render Final Assessments (`Goed`/`Niet goed`, `Veilig`/`Niet veilig`), Next Inspection Date, Defects/Remarks, and Technician/Customer signatures.
  3. **Fix `Laaglast` / `Hooglast` Checkboxes:** In `pdf_meting_builder.dart`, replace hardcoded `isChecked: false` on low/high load checkboxes with actual checks based on whether `final_low` or `final_high` slots are populated.
  4. **Fix Flue Pressure (`Pa`) & Assessments:** Bind the numeric flue pressure value into the `Pa` line in `pdf_meting_builder.dart`, and wire `CO` and `Hi` OK/Niet OK boxes to the visit's saved assessment fields rather than reading only `proef1`.
  5. **Cross-Platform File Saving:** Replace the hardcoded `/storage/emulated/0/Download` path in `saveRawPdf` with `path_provider` application document storage + `printing` / share sheet export so it works on modern Android and iPhone.
  6. **Font Fallback:** Ensure the PDF generator either bundles the required font in `assets/fonts/` and `pubspec.yaml` or falls back cleanly to a standard `pw.Font.helvetica()` so PDF generation never crashes on a missing asset.




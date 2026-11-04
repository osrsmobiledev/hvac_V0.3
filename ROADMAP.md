# Project Roadmap & Slice Tracker (hvac_V0.3)

## How to Use This File
- Work through **one slice at a time**.
- Do not start the next slice until the current slice runs cleanly (`flutter analyze`, `flutter test`) and the owner has verified it on their device/emulator.
- After completing a slice and getting owner approval, commit and push the code to GitHub, then update Section 2 (Current Handoff) at the bottom of this file.

---

## 1. Implementation Milestones & Slices

### Milestone 1: "BO2 Tactical" UI Theme, App Shell & Dashboard
*Goal: Nail the Dark Luxury Industrial aesthetic, bento squircle applet tiles, and persistent navigation before building any forms.*

- [x] **Slice 1.1 â€” Theme Engine & Initialization (BO2 Tactical HUD):** Initialize the Flutter app. Ensure a standard Flutter .gitignore is created so build artifacts are not tracked. Set up the app_theme.dart using the "Glow on Carbon" / Dark Luxury Industrial tokens: deep #121212 OLED base, amber gold/terracotta/slate accents, negative-space silhouette icons, hairline dividers, and 28px bento squircle radii for cards.
- [x] **Slice 1.2 â€” Adaptive App Shell & Drawer:** Build the main Scaffold with a persistent AppBar. Implement adaptive navigation: a Hamburger Drawer on phones, the Hamburger Drawer must open directly underneath the persistent AppBar (leaving the top AppBar visible), transitioning to a permanent side menu on tablet/landscape widths. The AppBar title must dynamically change based on the active applet.
- [x] **Slice 1.3 â€” Home Dashboard (Applet Launcher):** Build the homepage body containing the "Bento Squircle" applet tiles (e.g., Verbrandingsattest, Cleaning, Inspection). Implement the Tinted Dark Mode / Tonal Surfaces so each tile has a subtle hue tint matching its accent border and vibrant glyph. Use a responsive grid (e.g., 1-2 columns on phones, 3-4 columns on tablets).
- [x] **Slice 1.4 â€” SQLite Database Core:** Set up `sqflite` tables (`technician_profile`, `customers`, `service_locations`, `boilers`, `maintenance_visits`, `measurement_captures`). Ensure the DB initializes correctly on app launch.

### Milestone 2: The "Verbrandingsattest" Applet (Tabs 1 to 4)
*Goal: Build the 7-tab persistent shell and the first 4 tabs tab-by-tab.*

- [x] **Slice 2.1 â€” 7-Tab Internal Shell & Tab 1 (`Data`):** Route from Home "Verbrandingsattest Vlaanderen" tile into the 7-tab workflow. Adaptive persistent AppBar title in Libron font: 2 lines centered on narrow screens ("Verbrandingsattest" / "Vlaanderen" with comfortable height padding) and 1 line on wider screens ("Verbrandingsattest Vlaanderen"). Top scrollable horizontal navigation bar directly below AppBar (`Data`, `Start`, `Firma - Technicus`, `Klant`, `Stooktoestel`, `Meting`, `Eindbeoordeling`) matching preferred theme. Build Tab 1 (`Data`) UI layout: collapsible `Meetgegevens` bento card, `Rookgassen` sub-card with Eurolyzer QR scanner launch icon button and live readings container.
- [x] **Slice 2.2 â€” Tab 2 (`Start`):** Build the clean `Start` form: Reusable gold-tinted `BentoMainSection` header, tactile activity type selector (*Onderhoud* vs. *Keuring voor eerste ingebruikname*) with springy mechanical tap animation and reticle indicators, and tactical *Volgnummer Attest* input box. Auto-save draft changes to SQLite `maintenance_visits`.
- [x] **Slice 2.3 â€” Tab 3 (`Firma - Technicus` & BO2 Time Spinner):** Build Company & Technician form backed by the singleton `technician_profile` table. *Datum onderhoud* (calendar picker defaulting to today). Adapt and integrate the 24-hour **BO2 Time Spinner** with Dutch labels (*Uren*, *Minuten*, *Kies tijd*, *Annuleren*, *OK*) for *Arbeidsduur van* & *tot*. Auto-save to SQLite.
- [x] **Slice 2.4 â€” Tab 4 (`Klant` & Installation Location):** Customer contact details, *Eigenaar* vs. *Huurder* role toggle, installation address, and searchable SQLite saved-customer directory picker.

### Milestone 3: Appliance, Measurements & Final Assessment (Tabs 5 to 7)
*Goal: Complete the remaining tabs tab-by-tab.*

- [x] **Slice 3.1 — Tab 5 (`Stooktoestel` + Serial Barcode Scanner):** Appliance (`Toestel`) & burner (`Brander`) forms, single authoritative Fuel selector (`Stookolie`, `Aardgas`, `LPG`, etc.), smart integrated vs separate burner toggle with statutory compliance badge, brand quick-pickers for boiler & burner, full-width inputs with tactical `Onbekend` chips, and camera barcode scanner button (`mobile_scanner`) next to `Fabricatienummer` with manual text fallback.
- [x] **Slice 3.2 — Tab 6 (`Meting` & Eurolyzer Flue-Gas QR):** Flue-gas measurement slots (*Vóór onderhoud*, *Na - Laaglast*, *Na - Hooglast*), QR reading insertion from Tab 1 into active slot via *"Overnemen uit Data"*, tactical slot indicator dots, smart statutory auto-check (CO and Rendement Hi against VLAREM II/VEKA norms), fuel-driven check visibility, and live *Verbrandingscontrole* compliance badge.
- [x] **Slice 3.3 — Tab 7 (`Eindbeoordeling` & Signatures):** Dual conclusions (*Goed*/*Niet goed*, *Veilig*/*Niet veilig*), statutory next inspection date calculation (+2 years for gas, +1 year for oil/solid) with quick chips, defects/remarks with 3-month legal remediation banner (Art. 6 Vlaams Stooktoestellenbesluit), quick defect chips, digital signature pads for technician and customer with live preview and clear, and complete button.

### Milestone 4: Re-Wired PDF Generation & Local Completion (`Voltooien`)
- [ ] **Slice 4.1 — `Voltooien` Pre-Flight Validation:** Build the `Voltooien` checklist showing missing fields with one-tap waypoint navigation ("teleport") to fix them. Freeze a `snapshot_json` upon finalization.
- [ ] **Slice 4.2 — Re-Wiring Legacy PDF Builders:** Connect the finalized visit snapshot to the legacy PDF builders. Build the missing bottom `pdf_besluit_builder`. Fix `Laaglast`/`Hooglast` checkboxes, `Pa` binding, and font fallback.
- [ ] **Slice 4.3 — Local PDF Preview, Storage & Email Queue:** Save the PDF via `path_provider`, add an in-app preview/print button, and implement the independent email delivery tracker.

### Milestone 5: Public API Address Lookup & VEKA Tracking
- [ ] **Slice 5.1 — Basisregisters Vlaanderen Lookup (`Klant` Tab):** Add online address verification with an offline manual fallback.
- [ ] **Slice 5.2 — Independent VEKA Reporting Tracker:** Add VEKA reporting status tracker (`not_submitted`, `reported_manually_portal`, API payload preview).
- [ ] **Slice 5.3 — History & Reminders Dashboard:** Add a view (accessible via the Drawer) to browse past certificates per customer/boiler, and trigger upcoming maintenance reminders.

---

## 2. Current Handoff (Active State for AI Agent)

- **Current Status:** Milestone 1, Milestone 2, and Milestone 3 (Slices 3.1, 3.2, 3.3) complete, refined, and verified.
- **Workflow & Architecture Hardening Delivered:**
  - **Tab 4 (`Klant` & Installatielocatie):**
    - Address matching logic refined: `Locatie Toestel` section is disabled/grayed out when installation location is identical to customer address, and unlocks smoothly when separate address is selected.
    - Standardized dark input labels and typography matching Tab 5 (`Stooktoestel`).
  - **Tab 5 (`Stooktoestel` & Brandstofkeuze):**
    - Fuel category memory ([FuelCategoryMemory](file:///c:/Users/Admin/Documents/hvac_V0.3/lib/features/certificate_draft/ui/tabs/stooktoestel/fuel_category_memory.dart)) isolates and remembers user sub-selections (e.g. *Aardgas*, *LPG*, *Houtpellets*) across category switches.
    - Eliminated auto-selection of *Aardgas* when selecting *Gasvormig* (Zero Fake Defaults). Sub-types start unselected and are fully de-selectable.
  - **Tab 6 (`Meting` & Veilige staat van werking):**
    - Dynamic fuel banner displaying accurate fuel and subtype names.
    - Full de-selection support for all safety check toggles (`TacticalBinaryCheck`) back to neutral `null` via sentinel pattern in [OperatingConditionsDraft](file:///c:/Users/Admin/Documents/hvac_V0.3/lib/features/certificate_draft/domain/operating_conditions_draft.dart) and [MeasurementSlotDraft](file:///c:/Users/Admin/Documents/hvac_V0.3/lib/features/certificate_draft/domain/measurement_slot_draft.dart).
  - **Tab 7 (`Eindbeoordeling` & Regulatory Coupling):**
    - Dual clear section labels: *Het stooktoestel werkt* ([Goed]/[Niet goed]) and *Verluchting en rookgasafvoer* ([Veilig]/[Niet veilig]).
    - Fool-proof statutory date logic: Zero fake defaults when fuel is empty (no phantom `+1 Jaar` selections). Date strictly derives when fuel and compliance are established.
    - Reactive link with Tab 6 via [MeasurementAssessmentNotifier](file:///c:/Users/Admin/Documents/hvac_V0.3/lib/features/certificate_draft/ui/measurement_assessment_notifier.dart) with clean de-selection and 3-month legal remediation rule (Art. 6 Vlaams Stooktoestellenbesluit).
  - **Quality & Metrics:**
    - 167 unit and widget tests passing (100% green).
    - 0 Dart analyzer issues across all files.
    - All Dart files in `lib/` strictly $\le 250$ lines of code.
- **Active State:** All 7 tabs of the Flemish combustion certificate workflow are fully operational, refined, styled, lag-free, and verified.
- **Next Step:** Proceeding with Milestone 4 (Re-Wired PDF Generation & Local Completion).
- **Blockers / Open Questions:** None. Ready for Milestone 4.

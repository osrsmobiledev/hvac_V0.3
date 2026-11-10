# Project Roadmap & Slice Tracker (hvac_V0.3)

## How to Use This File
- Work through **one slice at a time**.
- Do not start the next slice until the current slice runs cleanly (`flutter analyze`, `flutter test`) and the owner has verified it on their device/emulator.
- After completing a slice and getting owner approval, commit and push the code to GitHub, then update Section 2 (Current Handoff) at the bottom of this file.

---

## 1. Implementation Milestones & Slices

### Milestone 1: "BO2 Tactical" UI Theme, App Shell & Dashboard
*Goal: Nail the Dark Luxury Industrial aesthetic, bento squircle applet tiles, and persistent navigation before building any forms.*

- [x] **Slice 1.1 — Theme Engine & Initialization (BO2 Tactical HUD):** Initialize the Flutter app. Standard `.gitignore`. Setup `app_theme.dart` using "Glow on Carbon" / Dark Luxury Industrial tokens: deep #121212 OLED base, amber gold/terracotta/slate accents, hairline dividers, 28px bento squircle radii.
- [x] **Slice 1.2 — Adaptive App Shell & Drawer:** Main Scaffold with persistent AppBar. Adaptive navigation (Hamburger Drawer under AppBar on phones, permanent side menu on tablet/desktop).
- [x] **Slice 1.3 — Home Dashboard (Applet Launcher):** Bento Squircle applet tiles with tinted dark mode and responsive grid.
- [x] **Slice 1.4 — SQLite Database Core:** Core SQLite schema initialization (`technician_profile`, `customers`, `service_locations`, `boilers`, `maintenance_visits`, `measurement_captures`).

### Milestone 2: The "Verbrandingsattest" Applet (Tabs 1 to 4)
*Goal: Build the 7-tab persistent shell and the first 4 tabs tab-by-tab.*

- [x] **Slice 2.1 — 7-Tab Internal Shell & Tab 1 (`Data`):** Persistent 7-tab workflow (`Data`, `Start`, `Firma - Technicus`, `Klant`, `Stooktoestel`, `Meting`, `Eindbeoordeling`). Eurolyzer QR scanner launch icon button and live readings container.
- [x] **Slice 2.2 — Tab 2 (`Start`):** Activity selector (*Onderhoud* vs. *Keuring voor eerste ingebruikname*), tactical *Volgnummer Attest* input box. Auto-save draft changes to SQLite.
- [x] **Slice 2.3 — Tab 3 (`Firma - Technicus` & BO2 Time Spinner):** Company & Technician form backed by singleton `technician_profile`. 24-hour **BO2 Time Spinner** with Dutch labels for *Arbeidsduur van* & *tot*.
- [x] **Slice 2.4 — Tab 4 (`Klant` & Installation Location):** Customer contact details, *Eigenaar* vs. *Huurder* role toggle, installation address, and searchable SQLite saved-customer directory picker.

### Milestone 3: Appliance, Measurements & Final Assessment (Tabs 5 to 7)
*Goal: Complete the remaining tabs tab-by-tab.*

- [x] **Slice 3.1 — Tab 5 (`Stooktoestel` + Serial Barcode Scanner):** Appliance (`Toestel`) & burner (`Brander`) forms, single authoritative Fuel selector, smart integrated vs separate burner toggle, barcode camera scanner (`mobile_scanner`).
- [x] **Slice 3.2 — Tab 6 (`Meting` & Eurolyzer Flue-Gas QR):** Flue-gas measurement slots (*Vóór onderhoud*, *Na - Laaglast*, *Na - Hooglast*), QR reading transfer, smart statutory auto-check (CO and Rendement Hi against VLAREM II/VEKA norms), fuel-driven check visibility.
- [x] **Slice 3.3 — Tab 7 (`Eindbeoordeling` & Signatures):** Dual conclusions (*Goed*/*Niet goed*, *Veilig*/*Niet veilig*), statutory next inspection date calculation, defects/remarks with 3-month legal remediation banner (Art. 6 Vlaams Stooktoestellenbesluit), senior-friendly signature pads with refusal/absence exceptions.

### Milestone 4: Re-Wired PDF Generation & Local Completion (`Voltooien`)
- [x] **Slice 4.1 — `Voltooien` Pre-Flight Validation:** Full pre-flight checklist across Tabs 2-6 with zero-lag in-memory validation, one-tap waypoint navigation ("teleportation"), and fuel-isolated check rules.
- [x] **Slice 4.2 — Re-Wiring Legacy PDF Builders:** Revive and re-wire legacy PDF builders into modular clean Flutter architecture (`lib/features/pdf_export/`). Build missing bottom `PdfBesluitBuilder` (dual conclusions, statutory 3-month legal remediation note Art. 6, next inspection date, defects/remarks, technician & customer digital signatures with refusal/absence support). Exact Flemish single-page A4 geometry.
- [x] **Slice 4.3 — Local PDF Preview, Storage & Actions:** Add interactive in-app `PdfPreviewDialog` launched directly from Tab 7 via `[ 📄 Test-PDF Genereren ]` button (bypassing pre-flight gates for instant testing on empty or full drafts), with full-page zoom, direct Android printing, and PDF file sharing.

### Milestone 5: Public API Address Lookup & VEKA Tracking
- [ ] **Slice 5.1 — Basisregisters Vlaanderen Lookup (`Klant` Tab):** Add online address verification with an offline manual fallback.
- [ ] **Slice 5.2 — Independent VEKA Reporting Tracker:** Add VEKA reporting status tracker (`not_submitted`, `reported_manually_portal`, API payload preview).
- [ ] **Slice 5.3 — History & Reminders Dashboard:** Add a view (accessible via the Drawer) to browse past certificates per customer/boiler, and trigger upcoming maintenance reminders.

---

## 2. Current Handoff (Active State for AI Agent)

- **Current Status:** Milestone 4 (Re-Wired PDF Generation, In-App Preview Dialog, Direct Android Downloads Export & Verified Single-Page Flemish A4 Geometry) complete, owner-verified, and approved on Android emulator.
- **Milestone 4 PDF Engine & Device Export Delivered:**
  - **Architecture & Clean Code (`lib/features/pdf_export/`):**
    - 2-Layer modular architecture: UI (`PdfPreviewDialog`) + Data/Builders (`CombustionPdfGenerator`, `PdfDataMapper`, `PdfVisitLoader`, section builders, theme tokens, lego widgets).
    - All Dart files in `lib/` strictly $\le 250$ lines of code.
    - Zero Dart analyzer issues (`flutter analyze` passes with 0 warnings/errors).
    - 227 tests passing (`flutter test` passes 100% green).
  - **Single-Page Flemish A4 Geometry:**
    - Margins: top 10.0pt, left 24.9pt, right 17.3pt, bottom 10.0pt (A4 595.28 x 841.89 pt).
    - Printable height: 821.89 pt. Total content height: ~785 pt, guaranteeing **100% fit on a single A4 page with zero vertical overflow or page splitting**.
    - Full-width boxes locked to `552.9pt`, half-width boxes locked to `275.75pt`.
    - Strict 0.2pt borders, Libron typography tiers (Calibri/Libron 7pt, 5pt), and Helvetica fallback.
  - **Re-Wired Sections & Completed Bottom 20%:**
    - **Header:** Activity type (*Onderhoud* vs. *Keuring*) and statutory attest number.
    - **Firma & Technicus:** Company details, KBO BE format, technician GV/TV accreditation, date, 24h work time duration box, and Eurolyzer S1 serial number input box with SQLite persistence in `technician_profiles`.
    - **Klant & Locatie:** Customer name, contact info, and separate installation address if applicable.
    - **Stooktoestel Kenmerken:** Type B/C checkboxes with suffix, fuel category (gas/oil/solid), and burner technology (premix GI).
    - **Stooktoestel Apparaat:** Boiler and burner brands, models, construction years, serial numbers, and nominal power.
    - **Goede & Veilige Staat van Werking:** 24 statutory measurement and safety check rows with Proef I / Proef II modulation bindings (`w5Laag` & `w5Hoog` first-class cells with continuous vertical and horizontal hairline borders), Pa chimney draft, and dynamic Eurolyzer S1 serial number header. Operating pressures and temperatures cleanly copied across to Proef II.
    - **Besluit & Handtekeningen:** Dual statutory conclusions (*Goed*/*Niet goed*, *Veilig*/*Niet veilig*), statutory 3-month legal remediation note (Art. 6 Vlaams Stooktoestellenbesluit), next inspection date, defects/remarks, and centered technician & customer digital signatures (with automatic handling for signature refusal or absence). Signatures constrained to natural 24pt height with 2.2 rollerball stroke and customer name removed.
  - **In-App Test-PDF Dialog & Save-Device Export:**
    - Secondary button **`[ 📄 Test-PDF Genereren ]`** on Tab 7 (`Eindbeoordeling`) directly above `[ Verbrandingsattest Voltooien ]` for instant live preview and sharing.
    - Tertiary button **`[ 💾 Save-Device ]`** generating both `Verbrandingsattest_<id>.pdf` and high-res raster `Verbrandingsattest_<id>.png` directly saved to the public Android **Downloads** folder (`/storage/emulated/0/Download/`) using native Android `MediaStore.Downloads` via `MethodChannel` (`MainActivity.kt`). Overwrites clean without duplicate increments, accessible immediately in GIMP, photo viewers, and Android file managers.
- **Active State:** Milestone 4 complete and verified on emulator. Ready for Milestone 5.
- **Next Step:** Proceed to Milestone 5: Slice 5.1 — Basisregisters Vlaanderen Lookup (`Klant` Tab).
- **Blockers / Open Questions:** None. Ready to build Slice 5.1.

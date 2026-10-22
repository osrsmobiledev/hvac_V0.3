# Project Roadmap & Slice Tracker (hvac_V0.3)

## How to Use This File
- Work through **one slice at a time**.
- Do not start the next slice until the current slice runs cleanly (`flutter analyze`, `flutter test`) and the owner has verified it on their device/emulator.
- After completing a slice and getting owner approval, commit and push the code to GitHub, then update Section 2 (Current Handoff) at the bottom of this file.

---

## 1. Implementation Milestones & Slices

### Milestone 1: "BO2 Tactical" UI Theme, App Shell & Dashboard
*Goal: Nail the Dark Luxury Industrial aesthetic, bento squircle applet tiles, and persistent navigation before building any forms.*

- [x] **Slice 1.1 — Theme Engine & Initialization (BO2 Tactical HUD):** Initialize the Flutter app. Ensure a standard Flutter .gitignore is created so build artifacts are not tracked. Set up the app_theme.dart using the "Glow on Carbon" / Dark Luxury Industrial tokens: deep #121212 OLED base, amber gold/terracotta/slate accents, negative-space silhouette icons, hairline dividers, and 28px bento squircle radii for cards.
- [x] **Slice 1.2 — Adaptive App Shell & Drawer:** Build the main Scaffold with a persistent AppBar. Implement adaptive navigation: a Hamburger Drawer on phones, the Hamburger Drawer must open directly underneath the persistent AppBar (leaving the top AppBar visible), transitioning to a permanent side menu on tablet/landscape widths. The AppBar title must dynamically change based on the active applet.
- [x] **Slice 1.3 — Home Dashboard (Applet Launcher):** Build the homepage body containing the "Bento Squircle" applet tiles (e.g., Verbrandingsattest, Cleaning, Inspection). Implement the Tinted Dark Mode / Tonal Surfaces so each tile has a subtle hue tint matching its accent border and vibrant glyph. Use a responsive grid (e.g., 1-2 columns on phones, 3-4 columns on tablets).
- [x] **Slice 1.4 — SQLite Database Core:** Set up `sqflite` tables (`technician_profile`, `customers`, `service_locations`, `boilers`, `maintenance_visits`, `measurement_captures`). Ensure the DB initializes correctly on app launch.

### Milestone 2: The "Verbrandingsattest" Applet (Tabs 1 to 4)
*Goal: Build the 7-tab persistent shell and the first 4 tabs tab-by-tab.*

- [x] **Slice 2.1 — 7-Tab Internal Shell & Tab 1 (`Data`):** Route from Home "Verbrandingsattest Vlaanderen" tile into the 7-tab workflow. Adaptive persistent AppBar title in Libron font: 2 lines centered on narrow screens ("Verbrandingsattest" / "Vlaanderen" with comfortable height padding) and 1 line on wider screens ("Verbrandingsattest Vlaanderen"). Top scrollable horizontal navigation bar directly below AppBar (`Data`, `Start`, `Firma - Technicus`, `Klant`, `Stooktoestel`, `Meting`, `Eindbeoordeling`) matching preferred theme. Build Tab 1 (`Data`) UI layout: collapsible `Meetgegevens` bento card, `Rookgassen` sub-card with Eurolyzer QR scanner launch icon button and live readings container.
- [x] **Slice 2.2 — Tab 2 (`Start`):** Build the clean `Start` form: Reusable gold-tinted `BentoMainSection` header, tactile activity type selector (*Onderhoud* vs. *Keuring voor eerste ingebruikname*) with springy mechanical tap animation and reticle indicators, and tactical *Volgnummer Attest* input box. Auto-save draft changes to SQLite `maintenance_visits`.
- [x] **Slice 2.3 — Tab 3 (`Firma - Technicus` & BO2 Time Spinner):** Build Company & Technician form backed by the singleton `technician_profile` table. *Datum onderhoud* (calendar picker defaulting to today). Adapt and integrate the 24-hour **BO2 Time Spinner** with Dutch labels (*Uren*, *Minuten*, *Kies tijd*, *Annuleren*, *OK*) for *Arbeidsduur van* & *tot*. Auto-save to SQLite.
- [ ] **Slice 2.4 — Tab 4 (`Klant` & Installation Location):** Customer contact details, *Eigenaar* vs. *Huurder* role toggle, installation address, and searchable SQLite saved-customer directory picker.

### Milestone 3: Appliance, Measurements & Final Assessment (Tabs 5 to 7)
*Goal: Complete the remaining tabs tab-by-tab.*

- [ ] **Slice 3.1 — Tab 5 (`Stooktoestel` + Serial Barcode Scanner):** Appliance (`Toestel`) & burner (`Brander`) forms, single authoritative Fuel selector (`Stookolie`, `Aardgas`, `LPG`, etc.), and camera barcode scanner button (`mobile_scanner`) next to `Fabricatienummer` with manual text fallback.
- [ ] **Slice 3.2 — Tab 6 (`Meting` & Eurolyzer Flue-Gas QR):** Flue-gas measurement slots (*Vóór onderhoud*, *Na - Laaglast*, *Na - Hooglast*), QR reading insertion from Tab 1 into active slot, and fuel-driven check visibility.
- [ ] **Slice 3.3 — Tab 7 (`Eindbeoordeling` & Signatures):** Dual conclusions (*Goed*/*Niet goed*, *Veilig*/*Niet veilig*), statutory next inspection date, defects/remarks, digital signature pads for technician and customer, and *Afdrukken* trigger.

### Milestone 4: Re-Wired PDF Generation & Local Completion (`Voltooien`)
- [ ] **Slice 4.1 — `Voltooien` Pre-Flight Validation:** Build the `Voltooien` checklist showing missing fields with one-tap navigation to fix them. Freeze a `snapshot_json` upon finalization.
- [ ] **Slice 4.2 — Re-Wiring Legacy PDF Builders:** Connect the finalized visit snapshot to the legacy PDF builders. Build the missing bottom `pdf_besluit_builder`. Fix `Laaglast`/`Hooglast` checkboxes, `Pa` binding, and font fallback.
- [ ] **Slice 4.3 — Local PDF Preview, Storage & Email Queue:** Save the PDF via `path_provider`, add an in-app preview/print button, and implement the independent email delivery tracker.

### Milestone 5: Public API Address Lookup & VEKA Tracking
- [ ] **Slice 5.1 — Basisregisters Vlaanderen Lookup (`Klant` Tab):** Add online address verification with an offline manual fallback.
- [ ] **Slice 5.2 — Independent VEKA Reporting Tracker:** Add VEKA reporting status tracker (`not_submitted`, `reported_manually_portal`, API payload preview).
- [ ] **Slice 5.3 — History & Reminders Dashboard:** Add a view (accessible via the Drawer) to browse past certificates per customer/boiler, and trigger upcoming maintenance reminders.

---

## 2. Current Handoff (Active State for AI Agent)

- **Current Status:** Milestone 1, Slice 2.1, Slice 2.2, and Slice 2.3 complete, tested, and verified.
- **Active Slice:** **Slice 2.4 — Tab 4 (`Klant` & Installation Location)**
- **Immediate Next Step for Agent:**
  1. Inspect `references/legacy/screenshots/` and legacy customer models/forms for Tab 4 (`Klant`).
  2. Implement `KlantTab` with Customer Contact Details, Role selector (*Eigenaar* / *Huurder*), and Installation Address fields.
  3. Wire searchable customer picker modal querying SQLite `customers` and `service_locations` tables.
  4. Ensure all files remain strictly under 250 lines with helpful comments.
  5. Verify with `flutter analyze` and `flutter test`.
- **Blockers / Open Questions:** None. Ready to proceed with Slice 2.4 upon owner authorization.

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
- [ ] **Slice 1.2 — Adaptive App Shell & Drawer:** Build the main Scaffold with a persistent AppBar. Implement adaptive navigation: a Hamburger Drawer on phones, the Hamburger Drawer must open directly underneath the persistent AppBar (leaving the top AppBar visible), transitioning to a permanent side menu on tablet/landscape widths. The AppBar title must dynamically change based on the active applet.
- [ ] **Slice 1.3 — Home Dashboard (Applet Launcher):** Build the homepage body containing the "Bento Squircle" applet tiles (e.g., Verbrandingsattest, Cleaning, Inspection). Implement the Tinted Dark Mode / Tonal Surfaces so each tile has a subtle hue tint matching its accent border and vibrant glyph. Use a responsive grid (e.g., 1-2 columns on phones, 3-4 columns on tablets).
- [ ] **Slice 1.4 — SQLite Database Core:** Set up `sqflite` tables (`technician_profile`, `customers`, `service_locations`, `boilers`, `maintenance_visits`, `measurement_captures`). Ensure the DB initializes correctly on app launch.

### Milestone 2: The "Verbrandingsattest" Applet (Tabs 1-4)
*Goal: Build the 7-tab workflow inside the persistent shell.*

- [ ] **Slice 2.1 — 7-Tab Internal Shell & `Start` Tab:** When tapping the Verbrandingsattest tile on the homepage, route to the applet. Update the AppBar title to "Verbrandingsattest". Add the internal 7-tab navigation bar at the bottom/top. Build the `Start` tab and adapt the legacy `bo2_time_spinner.dart` with Dutch labels and auto-save.
- [ ] **Slice 2.2 — `Firma` Tab (Reusable Technician Profile):** Build the `Firma` form backed by the singleton `technician_profile` table.
- [ ] **Slice 2.3 — `Klant` Tab & Saved Customer Directory:** Build the customer/owner/tenant/installation location form with a searchable saved-customer picker.
- [ ] **Slice 2.4 — `Stooktoestel` Tab + Serial Barcode Scanner:** Build the appliance (`Toestel`) and burner (`Brander`) form, including the single authoritative fuel selector. Add a camera barcode scan button (`mobile_scanner`) next to the `Fabricatienummer` fields with manual text fallback.

### Milestone 3: Measurements (`Meting`), Eurolyzer QR & Final Assessment (`Besluit`)
- [ ] **Slice 3.1 — `Meting` Tab & Fuel-Driven Field Visibility:** Build the `Meting` form dynamically showing/hiding fuel-specific fields based on `Stooktoestel` without deleting hidden measurement rows.
- [ ] **Slice 3.2 — Eurolyzer QR Code Scanner & Parser:** Connect `mobile_scanner` to parse flue-gas readings into the selected slot (`initial`, `final_low`, `final_high`), and warn on fuel mismatch.
- [ ] **Slice 3.3 — `Besluit` Tab & Signature Capture:** Build the final assessment tab (`Goed`/`Veilig`, dates, remarks) and dual signature pads saved locally.

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

- **Current Status:** Slice 1.1 (Theme Engine & Initialization) completed and verified.
- **Active Slice:** **Slice 1.2 — Adaptive App Shell & Drawer**
- **Immediate Next Step for Agent:**
  1. Build the adaptive App Shell with persistent AppBar and Hamburger Drawer.
  2. On mobile/phones, drawer slides out underneath the persistent AppBar (leaving AppBar visible). On tablet/landscape, drawer displays as a permanent side menu.
  3. Style Drawer items using the BO2 dark carbon aesthetic with glowing icon badges.
  4. Keep main.dart minimal (< 40 lines) and ensure all files remain strictly under 250 lines with helpful comments.
- **Blockers / Open Questions:** None for Slice 1.2.

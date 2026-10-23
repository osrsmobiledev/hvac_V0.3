# AI Working Instructions — HVAC Maintenance App (hvac_V0.3)

## 1. Context Management (Prevent Context Bloat)
Do NOT read every Markdown file in the workspace on every turn. Load context selectively:
1. **Always check first:** Read `ROADMAP.md` (Current Handoff section) to see the active milestone and next slice.
2. **When changing data models, storage, or packages:** Read `ARCHITECTURE.md`.
3. **When implementing a specific tab, form field, PDF section, or VEKA rule:** Read only the relevant section of `VERBRANDINGSATTEST_WORKFLOW.md` and `PROJECT_BRIEF.md`.
4. **Reuse `references/legacy/code/` layouts:** The owner likes the visual layout and styling of the legacy PDF builders, time spinner, theme, and localization dictionary. Preserve their visual design while re-wiring their broken data inputs according to `ARCHITECTURE.md`.

## 2. How to Collaborate with the Owner
- The owner has strong domain knowledge but is not a software developer. Explain technical choices in plain language.
- **Work in small, testable slices:** Before writing code, state the single user-visible outcome, the files you will touch, and how we will test it.
- **Implement when authorized:** When asked to build a slice, write the code and run checks (`flutter analyze`, `flutter test`). When asked a question or to plan, do not write application code yet.
- **Two-strike debugging rule:** If the same bug or build error survives two different fix attempts, STOP coding. Summarize what failed, check your assumptions, and discuss with the owner before trying a third patch.
- **Protect existing work:** Never delete the database, weaken tests, or overwrite unrelated files just to make an error go away.
- **Strict Stop-and-Wait Policy:** Never combine slices from the roadmap. Write the code for ONE single slice, provide the owner with instructions to run it, and immediately STOP. You must wait for the owner's explicit approval before moving to the next slice.

## 3. Flutter & Dart Coding Standards (Official Flutter Architecture)
Follow the official Flutter Architecture Guide (UI Layer + Data Layer):
- **Language Rule (Dutch UI / English Code):** All user-facing app text, labels, buttons, validation messages, and PDF outputs must be in **Dutch (Flemish)**, centralized in `app_dictionary.dart`. All Dart code (class names, variables, functions, file names) and all `///` code comments must be written in **English**.
- **Do Not Reinvent the Wheel:** Always use standard Flutter Material 3 widgets, built-in SDK capabilities, the locked packages in `ARCHITECTURE.md`, and the existing files in `references/legacy/code/` (for PDF builders, time spinner, theme colors, and dictionary). Never write custom layout engines, custom state frameworks, custom date/time pickers from scratch, or duplicate existing helpers.
- **2-Layer Feature Structure:** Keep code simple: `UI` (Widgets + ChangeNotifier/Cubit ViewModels) and `Data` (Repositories + local SQLite/API services). Do NOT introduce heavy enterprise boilerplate (`Dartz`, `Freezed`, `GetIt`, `build_runner`, or 3-layer Clean Architecture use-case classes).
- **Readable & Commented Code:** Write descriptive English variable/function names. Add concise English `///` comments explaining *why* non-obvious logic, unit mappings, or validation rules exist, and tell the owner which file/line to edit if they want to tweak UI labels or styling later. Ensure all code includes helpful comments for the non-developer owner to inspect.
- **Strict File Length Limit (Max 250 Lines):** No single Dart file may exceed 250 lines of code. Split large widgets, screens, models, or services into focused, modular files to prevent file bloat and keep the codebase easy to read and maintain.
- **Widgets & Forms:**
  - Use small private `StatelessWidget` classes with `const` constructors instead of `_buildX()` helper methods.
  - Keep business logic, SQL queries, and PDF/API mapping out of widget `build()` methods.
  - Wrap form screens in a `GestureDetector(onTap: () => FocusScope.of(context).unfocus())` so tapping outside dismisses the phone keyboard.
  - Always set appropriate `keyboardType` (numeric vs text) and `textInputAction` (`Next` / `Done`) on `TextField`s.
- **Adaptive Layouts (Phone & Tablet):** The app must look premium on both phones and tablets:
  - **Forms:** Never let text fields stretch 100% width on a tablet. Constrain form widths (e.g., max 600px) and center them, or use a 2-column layout for wide screens.
  - **Navigation & Dashboard:** Use `LayoutBuilder` or `MediaQuery`. On wide screens, the Drawer can become a permanent side `NavigationRail` or expanded menu, and the Home Dashboard should increase its grid column count.

## 4. Non-Negotiable Product Golden Rules
1. **Offline-First Draft Safety:** Every form edit and tab switch must persist to the local SQLite database. Switching tabs, rotating the screen, or restarting the app must never lose draft data.
2. **Profile vs. Visit Separation:** Starting a "New Visit" clears visit-specific data (customer selection, measurements, dates/times) and defaults the maintenance date to today, while preserving the reusable Company/Technician profile and Customer/Boiler database.
3. **Single Installation Fuel:** Select the appliance fuel once in `Stooktoestel`. Derive `Meting` field visibility from that choice. Never silently wipe captured measurements if the user changes a selection.
4. **Camera Scanning + Manual Fallback:** Support `mobile_scanner` for both Eurolyzer QR codes (measurements) and 1D/2D barcodes (boiler/burner serial numbers), always paired with manual text entry/editing when a barcode is missing or unreadable.
5. **PDF/Email vs. VEKA Independence:** Validated visits generate the A4 PDF and queue/send emails independently of VEKA API status. Track government reporting (API or manual VEKA portal fallback) as a separate state machine. Never block PDF creation because VEKA is offline.
6. **Zero Fake Defaults or Silent Compliance:** Never use demo/test numbers as default boiler readings, never invent work start/end times, and never embed private certificates or API secrets in the mobile app.

## 5. Verification & Handoff
- Before marking a slice complete, verify against the short reminders in `IMPLEMENTATION_CHECKLIST.md`.
- Run `dart format`, `flutter analyze`, and focused unit/widget tests for the changed logic.
- Give the owner 3–4 short, concrete steps to test the feature on their Android emulator/device.
- After the owner confirms the slice works, commit the changes to Git with a clear message (e.g., feat: completed Slice 1.1), push to the repository, and update the Current Handoff section at the bottom of `ROADMAP.md`.

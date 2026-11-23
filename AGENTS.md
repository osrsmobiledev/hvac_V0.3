# AI Working Instructions — HVAC Maintenance App (hvac_V0.3)

## 1. Context Management (Prevent Context Bloat)
Do NOT read every Markdown file in the workspace on every turn. Load context selectively:
1. **Always check first:** Read `ROADMAP.md` (Current Handoff section) to see the active milestone and next slice.
2. **When planning code changes:** Answer the **Section 0 Pre-Code Check** from `IMPLEMENTATION_CHECKLIST.md` (negative states, lowest data boundary, exact scope).
3. **When changing data models, storage, or packages:** Read `ARCHITECTURE.md`.
4. **When building or modifying UI components, tokens, or forms:** Read `doc/UI_DESIGN_SYSTEM.md`.
5. **When implementing a specific tab, form field, PDF section, or VEKA rule:** Read only the relevant section of `doc/MASTER_HVAC_LIFECYCLE_WORKFLOW.md`, `doc/MASTER_EMAIL_DELIVERY_WORKFLOW.md`, `doc/BASISREGISTER_AND_VEKA_API_SPECIFICATION.md`, `doc/PRE_FLIGHT_VALIDATION_BLUEPRINT.md`, and `references/official/FLEMISH_REGULATORY_AND_VEKA_NORMS.md`.
6. **Archive-Only Documentation:** `doc/LESSONS_LEARNED.md` is a historical archive of past bug analyses. Do **not** load it during routine coding turns.
7. **Reuse `references/legacy/code/` layouts:** The owner likes the visual layout and styling of the legacy PDF builders, time spinner, theme, and localization dictionary. Preserve their visual design while re-wiring their broken data inputs according to `ARCHITECTURE.md`.

## 2. How to Collaborate with the Owner
- The owner has strong domain knowledge but is not a software developer. Explain technical choices in plain language.
- **Work in small, testable slices:** Before writing code, state the single user-visible outcome, the files you will touch, and how we will test it.
- **Implement when authorized:** When asked to build a slice, write the code and run checks (`flutter analyze`, `flutter test`). When asked a question or to plan, do not write application code yet.
- **Two-strike debugging rule:** If the same bug or build error survives two different fix attempts, STOP coding. Summarize what failed, check your assumptions, and discuss with the owner before trying a third patch.
- **Protect existing work:** Never delete the database, weaken tests, or overwrite unrelated files just to make an error go away.
- **Strict Stop-and-Wait Policy:** Never combine slices from the roadmap. Write the code for ONE single slice, provide the owner with instructions to run it, and immediately STOP. You must wait for the owner's explicit approval before moving to the next slice.

## 3. Flutter & Dart Coding Standards (Official Flutter Architecture)
Follow the official Flutter Architecture Guide (UI Layer + Data Layer):
- **Official Flutter Skills (Mandatory Direct Reference):**
  Consult the installed official skills before writing new components, layouts, or tests:
  - Architecture & MVVM: [`flutter-apply-architecture-best-practices`](file:///C:/Users/Admin/.gemini/config/plugins/flutter/skills/flutter-apply-architecture-best-practices/SKILL.md)
  - Adaptive Layout (Phone/Tablet): [`flutter-build-responsive-layout`](file:///C:/Users/Admin/.gemini/config/plugins/flutter/skills/flutter-build-responsive-layout/SKILL.md)
  - Widget Tests (`WidgetTester`): [`flutter-add-widget-test`](file:///C:/Users/Admin/.gemini/config/plugins/flutter/skills/flutter-add-widget-test/SKILL.md)
  - Unit Tests (`package:test`): [`dart-add-unit-test`](file:///C:/Users/Admin/.gemini/config/plugins/flutter/skills/dart-add-unit-test/SKILL.md)
  - Layout & Overflow Fixes: [`flutter-fix-layout-issues`](file:///C:/Users/Admin/.gemini/config/plugins/flutter/skills/flutter-fix-layout-issues/SKILL.md)
- **Language Rule (Dutch UI / English Code):** All user-facing app text, labels, buttons, validation messages, and PDF outputs must be in **Dutch (Flemish)**, centralized in `app_dictionary.dart` or feature-scoped dictionaries under `lib/app/localization/` (e.g. `meting_dictionary.dart`, `visit_history_dictionary.dart`, `email_delivery_dictionary.dart`). All Dart code (class names, variables, functions, file names) and all `///` code comments must be written in **English**.
- **Do Not Reinvent the Wheel:** Always use standard Flutter Material 3 widgets, built-in SDK capabilities, the locked packages in `ARCHITECTURE.md`, and the existing files in `references/legacy/code/` (for PDF builders, time spinner, theme colors, and dictionary). Never write custom layout engines, custom state frameworks, custom date/time pickers from scratch, or duplicate existing helpers.
- **2-Layer Feature Structure:** Keep code simple: `UI` (Widgets + ChangeNotifier/Cubit ViewModels) and `Data` (Repositories + local SQLite/API services). Do NOT introduce heavy enterprise boilerplate (`Dartz`, `Freezed`, `GetIt`, `build_runner`, or 3-layer Clean Architecture use-case classes).
- **Readable & Commented Code:** Write descriptive English variable/function names. Add concise English `///` comments explaining *why* non-obvious logic, unit mappings, or validation rules exist, and tell the owner which file/line to edit if they want to tweak UI labels or styling later. Ensure all code includes helpful comments for the non-developer owner to inspect.
- **Strict File Length Limit (Max 250 Lines):** No single Dart file may exceed 250 lines of code. Split large widgets, screens, models, or services into focused, modular files to prevent file bloat and keep the codebase easy to read and maintain.
  - **Single Responsibility over Helper Bloat:** "Reuse existing code" means invoking existing utilities, not dumping new responsibilities into an existing 150+ line class. Keep public OS export (e.g. `PdfFileSaver`) strictly separate from private internal data archiving (e.g. `PdfArchiveService`).
- **Widgets & Forms:**
  - Use small private `StatelessWidget` classes with `const` constructors instead of `_buildX()` helper methods.
  - Keep business logic, SQL queries, and PDF/API mapping out of widget `build()` methods.
  - For global tap-to-dismiss keyboard handling and list drag dismissal, follow `doc/UI_DESIGN_SYSTEM.md` (never add redundant per-screen `GestureDetector` wrappers).
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
7. **Offline Outbox Preflight:** Outbox queues (e.g. SMTP email delivery) must test connectivity via package preflight (`mailer.checkCredentials`) before claiming jobs. Normal offline states (e.g. basement visits) must immediately leave jobs `queued` with `attempt_count = 0` for automatic dispatch on app resume; only in-flight drops *during or after* `send()` transition to `uncertain_timeout`.
8. **Recoverable Dual-Store Credential Updates:** When updating state across SQLite and Android KeyStore, use a staged credential protocol (`smtp_password_staged` -> `smtp_password`) with `smtp_state` tracking. Startup recovery must deterministically resolve active credentials, and unresolved states (`needs_attention`) block automated sending.

## 5. Verification & Handoff
Before declaring any slice or coding task complete, strictly follow the 3-Tier Pre-Handoff Quality Gate in [`IMPLEMENTATION_CHECKLIST.md`](file:///c:/Users/Admin/Documents/hvac_V0.3/IMPLEMENTATION_CHECKLIST.md):

- **Plan First (Section 0 Pre-Code Check):** In your plan before writing any application code, answer the 3 questions in Section 0 of `IMPLEMENTATION_CHECKLIST.md`: (1) Negative states (prerequisites OFF/empty/null/offline), (2) Lowest data boundary enforcing the invariant, and (3) Exact user-visible outcome and files to touch.
- **Inspect Working Tree Before Testing:** Inspect `git status`, `git diff --check` (detects whitespace errors; note that it does not establish consistent line endings), and the actual diff for scope and accidental changes before running tests or declaring work ready. Do not claim line endings were verified unless an explicit line-ending check was performed.
- **Tier 1 — Automated Quality Gate (`.\tool\check_gates.ps1`):**
  - Run focused unit and widget tests for changed behavior first.
  - Execute `.\tool\check_gates.ps1` from the repository root before declaring code work complete. The script authoritatively verifies formatting (Gate 1A), static analysis (Gate 1B), Dart file lengths in `lib/` and `test/` <= 250 lines (Gate 1C), and the full automated test suite.
  - The script automatically captures full test output to `$env:TEMP\hvac-test-suite.log` and outputs a concise pass/fail summary (with tail on failure) to prevent terminal buffer truncation.
  - **Wait for Completion & Record Exit Code:** Always wait for the process to exit and record its actual exit code. Do not start duplicate runs, report a pass while still running, or infer results from partial output.
  - **Documented Totals Integrity:** Update documented test totals in `ROADMAP.md` and feature workflows only after the full gate exits successfully with exit code 0. For documentation-only tasks, do not run the test suite or update test counts.
- **Tier 2 — Adversarial Self-Audit on `git diff` (Mandatory Before Handoff):**
  - Switch from builder mode to bug-hunter mode before handing off. Perform the 4 checks in Tier 2 of `IMPLEMENTATION_CHECKLIST.md`: (1) Toggle-Off & Missing-Prerequisite Sweep across UI, memory, and data payloads, (2) Negative & Boundary Tests for every positive test, (3) Roundtrip Trace, and (4) Lifecycle & Leak Check.
  - Mark any invariant as unproven if its lowest data boundary has not been checked with an automated test. General slice acceptance does not prove an untested detail.
- **Tier 3 — Focused Feature & Owner Device Testing:**
  - Provide the owner with 3–4 short, concrete steps to test the feature on an Android emulator or physical device, including at least one negative or edge-case step. Never hand off based solely on an automated pass.
  - **Strict Stop-and-Wait Policy:** Wait for the owner's explicit confirmation on Android before moving to the next slice or making Git commits.
  - **Git Commit & Push:** After the owner confirms the slice works on Android, commit with a clear message (e.g., `feat: completed Slice 1.1`), push to the repository, and update the Current Handoff section at the bottom of `ROADMAP.md`.
- **Documentation Hierarchy & Consistency:** When working across documents and code, strictly adhere to this order of authority:
  1. **Direct Owner Decisions & Instructions:** The ultimate authority on product intent and scope.
  2. **Owner-Approved Master Workflows (`doc/`):** Define canonical product behavior, domain invariants, persisted state transitions, recovery guarantees, and acceptance criteria.
  3. **Code & Automated Tests:** Executable evidence of current implementation behavior; tests never override or redefine product requirements.
  4. **`ROADMAP.md`:** Concise progress tracking, active handoff, open decisions, verification status, owner device check steps, and links to the relevant master workflow (never duplicate detailed feature specs).
  5. **`IMPLEMENTATION_CHECKLIST.md`:** Cross-feature architectural quality gates and lifecycle rules (must not duplicate feature-specific workflow rules).
  - *Conflict Resolution & Honesty:* Resolve all conflicts against owner intent and canonical master workflows. Distinguish current code behavior, documented claims, explicit owner decisions, and inference. General slice acceptance does not prove an untested detail. Cite exact evidence; never assume an untested detail or choose silently when sources conflict—report unresolved decisions and gaps honestly. Link to master sections rather than copying detailed specifications across files.
  - Before claiming an action has no side effects, trace awaited work before and during that action.
- **Safe Section Inspection:** When inspecting the active handoff state, use this heading-based PowerShell search instead of splitting on platform-specific newlines or using fragile fixed line numbers:
  ```powershell
  Select-String -Path .\ROADMAP.md -Pattern '^## 2\. Current Handoff' -Context 0,30
  ```

### Standard Completion Report Format
Every slice handoff or task completion summary to the owner must follow this concise structure:
1. **Scope & Files Changed:** Single user-visible outcome. Explicitly separate:
   - *Files changed in current task:* exact list of modified/added files.
   - *Pre-existing working tree changes (if any):* uncommitted files from earlier work.
2. **Key Architecture & Library Choices:** Critical design decisions, locked packages, or patterns applied (or note "N/A — workflow documentation only").
3. **Verification Results:**
   - *For code / slice work:* Focused test outcome, full `.\tool\check_gates.ps1` exit status, total test count, and a brief Tier 2 Adversarial Self-Audit summary (listing key toggle-off/negative cases verified on `git diff`).
   - *For documentation-only work:* Explicitly state "Flutter checks not run—documentation-only" and report relevant documentation checks (`git diff --check`, working-tree audit).
4. **Owner Device Testing Status:** Concrete 3–4 step manual testing instructions on Android, or explicit pending status for hardware-only checks (or "N/A — documentation-only").
5. **Remaining Risks or Unverified Items:** Document any pending hardware tests (e.g. cloud backup/restore), external mock bounds, or edge cases.

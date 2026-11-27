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
- [x] **Slice 5.1 — Basisregisters Vlaanderen Lookup (`Klant` Tab):** Add online address verification with an offline manual fallback.
- [x] **Slice 5.2 — Independent VEKA Reporting Tracker:** Add VEKA reporting status tracker (`not_submitted`, `reported_manually_portal`, API payload preview).
- [x] **Slice 5.3 — History & Reminders Dashboard:** Browse past certificates by customer or boiler and share upcoming maintenance reminders from **Historiek**.
- [x] **Slice 5.4 — Reuse a saved boiler:** When creating a new visit, offer the saved boilers for the selected installation address, including its bus number. Let the technician explicitly select a boiler or add a new one. Copy the selected boiler details into the new visit without changing archived certificates or VEKA evidence.
- [x] **Slice 5.5 — Mock VEKA API submission, recovery and receipts:** Save the exact outgoing JSON and a unique request reference before sending. With a fake transport, verify receipts, rejections, access recovery and uncertain outcomes. Put unfinished reports in Historiek with an actionable next step. Keep archived certificates immutable when correcting a date-only rejection. Owner Android acceptance confirmed.

### Milestone 6: Email Delivery & PDF Archiving
*Goal: Deliver the signed PDF certificate to the customer and technician via standard SMTP (Gmail App-password / Custom SMTP) with an offline-first SQLite queue and native Android share fallback. See [MASTER_EMAIL_DELIVERY_WORKFLOW.md](doc/MASTER_EMAIL_DELIVERY_WORKFLOW.md).*

- [x] **Slice 6.1 — Email Configuration & Connection Test:** Configure outbound SMTP settings (Gmail App-password or Custom SMTP with SSL/TLS vs STARTTLS) with auto-send and technician-copy options. Store passwords via a recoverable staged credential protocol (`smtp_password_staged` -> `smtp_password` in `flutter_secure_storage: ^9.2.2` with `smtp_state` in SQLite v12), verify credentials cleanly via `package:mailer ^7.2.0` (`checkCredentials`) with instant tactical feedback, and provide a single-account disconnect action (**E-mailinstellingen wissen**) with confirmation dialog and crash-safe clearing protocol (`clearing` -> `unconfigured`). Target destination is **Instellingen** (`AppletType.technicianSettings`), top-aligned using `WorkflowTabContainer` to match the Verbrandingsattest Bento layout. Status: Completed & verified (37 focused email tests + 6 theme/navigation tests passing, 358 full suite tests passing, 0 analyzer lints, all files <= 250 lines). Tested on Android by owner.
- [x] **Slice 6.2 — PDF Archiving & Outbox Creation:** On visit finalization (`Voltooien`), freeze the certificate snapshot in SQLite, stage and verify the PDF in `certificates/staging/` via dedicated `PdfArchiveService` under isolate-level `Lock()`, publish to unique filename in `certificates/`, prompt recipient confirmation (`EmailRecipientDialog`), and queue frozen jobs in `email_delivery_jobs`. Status: Completed & accepted on Android by owner (28 focused tests passing, 386 full suite tests passing, 0 analyzer lints, all files <= 250 lines).
- [x] **Slice 6.3 — Offline Outbox, History Tracker & Native Share:** Dispatch queued emails triggered from root UI shell on app resume, verify connection via `mailer.checkCredentials()` (preflight failure leaves jobs `queued` with their `attempt_count` unchanged, which is 0 for fresh, never-claimed jobs), claim jobs atomair under app-scoped lock, classify recipient rejections via isolated `classifyCommunicationException` matching locked `mailer` responses (`RCPT TO` unambiguously recipient-specific `5.1.x`/`551`/`553` on first reply line -> `recipient_rejected`, ambiguous bare `550`, `4xx` temporary or `5.7.x` policy rejections and `MAIL FROM` -> `server_rejected`, in-flight auth failure -> marks current job `server_rejected` with `failure_reason = 'authentication_failed'`, sets `smtp_state = 'needs_attention'`, stops the batch via early return, and leaves later unclaimed jobs in `queued` with their `attempt_count` unchanged, which is 0 for fresh, never-claimed jobs), handle `uncertain_timeout` with duplicate-risk confirmation on retry, support in-place address corrections restricted to eligible failure statuses, execute real database schema migration to v13 (adding `resolved_at` and `resolution_notes` to `email_delivery_jobs` via `AppDatabase.onUpgrade`), require non-empty resolution notes without fallbacks, support PDF archive recovery in Historiek ("Archivering opnieuw proberen" for `pdf_status = 'failed'` preserving `snapshot_json`), offer "Alsnog e-mailen" (reading frozen `snapshot_json`; technician-only copy requires configured/selected technician email; Option A confirmed by owner allowing technician-only copy), and offer zero-config native share sheet fallback via `Printing.sharePdf` with asynchronous file operations. Status: Completed and accepted on Android by owner (Option A confirmed: technician-only dispatch without customer email is accepted product intent; native PDF sharing and offline outbox handling verified on Android device; post-audit fixes for in-flight auth abort, PDF archive recovery, and write-boundary validation verified across 448 automated tests, 0 analyzer lints, all files <= 250 lines).
- [x] **Slice 6.4 — Optionele Klanten-Opmerking & Voorwaardelijke Gating:** Allow technician to add an optional message to the customer's email via an expandable Material 3 text field behind "Opmerking toevoegen". Enforce 3-layer dependency invariant: note input renders only when customer has email and is checked; unchecking customer or cancelling collapses the field, clears controller, and unfocuses keyboard; `EmailJobSpec.buildJobs` enforces lowest-boundary pruning and 500-character safety limit so technician copies never produce false remark claims when no customer email is dispatched. Full text frozen into `email_delivery_jobs.body_text` for retries and Historiek tracking. Works for both visit finalization and "Alsnog e-mailen". Status: Completed and accepted on Android by owner (10 focused tests passing, 458 full suite tests passing, 0 analyzer lints, all files <= 250 lines).

---

## 2. Current Handoff (Active State for AI Agent)

**Active Milestone: Milestone 7 (Reinigingsattest Vlaanderen) — Slice 7.4 (Reinigingsattest A4 PDF Export) complete and verified on Android across 510 automated tests (`.\tool\check_gates.ps1` exit code 0). Next active slice: Slice 7.5 — Finalization, Email & Historiek. See `doc/REINIGINGSATTEST_BLUEPRINT.md`.**

### Slice 6.4 Implementation Summary & Verification
Slice 6.4 completed and accepted on Android by the owner. Full implementation and 3-layer dependency invariant verified across the 458-test automated suite (0 analyzer lints, all files <= 250 lines):

1. **Expandable Note Input Component (`EmailCustomNoteInput`):**
   - Starts collapsed with compact "Opmerking toevoegen" button (`Icons.note_add_outlined`).
   - Expands on tap to show standard Material 3 multiline `TextField` with `maxLength: 500`, `MaxLengthEnforcement.enforced`, and dense styling.
   - Close button with tooltip (`EmailDeliveryDictionary.emailNoteActionRemove`) clears the controller and drops the software keyboard (`FocusScope.of(context).unfocus()`).

2. **UI Dependency Gating (`RecipientDialogContent` & `EmailRecipientDialog`):**
   - Note input is conditionally rendered only when `customerEmail.trim().isNotEmpty && sendCustomer`. If customer has no email or is unchecked, the note field does not exist in the widget tree.
   - Unchecking customer checkbox immediately clears `_noteController` and unfocuses the keyboard. Re-checking starts clean and collapsed.
   - Confirming with customer unchecked strictly returns `customNote: null`.

3. **Lowest Data Boundary Invariant (`EmailJobSpec.buildJobs`):**
   - Computes `effectiveNote` once: valid only when `hasCustomer && rawTrimmed.isNotEmpty`, sanitized and truncated at 500 characters.
   - Both customer and technician jobs receive the identical `effectiveNote`.
   - If no customer email is dispatched, `effectiveNote = null`; technician copy never makes false claims of a customer remark.
   - Full body text frozen into SQLite `body_text` on queueing, preserving exact text across retries and Historiek outbox tracker.
   - Integrated with both visit finalization and Historiek "Alsnog e-mailen" flow.

4. **Quality Gates & Test Coverage:**
   - 10 focused tests in `test/email_custom_note_test.dart` and `test/email_custom_note_dialog_test.dart` covering dictionary formatting, boundary pruning, 500-char limits, UI gating, and buffer reset.
   - Full gate pass: 458 tests green, 0 static analysis issues, all files <= 250 lines. Tested and confirmed on Android device by owner.

### Slice 6.3 Implementation Summary & Verification
Slice 6.3 core implementation was accepted earlier on Android by the owner, and post-audit code/test closure is now verified across the 466-test automated suite (0 analyzer lints, all files <= 250 lines; Option A confirmed and closed). Remaining device QA status is recorded below:

1. **Serialized Outbox Processing & Live-Send Protection (`EmailDeliveryCoordinator`):**
   - App-scoped coordinator instance (`EmailDeliveryCoordinator.instance`) and static `_sharedLock` (`package:synchronized`) shared within the app isolate.
   - `AppShellScreen` (resume trigger) and `EmailDeliveryCard` (Historiek actions) share the same lock, ensuring outbox processing, recovery, corrections, and retries are strictly serialized.
   - Live send protection: stale-send recovery cannot overwrite an actively sending job; verified via concurrency test overlapping resume processing with an active send (`email_delivery_concurrency_test.dart`).

2. **Accurate SMTP Rejection Handling Matching Locked Mailer API (`EmailSenderService`):**
   - Isolated classifier `EmailSenderService.classifyCommunicationException` inspects `SmtpClientCommunicationException` messages emitted by locked `package:mailer ^7.3.0` (with `acceptedRespCodes` default `['2']`).
   - Unambiguously recipient-specific responses on `RCPT TO` (RFC 3463 `5.1.x` addressing status or RFC 5321 `551`/`553`) classify as `recipient_rejected` (address correction eligible).
   - Ambiguous bare `550` responses, temporary `4xx` server responses (e.g. `450`, `451`, `452`), and policy/relay rejections (e.g. `550 5.7.1`, `554 5.7.1`) on `RCPT TO` or `MAIL FROM` classify as `server_rejected` so the technician is not told to change a valid address.
   - Unknown, malformed, or ambiguous communication failures or mid-stream drops classify as `uncertain_timeout` (duplicate prevention).
   - Verified with unit tests covering bare `550`, recipient-specific `550 5.1.1`, policy `550 5.7.1`, temporary `4xx`, and malformed payloads (`email_rejection_classification_test.dart`).

3. **Conditional Updates & Duplicate Prevention (`EmailOutboxRepository`):**
   - `updateRecipientEmail()` restricts updates to `status IN ('recipient_rejected', 'failed')` and returns `bool`.
   - `requeueJob()` restricts updates to `status IN ('uncertain_timeout', 'server_rejected', 'failed')` and returns `bool`.
   - `EmailDeliveryCoordinator` stops send dispatch if the update was ineligible (e.g. job was already `sent` or `resolved_manually`).
   - Verified with tests confirming stale retry/correction actions cannot change `sent` or `resolved_manually` jobs or send them again (`email_delivery_concurrency_test.dart`).

4. **Real v12 to v13 Database Migration (`AppDatabase.onUpgrade`):**
   - Built a genuine v12 database lacking `resolved_at` and `resolution_notes`, populated with customer, technician profile, visit, and email job records.
   - Reopened through `AppDatabase.instance.initDatabase`, exercising real `onUpgrade` migration adding both columns.
   - Verified all existing data and queued/sent jobs remain 100% intact, and new columns are fully operational (`database_migration_v13_test.dart`).

5. **Mandatory Manual-Resolution Notes (`EmailRecoveryDialogs` & `EmailOutboxRepository`):**
   - Removed generic "Handmatig opgelost door technicus" fallback.
   - Dialog confirm button is disabled (`onPressed: null`) until a non-empty explanation is typed via `ValueListenableBuilder`.
   - Enforced validation at repository and coordinator boundaries (`throw ArgumentError` if empty).
   - Verified with widget tests checking disabled state on empty/whitespace and enabled on valid input (`email_recovery_dialogs_test.dart`).

6. **Asynchronous PDF Sharing Off UI Thread (`EmailDeliveryCard`):**
   - Replaced synchronous `file.existsSync()` and `file.readAsBytesSync()` with `await file.exists()` and `await file.readAsBytes()`.
   - Wrapped operations with localized error feedback (`EmailDeliveryDictionary.sharePdfError`) if file is missing or reading fails.
   - Action runs under `_handleAction` to indicate processing and prevent duplicate taps.
   - Verified with widget tests for successful sharing and missing file error SnackBar (`email_delivery_card_share_test.dart`).

7. **Unified Finalization Flow & Empty Outbox Recovery (Fix 1):**
   - Replaced double pop-up flow with a single cohesive dialog (`Attest voltooien`) with customer recipient confirmation (at initial finalization, `saveScope.settle()` runs and `PdfVisitLoader.loadVisitData(visitId)` loads the active visit's current customer data before the visit is finalized, without duplicate input fields), technician copy toggle, and 3 explicit actions: "Annuleren", "Alleen bewaren", and "Voltooien & E-mailen".
   - 100% draft-safe cancellation: `VisitFinalization.executeWorkflow()` awaits `saveScope.settle()` before opening the recipient dialog (flushing pending draft edits to SQLite). Cancellation prevents finalization (`is_draft = 0`), snapshot freezing, PDF archiving, outbox creation, and dispatch; it preserves `is_draft = 1` and `pdf_status = 'draft'` without premature locking or failed rollback, ensuring form fields on Tab 4 (`Klant`) remain immediately editable and restorable without errors.
   - Never lose email ability: visits saved via "Alleen bewaren" show `EmailEmptyOutboxView` in Historiek with "Alsnog e-mailen" (opens recipient dialog using the immutable `snapshot_json` for already-finalized visits to queue outbox jobs) and "Attest delen" (native Android share sheet).
     - Customer delivery uses the email frozen in the finalized visit `snapshot_json`.
     - Technician-only delivery requires a configured technician email in Settings and selection in the dialog.
     - If no recipient is selected or available, the dialog flow exits without calling `createEmailJobs()`, so no outbox row is inserted.
     - **Owner Decision Confirmed (Option A):** Technician-only delivery without a customer email via "Alsnog e-mailen" is explicitly approved product behavior (allows the technician to email an archive copy to themselves).

8. **Tactical Pop-Up Standardization & Symmetrical Layout (Fix 2):**
   - Transformed `EmailRecipientDialog` to faithfully inherit `TacticalDialogWindow` and `TacticalDialogButton`, matching the exact "BO2 Tactical HUD" signature styling of the Basisregisters dialog on Tab Klant:
     - Dark charcoal glass surface (`AppColors.charcoalGlass`) with 24px border radius.
     - Glowing HUD laser divider (`TacticalLaserDivider` in `antiqueGold`).
     - Centered title in bold white text and top-right close icon (`onClose: _onCancel`) for safe, non-destructive dismissal.
     - Signature 48px tactile capsule buttons: `TacticalDialogButton.primary` (antique gold fill) and `TacticalDialogButton.secondary` (dark `#1E1E1E` outline).
   - 100% Symmetrical Recipient Cards (`CustomerRecipientCard` & `TechnicianRecipientCard`):
     - Both cards share identical anatomy: Antique Gold leading icon (`Icons.person_rounded` vs `Icons.badge_outlined`), 14px bold primary title, 13px secondary subtitle, and amber gold checkbox on the **RIGHT**.
     - Eliminated phone number clutter: removed unrelated phone display from email dispatch dialog, resolving font hierarchy inconsistencies.
      - When customer email is absent, replaces the checkbox with tactical notice *"Geen e-mail of telefoon opgeslagen (Tab Klant)"* and physical delivery notice *"Het attest wordt bewaard voor fysieke bezorging (afdrukken in de wagen of per post)."*
     - Single source of truth: customer email is read directly without duplicate input fields (at initial finalization, `saveScope.settle()` runs and `PdfVisitLoader.loadVisitData(visitId)` loads the active visit's current customer data before the visit is finalized; the immutable `snapshot_json` is used later for already-finalized visits, such as Historiek recovery).
   - Modularized UI files respecting strict architectural limits: `recipient_dialog_content.dart` (94 lines), `customer_recipient_card.dart` (183 lines), `technician_recipient_card.dart` (80 lines), and `email_recipient_dialog.dart` (206 lines) — all <= 250 lines.

9. **Code Quality, Static Hygiene & Test Suite Verification:**
   - Static analysis (`flutter analyze --no-pub`): **0 issues found!**
   - Formatter (`dart format --output=none --set-exit-if-changed lib test`): **0 unformatted files** across all 398 files.
   - Full test suite: **448 tests passing** with exit code 0 (`flutter test --no-pub` / `check_gates.ps1`).
   - Line count audit: Every single Dart file strictly respects the **<= 250 line limit** (zero files over 250 lines).

10. **Android Secure Storage Backup-Exclusion Verification & Pending Device Test:**
    - Inspected locked `flutter_secure_storage` `9.2.4` source (`FlutterSecureStorage.java`): verifies default `SHARED_PREFERENCES_NAME = "FlutterSecureStorage"`, saving SharedPreferences to `shared_prefs/FlutterSecureStorage.xml`.
    - Confirmed XML rule alignment: both `android/app/src/main/res/xml/backup_rules.xml` (legacy Auto Backup) and `android/app/src/main/res/xml/data_extraction_rules.xml` (Android 12+ cloud backup & device-to-device transfer) explicitly exclude `<exclude domain="sharedpref" path="FlutterSecureStorage.xml"/>`.
    - Verified `AndroidManifest.xml` links both rule sets via `android:fullBackupContent="@xml/backup_rules"` and `android:dataExtractionRules="@xml/data_extraction_rules"`.
    - Verification Status: Static and package source configuration verified 100% correct; end-to-end cloud backup and restore cycle on physical Android hardware remains recorded as pending physical verification.

11. **Technician-Friendly Failure Feedback & Clean UI Boundary:**
    - `EmailFailureDisclosure`: Implemented concise Dutch explanation for failure categories (`recipient_rejected`, `server_rejected`, `uncertain_timeout`, `network_preflight_failed`, etc.) in Historiek, moving raw SMTP exceptions behind an expandable "Technische details tonen / verbergen" disclosure.
    - Localization: Centralized all Dutch failure messages in `EmailDeliveryDictionary.failureExplanation`.
    - Architectural Boundary: Injected `archivingCoordinator` into `EmailDeliveryCard` at the existing screen composition boundary (`VisitHistoryScreen._openEmail`) without adding unnecessary service locators or boilerplate.

12. **Two SMTP Authentication Failure Points (`EmailDeliveryCoordinator`):**
    - *Preflight Auth Failure (`testConnection`):* Sets `smtp_state = 'needs_attention'` and aborts outbox dispatch. All queued jobs remain untouched in `status = 'queued'` with their `attempt_count` unchanged (0 for fresh, never-claimed jobs; a previously retried job retains its existing count).
    - *In-Flight Auth Failure during `send()` (`sendCertificateEmail`):* Marks the current claimed job `status = 'server_rejected'` with `failure_reason = 'authentication_failed'` and increments `attempt_count`. Sets `smtp_state = 'needs_attention'` and terminates the batch immediately via early return (`return OutboxDispatchResult.needsAttention`). Later unclaimed jobs are not attempted and remain safely in `status = 'queued'` with their `attempt_count` unchanged (0 for fresh, never-claimed jobs; a previously retried job retains its existing count).
    - Verified with unit tests (`test/email_auth_failure_dispatch_test.dart`).

13. **PDF Archive Recovery in Historiek (`PdfArchivingCoordinator` & `EmailDeliveryCard`):**
    - Finalized visit with `pdf_status = 'failed'` retains its `snapshot_json` and `is_draft = 0`.
    - `EmailDeliveryCard` surfaces "Archivering opnieuw proberen" (`EmailDeliveryDictionary.actionRetryArchive`), keeping email and share actions disabled while `pdf_path` is empty or invalid.
    - Successful retry generates the PDF from `snapshot_json`, transitions `pdf_status = 'ready'`, sets `pdf_path`, and immediately enables email and sharing actions.
    - Failed retry preserves visit data and `snapshot_json`, displays the error message, and keeps the retry action available for subsequent attempts.
    - Verified with widget tests (`test/pdf_archive_recovery_test.dart`).

14. **Resolved Closure Items (466-Test Suite):**
    - *"Alsnog e-mailen" End-to-End Widget Tests:* Added `test/email_delivery_card_recovery_test.dart` covering empty-outbox `"Alsnog e-mailen"` -> `EmailRecipientDialog` (customer + technician, Option A technician-only without customer email, and cancel/no-op).
    - *`EmailDeliveryCard._loadJobs()` Failure Path:* Wrapped `_loadJobs()` in `try/catch/finally` with `debugPrint` logging, `mounted`-guarded `_isLoading = false`, and retryable `EmailLoadErrorView` (`EmailFailureDictionary.trackerLoadError`), plus sibling `EmailLoadedJobsView` extraction keeping `email_delivery_card.dart` under 250 lines.
    - *`EmailOutboxBanner` `needs_attention` Precedence Fix:* Reordered `EmailOutboxBanner.build()` to check `needsAttention` before `!isConfigured`, preventing `smtp_state == 'needs_attention'` from being shadowed by `outboxUnconfiguredNotice`; verified with `test/email_outbox_banner_test.dart` (including live **Nu verzenden** auth-failure transition).

15. **Reconciled Verification & Android Device Testing State:**
    - *Owner Device Acceptance:* Native PDF sharing ("Delen via Android"), offline/unconfigured outbox sending ("Nu verzenden"), and SMTP authentication failure recovery (persistent *"E-mailinstellingen vereisen aandacht"* banner + credential restore delivery) tested and confirmed working on Android device by the owner; Option A confirmed and closed (technician-only dispatch accepted).
    - *Automated Quality Gate:* All 466 automated tests pass cleanly with exit code 0 (`.\tool\check_gates.ps1`), 0 analyzer issues, all files <= 250 lines.
    - *Deferred Pre-Release QA Check:* Android KeyStore cloud backup exclusion (`FlutterSecureStorage.xml`) end-to-end backup/restore cycle remains recorded as a deferred pre-release QA check.

### Owner Check on Android

Test Slice 6.3 on an Android phone or tablet:

1. **Verify Outbox Status in Historiek:**
   - Open the app and tap **Historiek** in the navigation drawer.
   - Find the visit completed in Slice 6.2 (or complete a new visit via **Voltooien**).
   - Tap the mail icon button (`visit_email_<id>`) on the visit card to open the **E-mailbezorging** card.
   - Confirm the recipient(s) are listed with their status badge (e.g. **In wachtrij** or **Verzonden**).

2. **Test Manual Send ("Nu verzenden"):**
   - In the **E-mailbezorging** card, tap **Nu verzenden**.
   - If SMTP is configured and connected, observe the progress spinner and confirm the status transitions to **Verzonden** with delivery timestamp.
   - If offline or SMTP is not yet configured, verify the job remains safely **In wachtrij**.

3. **Test Native Share Fallback ("Delen via Android"):**
   - In the **E-mailbezorging** card, tap **Delen via Android**.
   - Confirm the native Android share sheet opens showing the certificate PDF, ready to share via WhatsApp, Gmail, Drive, etc.

### Slice 6.2 Implementation Summary & Verification
Slice 6.2 is **fully implemented and verified**. All required architectural, UI, and testing items have passed the Mandatory 3-Gate Pre-Handoff Quality Gate:

1. **Safe Multi-Stage PDF Archiving (`PdfArchiveService`):**
   - Renders the official single-page A4 certificate directly from the immutable `snapshot_json` frozen during visit finalization (`VisitFinalization.save`).
   - Writes to staging file `certificates/staging/visit_<id>_<attest>_v<micros>_<seq>.tmp` with `flush: true`, checks that file length strictly equals generated byte count, then atomically renames to `certificates/visit_<id>_<attest>_v<micros>_<seq>.pdf`.
   - Concurrency is protected via `package:synchronized` `Lock()`, declared as a direct dependency in `pubspec.yaml` and documented in `ARCHITECTURE.md`.
   - App startup cleans up any orphaned `.tmp` staging files under lock before the app becomes interactive (`cleanupStagingFiles()` in `main.dart`).

2. **Recipient Confirmation Dialog (`EmailRecipientDialog`):**
   - Modal alert (**Ontvangers bevestigen**) styled with existing dark theme tokens, showing customer name and email from the frozen certificate snapshot.
   - Displays optional technician copy checkbox (prefilled from `technician_profile.email_copy_technician` and statutory technician email).
   - Tapping **Overslaan** cancels email queuing while safely retaining the finalized visit and archived PDF.
   - Tapping **In wachtrij plaatsen** confirms recipient choices and proceeds to atomic outbox job creation.

3. **Atomic Outbox Job Creation & Resilient Coordination (`EmailOutboxRepository` & `PdfArchivingCoordinator`):**
   - Atomically inserts queued jobs into `email_delivery_jobs` with `status = 'queued'`, `attempt_count = 0`, and the archived `pdf_path`.
   - Idempotent: protected by SQLite unique index on `(visit_id, recipient_type)` with `INSERT OR IGNORE`.
   - Distinguishes newly queued jobs (`EmailQueueResult.queued`), already-queued duplicate jobs (`EmailQueueResult.alreadyQueued`), and skipped jobs (`EmailQueueResult.skipped`).
   - Updates `pdf_status = 'ready'` and `pdf_path` strictly for finalized visits (`is_draft = 0`).
   - Database registration failure handling: if PDF generation and rename succeed but SQLite update fails, an explicit non-dismissible dialog (**Database-registratie mislukt**) warns that skipping will delete the unregistered PDF, and offers **Opnieuw proberen** (verifies file existence on disk and registers same PDF path via `registerArchivedPdf` without regenerating) or **Verwijderen en overslaan** (prompts a second confirmation dialog **Niet-geregistreerde PDF verwijderen?** before coordinator delegates safe deletion via `deleteUnregisteredArchiveFile`; if deletion succeeds, displays `pdfRegistrationFailed`, whereas if deletion fails and the file remains, displays clear localized error feedback `pdfDeleteFailedError`).
   - Recoverable outbox failure in completion flow: if queuing fails, an explicit non-dismissible dialog (**E-mailwachtrij mislukt**) with `barrierDismissible: false` and `PopScope(canPop: false)` offers **Opnieuw proberen** (retries with identical visit ID, PDF path, and recipient choices) or **Overslaan** (neutral `TacticalFeedback.showInfo`, keeping finalized visit and archived PDF 100% intact).

4. **Code Quality, Static Hygiene & Test Suite Verification:**
   - Static analysis (`flutter analyze --no-pub`) reports **0 issues**.
   - Formatter (`dart format --output=none --set-exit-if-changed`) reports **0 unformatted files**.
   - Focused Slice 6.2 tests: **28 passing tests** across `pdf_archive_service_test.dart` (4), `email_outbox_repository_test.dart` (3), `pdf_archiving_coordinator_test.dart` (6), `email_recipient_dialog_test.dart` (4), `pdf_archiving_failure_and_retry_test.dart` (3), `pdf_registration_failure_test.dart` (6), and `pdf_registration_integration_test.dart` (2).
   - Full test suite: **386 tests** passing with exit code 0 (`flutter test --no-pub`).
   - Line count audit: Every single Dart file in `lib/` and `test/` strictly respects the **<= 250 line limit** (zero files over 250 lines).

### Owner Check on Android

Test Slice 6.2 on an Android phone or tablet:

1. **Complete a Valid Visit:**
   - In **Verbrandingsattest**, fill in or ensure a valid visit with customer name and email address (Tab 4), appliance & measurements (Tabs 5 & 6), and conclusions & signatures (Tab 7).
   - Tap **Voltooien** on Tab 7 and confirm the finalization dialog (**Attest bewaren**).

2. **Verify Recipient Confirmation Dialog:**
   - Verify that after saving, the recipient dialog **Ontvangers bevestigen** opens automatically.
   - Confirm that the customer's name and email address appear accurately.
   - Confirm that the technician copy checkbox is present with your technician email.
   - Check or uncheck the technician copy as desired.

3. **Verify Job Creation & Dialog Confirmation:**
   - Tap **In wachtrij plaatsen**: confirm green feedback banner ("E-mailtaak klaargezet in de wachtrij.").
   - Reopen **Historiek**: confirm the completed certificate appears.

4. **Verify Skip / Cancel Behavior:**
   - On a second test visit, tap **Voltooien** and tap **Overslaan** in the recipient dialog.
   - Confirm green notification ("Attest opgeslagen. E-mail overgeslagen.").
   - In **Historiek**, confirm that the certificate is still safely finalized and viewable/printable, with no email jobs queued.

### Slice 6.1 Implementation Summary & Verification
Slice 6.1 is **fully implemented and verified**. All required architectural, UI, and testing items have passed the Mandatory 3-Gate Pre-Handoff Quality Gate:

1. **UI Relocation to `Instellingen`:**
   - Outbound SMTP setup is hosted in `TechnicianSettingsScreen` under `AppletType.technicianSettings` ("Instellingen" in the drawer and persistent AppBar).
   - Layout is top-aligned using `WorkflowTabContainer`, ensuring the Bento card starts consistently below the AppBar (12px top inset matching Verbrandingsattest tabs), keyboard dismisses smoothly on drag/tap, and content is constrained to max 600px width on tablet.
   - Tab 3 (*Firma - Technicus*) has been completely cleaned of email settings, keeping it strictly reserved for certificate-printed statutory company and technician details.

2. **Strongly Typed Service Outcomes & Centralized Localization:**
   - `EmailSenderService.testConnection()` returns strongly typed domain outcomes (`enum SmtpConnectionResult`).
   - All user-facing tactical feedback messages are localized in Flemish and mapped via `EmailDeliveryDictionary`.

3. **Constructor-Injected ViewModel Architecture (`ChangeNotifier` + `ListenableBuilder`):**
   - `TechnicianSettingsApplet` at the applet boundary acts as the composition point, calling `createTechnicianSettingsNotifier()`, managing explicit notifier lifecycle and disposal (including cancellation if navigating away while initialization is pending), and passing the injected notifier into the pure screen view `TechnicianSettingsScreen(notifier: notifier)` and `EmailSettingsCard(notifier: notifier)`.
   - `TechnicianSettingsScreen` and `EmailSettingsCard` are clean widgets with zero repository/database/service construction. Zero third-party state packages or service locators were introduced.

4. **Sender Identity Separation & Validation Policy:**
   - `EmailSenderService.resolveSenderEmail` separates SMTP authentication credentials from the visible `Message.from` address.
   - Syntax validation is handled by the shared, pure-Dart `EmailAddressValidator` without UI dependencies, shared with `BelgianFormatters.validateEmail`.
   - Gmail uses the format-validated `smtp_username` directly. Custom SMTP uses format-validated `smtp_username`, falling back to format-validated `technician_profile.email` if permitted, and returning `null` if neither is valid. No synthetic fallback addresses (`username@host`) are created.

5. **Single-Account Disconnect & Crash-Safe Clear Protocol:**
   - Discreet action **E-mailinstellingen wissen** in `EmailSettingsCard` backed by `showEmailClearConfirmationDialog`. Explains that the SMTP connection is removed from this device and automatic sending is disabled, while company/technician profile, customers, boilers, visits, PDFs, and queued jobs are preserved.
   - Crash-safe clearing protocol across SQLite and secure storage: sets `smtp_state = 'clearing'` in SQLite with reset SMTP fields (`auto_send = 0`, `copy_technician` preserved, statutory email preserved), idempotently deletes active and staged secrets in KeyStore, then finalizes `smtp_state = 'unconfigured'`.
   - Startup recovery handles interrupted clear (`clearing` $\to$ delete secrets, finalize `unconfigured`), detects configured profiles with missing active secrets (`configured` with missing password $\to$ `needs_attention`), and discards orphaned staged keys on startup even if no profile row exists yet.

6. **Clean Test Runner Termination & Full Suite Verification:**
   - Fixed `FakeAsync` isolate pause in widget tests using `await tester.runAsync(...)` for SQLite FFI interactions.
   - All staged-credential recovery cases (interrupted clear, missing staged key $\to$ `needs_attention`, missing active key $\to$ `needs_attention`, orphaned staged key with or without profile row $\to$ discard staged without altering active credentials) are implemented and unit tested.
   - All 37 focused email tests (`email_sender_policy_test.dart`, `email_settings_repository_test.dart`, `email_settings_clear_test.dart`, `email_settings_ui_test.dart`, `email_settings_clear_ui_test.dart`, `email_settings_retry_ui_test.dart`) plus all 6 theme and drawer navigation tests (`theme_test.dart`) pass synchronously with exit code 0 (43 focused tests total).
   - The full test suite of **358 tests** passes with exit code 0 (`flutter test --no-pub`).
   - Static analysis (`flutter analyze --no-pub`) reports **0 issues**.
   - Every Dart file in `lib/` and `test/` strictly respects the **$\le 250$ line limit**.

### Owner Check on Android

Test Slice 6.1 on an Android phone or tablet:

1. **Verify UI Separation in Tab 3:**
   - Open **Verbrandingsattest** from the drawer or dashboard and navigate to Tab 3 (**Firma - Technicus**).
   - Verify that Tab 3 contains only statutory company and technician profile fields. Confirm that no email configuration card appears here.

2. **Open Instellingen & Verify Top-Aligned Layout:**
   - Open the drawer and tap **Instellingen** in the *Beheer* section.
   - Verify that the persistent AppBar displays **Instellingen**.
   - Verify that the **E-mailconfiguratie (SMTP)** Bento card starts consistently below the AppBar (12px top inset), matches the Verbrandingsattest dark surface and styling, and is constrained to max 600px width on tablet.
   - Tap outside an input field and confirm the soft keyboard dismisses smoothly. Confirm content remains fluidly scrollable.

3. **Verify Preset Toggles & Visibility:**
   - Tap **Gmail (App-wachtwoord)**: confirm host defaults to `smtp.gmail.com`, port to `465`, and the 16-digit Google App-password tip is displayed.
   - Tap the eye icon on the password field: confirm password toggle works between obscured and plain text.
   - Tap **Aangepaste SMTP**: confirm custom host and port inputs appear, along with the **SSL/TLS (465)** vs **STARTTLS (587)** toggle.

4. **Test Connection & Save State:**
   - Enter invalid/empty credentials and tap **Verbinding testen**: confirm a localized tactical warning appears ("Configuratiefout...").
   - Enter your real SMTP credentials (or Google App-password) and tap **Verbinding testen**: confirm green tactical success feedback ("Verbinding en inloggegevens geslaagd").
   - Tap **Instellingen opslaan**: confirm success notification. Force-close and restart the app, then reopen **Instellingen** and verify that your username, provider, and settings persist from SQLite, while the password field displays the saved placeholder dots (`••••••••••••••••`).

5. **Test Disconnect / Clear Action (E-mailinstellingen wissen):**
   - Tap **E-mailinstellingen wissen**: confirm a dialog opens explaining that the SMTP connection is removed from this device and automatic sending is disabled, while company/technician profile, customers, boilers, visits, PDFs, and queued jobs are preserved.
   - Tap **Annuleren**: confirm settings and the "Automatisch verzenden" switch remain unchanged.
   - Tap **E-mailinstellingen wissen** and tap **Wissen**: confirm green success notification ("E-mailinstellingen en inloggegevens gewist"). Confirm the username is cleared, password placeholder dots disappear, status resets to unconfigured, and the "Automatisch verzenden" switch is turned off.
   - Open Tab 3 or completed visits to confirm company profile and past certificates remain 100% intact.

---

### Historical Milestone 5 Handoff Notes

**Milestone 5 complete (Slice 5.5 accepted on Android).** All 5 slices of Milestone 5 are implemented, verified by automated tests (321 tests passing, 0 analyzer lints, all files $\le 250$ lines), and confirmed working on Android by the owner. The app supports full Basisregisters Vlaanderen address lookups, local independent VEKA portal tracking, completed certificate history & inspection reminders, boiler reuse at verified addresses, and mock VEKA API reporting with recovery & receipt tracking.

### Slice 5.5 implementation checklist

- [x] Save the exact outgoing JSON, report snapshot, contract version and request reference before the mock transport runs.
- [x] Keep each dispatch and its response. An uncertain result blocks automatic resending and the portal until an explicit check resolves it.
- [x] Make unfinished reports visible in Historiek with actions for starting, resuming, checking, correcting, or following up a portal report.
- [x] Allow an archived API correction only when the rejection identifies `datumActiviteit`. Require a different valid date, save a new attempt, and preserve the original signed certificate and rejected attempt.
- [x] Keep the existing response classification, including access refusal as a recoverable technical state and a possible duplicate response as uncertain.
- [x] Final static analysis reports no issues; all **321** Flutter tests pass; no Dart file in `lib/` or `test/` exceeds 250 lines.
- [x] Complete the owner’s Android acceptance checks below. Owner confirmed: looks good on Android.

### Owner check on Android

Use the connected Android phone and a different synthetic visit for each scenario. Run `flutter run --dart-define=VEKA_MOCK_PORTAL=true`. Each visit needs a supported central natural-gas or oil appliance, a linked installation, and complete reporting fields. In **Eindbeoordeling → Bekijk testmelding**, check the address, bus, serial number and activity before choosing a simulated result.

1. **Access refusal and recovery.** Select **Technische fout**. Save the certificate and open **Historiek**; the top follow-up card should show **Melding hervatten**. Open it, retry after recovery, and choose **Aanvaard met ontvangstbewijs**. In **Bekijk testpogingen**, confirm both dispatches use the same reference and the receipt appears.
2. **Uncertain outcome.** On a fresh visit, choose **Onzeker na time-out**, save the certificate and open its Historiek action. Confirm that it offers **Uitkomst controleren**, with no blind retry or portal action. Use **Bevestig gevonden testbewijs**; the attempt should resolve with a receipt and no second dispatch. The explicit absence branch can be checked on another fresh visit and must reuse the original reference.
3. **Archived date correction.** On a fresh visit, choose **Afgewezen met veldfouten**, then save the certificate. In Historiek, open **Gegevens verbeteren**, choose a different valid date and submit. Confirm the previous rejection and the new attempt both remain visible, the new attempt has a receipt, and the saved certificate is unchanged. Confirm that choosing the rejected date again does not submit.
4. **Successful receipt.** Open an accepted test report from Historiek and compare its receipt, address and bus with the reviewed request. Restart the app and confirm the report and receipt remain available.

### Scope and external dependency

The automated tests confirm that a possible duplicate response is treated as uncertain and cannot trigger a blind resend. The mock does not establish whether VEKA treats `externeReferte` as an idempotency key and cannot detect an equivalent submission from another device. Verify that behavior against VEKA’s secured test environment before live use. Live verification still requires an approved contract, secured connection and reconciliation against a matching test registration.

**Slice 5.4 — Reuse a saved boiler.** The owner confirmed on Android that the saved appliance details could be retrieved. Tab 5 offers appliances from completed certificates at the installation address saved in Tab 4, including its exact bus number. Choosing an appliance copies its boiler and burner details into the current draft. The previous certificate and VEKA evidence remain linked to the earlier visit.

Static analysis, the 289-test Flutter suite, the four focused saved-boiler tests, and the Android debug build with `VEKA_MOCK_PORTAL=true` passed.

1. Run `flutter run --dart-define=VEKA_MOCK_PORTAL=true` on Android. Use a completed test certificate in **Historiek** with a known installation address, bus and boiler serial number.
2. Start a new visit. In **Klant**, save the same installation address and bus. Before adding measurements or reporting evidence, open **Stooktoestel** → **Opgeslagen toestel kiezen**. Select the matching boiler, then tap **Toestel overnemen**. Check the model and serial number in the form.
3. Restart the app and reopen the draft. Check that the copied fields persist. In **Historiek**, open the original certificate and its saved VEKA record to confirm that their address and details still match the earlier visit.
4. Start another draft at the same street and house number with a different bus. Open the picker and check that the first bus's boiler is absent. If there are no saved boilers, tap **Nieuw toestel invoeren** to use the manual form.

**Slice 5.3 — History & Reminders Dashboard.** Owner accepted after testing **Historiek** and the upcoming maintenance list on Android and reviewing the Tab 7 VEKA card refinements. **Voltooien** saves a frozen certificate in SQLite. Reminders use the saved next-maintenance date and can be shared via Android's share sheet. The full Flutter suite passed 285 tests after the field move. The later divider spacing change passed the formatter check.

1. Run `flutter run --dart-define=VEKA_MOCK_PORTAL=true`. Open a valid test visit, set a next-maintenance date within 30 days, tap **Voltooien** and confirm **Attest bewaren**.
2. In **Historiek**, search for the customer or boiler serial number and open the certificate. Check the address and boiler details. Open the **VEKA-melding bekijken** action beside the certificate and verify the original saved reporting version.
3. Restart the app and open **Historiek** from the drawer. Check that the certificate is still there and that **Herinnering delen** opens Android's share sheet with the saved address and date.
4. Open **Verbrandingsattest** and verify a new visit opens with the company profile retained and the previous visit's customer, boiler and measurements cleared.

**Slice 5.2 — Independent VEKA Reporting Tracker.** Accepted on Android. The owner reopened the mock app and confirmed that **Manueel gemeld** and the original installation address persisted. The local preview and portal tracker passed 280 Flutter tests and static analysis before the field-specific validation follow-up, which passed its six focused tests. The mock uses a separate SQLite database and simulates opening the portal.

The checkout contains accepted Slices 5.2–5.4 alongside Slice 5.1, pending Slice 5.5, and pre-existing edits. Commit and push are pending while the accepted changes are separated from the other edits.

1. Complete a synthetic central natural-gas or heating-oil visit, including **Type verwarming**, **Condensatietype** and the three conformity choices in the **VEKA-melding** card on **Eindbeoordeling**. In **Eindbeoordeling**, preview the report, then choose **Open VEKA-portaal** and **Bewaar versie en open portaal**. Check that the status is **Nog niet bevestigd**.
2. Save a different installation address and force-close and reopen the mock app. Check that the current preview shows the new address and **Heropen VEKA-portaal** shows the original saved address.
3. Confirm the original version with your test name and reopen the app. Check **Manueel gemeld**, the original address and the recorded confirmation.
4. Generate the **Test-PDF** offline and check that the report remains **Manueel gemeld**.


**Slice 5.1 — Basisregisters Vlaanderen on the Klant tab.** The address lookup and draft safety changes are implemented. The owner confirmed the main lookup flow and retested apartment selection and manual bus edits on Android.

### Current behavior

- The technician chooses where the appliance is installed before entering an address. The lookup icon in each visible `Straat` field opens a prefilled dialog for that address.
- Multiple matches require an explicit choice. **Zoeken zonder busnummer** retries the current query without a bus filter while preserving the typed bus. The selected result fills the official address text.
- A separate billing lookup fills customer address text only. An installation lookup resolves building and unit IDs for the selected address after confirmation. Verification appears on the effective installation preview. Ambiguous units remain unconfirmed and manual entry works offline.
- The Klant edit queue keeps autosave, final save, and cancellation ordered. **Nieuw** preserves the original customer. **Opslaan** commits the final values and clears undo together. Reopening a pending edit restores its save and cancel actions. **Annuleren** restores the original links and preserves the draft boiler.

### Verification

- `dart format`, `flutter analyze --no-pub`, and the 250-line limit for `lib/` and `test/` passed.
- `flutter test --no-pub` passed all **274** tests. Coverage includes explicit apartment selection, retry without a bus number, separate billing routing, cancellation during verification, SQLite rollback, and reopening an autosaved edit.
- The owner confirmed that selecting bus `0001` and then another bus updates the full address under **Locatie toestel**. Manually editing the bus immediately switches the preview to **Handmatig ingevoerd**. This retest checked the on-screen address and status. The raw registry IDs were not independently compared.

### Address lookup follow-up

- Results now appear inside the search dialog, with street, number and bus on the first line and postcode and municipality below. Applying a match still requires explicit confirmation.
- The search now sends the municipality when entered. Enrichment checks that the unit response matches the requested ID. An inconsistent unit response cannot produce a green badge. The badge now reads **Gekoppeld aan Basisregisters**.
- For an independent registry check, use a public address with two registered buses and compare the stored address, building and unit IDs with the official records.

### Owner check on Android

1. Run `flutter run` and open **Klant** in edit mode. In shared mode, confirm that a lookup beside **Straat** fills the customer fields and updates the installation preview.
2. Try an apartment address. With multiple matches, check that each result shows the full bus and municipality and **Adres overnemen** waits for a selection. Retry with **Zoeken zonder busnummer** and choose the official bus from the results.
3. Switch to **Op een ander adres**. Look up the installation first, then look up the billing address. Confirm that the installation address and status stay the same.
4. Turn off the connection and enter an address manually. Leave and reopen the draft to confirm that the address is retained.

The owner authorized Slice 5.2 after the Android retest. Slice 5.1 changes remain in the working tree alongside pre-existing edits and have yet to be committed and pushed.

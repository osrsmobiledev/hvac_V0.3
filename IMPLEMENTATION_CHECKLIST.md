# Implementation Checklist & Anti-Pattern Prevention (hvac_V0.3)

> **Purpose:** Short, high-impact reminders and verification checks to run after every slice or code modification. Derived from past code review findings and inspection fixes.

---

## 1. Past Mistakes & Root Causes (What Went Wrong & Why)

| # | Mistake / Anti-Pattern | Why It Was Wrong | What Was Fixed |
|---|------------------------|------------------|----------------|
| **1** | **File length exceeded 250 lines** (`bo2_time_spinner.dart` was 252 lines) | Violates hard rule in `AGENTS.md`. Large files hurt maintainability and increase AI context pollution. | Extracted `Bo2LaserDivider` and `Bo2WheelColumnLabels` to sibling file (`bo2_time_wheels.dart`). |
| **2** | **Silent exception swallowing** (`catch (_) {}`) | Swallowing errors leaves DB failures completely silent. Developers and users cannot tell why forms stay blank or unpopulated. | Added `debugPrint('[Class] method error: $e\n$stack')` and safe fallback states (`setState(() => _isLoading = false)`). |
| **3** | **Unprotected async calls** (Missing try/catch in `_saveDraft` & `_saveProfile`) | An unexpected SQLite lock or migration glitch causes unhandled async crashes or silent autosave drops. | Wrapped all draft save and profile update routines in robust `try/catch` blocks. |
| **4** | **`PageStorage` read loop in `didChangeDependencies`** (`BentoMainSection` / `BentoSubSection`) | `didChangeDependencies` runs multiple times (theme/keyboard/orientation changes). It repeatedly overwrote user's active expand/collapse toggle. | Guarded with `_hasRestoredState` boolean flag to ensure state restores only once on mount. |
| **5** | **Hardcoded UI strings** (inline tab titles instead of `AppDictionary`) | Violates centralization rule. Changes to Dutch labels in `AppDictionary` wouldn't reflect on the tab bar. | Replaced inline static list with `AppDictionary.combustionTabs`. |
| **6** | **Theme / Component token mismatch** (`hintStyle` 14px in theme vs 15px in `DarkInputBox`) | Inconsistent typography sizes cause jarring visual baseline and scale shifts across inputs. | Aligned `hintStyle` `fontSize: 15` in `app_theme.dart` with `DarkInputBox`. |
| **7** | **Font styling hacks** (using arbitrary `height: 1.25` multipliers) | Caused uneven vertical alignment and visual rendering bugs with the Libron font. | Removed custom `height` multipliers; unified on standard `DarkInputBox.inputStyle`. |
| **8** | **Missing DB migration stub** (no `onUpgrade` in `AppDatabase`) | App would have trouble upgrading SQLite schemas for upcoming slices (e.g. `stooktoestel`). | Added an `onUpgrade` stub and migration instructions. |
| **9** | **Per-field `onTapOutside` hacks & redundant per-screen `GestureDetector` wrappers** | Per-field hacks cause focus bugs when opening drawers, and per-tab wrappers create redundant, conflicting hit-test layers. | Replaced with canonical root `MaterialApp.builder` global tap-to-dismiss, explicit unfocus on drawer open, and `ScrollViewKeyboardDismissBehavior.onDrag` on lists. |
| **10** | **`_buildX()` helper methods returning widgets** (e.g. `_buildAppBarTitle`) | Helper methods lack their own `BuildContext`, cannot use `const`, and bypass Flutter's widget reconciliation and element tree caching. | Extracted to dedicated private `StatelessWidget` classes with `const` constructors. |
| **11** | **Inconsistent tab padding & bento-to-bento spacing** (`10px`, `12px`, `16px`, `18px`) | Caused the top Bento card header to jump 4–6px vertically when swiping between tabs, and created uneven gaps between cards. | Centralized tokens in `AppTheme`: `AppTheme.tabViewPadding` (12px top offset) and `AppTheme.bentoCardSpacing` (14px). |
| **12** | **Duplicate SnackBar styling across tabs** | `klant_action_dialogs.dart`, `customer_search_modal.dart`, `data_tab.dart`, `meting_slot_actions.dart`, and `stooktoestel_tab.dart` each hand-crafted their own `SnackBar` with bespoke colors and borders. | Created `lib/core/widgets/tactical_feedback.dart` with `TacticalFeedback.showSuccess(...)`, `showInfo(...)`, and `showError(...)`. |
| **13** | **Duplicate 40x40 square icon-button container** (`rookgassen_card.dart` QR + Delete buttons) | The Delete and QR Scan buttons in Tab 1 manually built their own 40x40 `Container` with rounded border and colored icon. | Created `lib/core/widgets/tactical_square_button.dart` to unify all 40x40 square action buttons. |
| **14** | **Hardcoded inline Dutch strings inside widget trees** | Inline strings like camera error messages and modal slot titles bypassed the dictionary. | Added missing strings to `MetingDictionary` and `AppDictionary`; zero inline Dutch strings allowed in widgets. |
| **15** | **Manual `Center > ConstrainedBox > ListView` boilerplate duplicated in Tabs 4, 5, 6** | `klant_tab_body.dart`, `stooktoestel_tab_body.dart`, and `meting_tab.dart` each repeated the same scroll-container boilerplate instead of using `WorkflowTabContainer`. | Replaced manual boilerplate with shared `WorkflowTabContainer(scrollKey: '...')`. |
| **16** | **Uncoordinated SQLite queries during gestures & cold applet teardown** | Caused dropped frames (jank/lag) during the first tab swipe on physical devices because tabs independently read SQLite mid-gesture, and navigating to Home destroyed the screen. | Implemented parallel startup pre-warm (`AppWarmupService`), synchronous Frame-1 `visitId` injection to tabs, and `IndexedStack` screen preservation in `AppShellScreen`. |
| **17** | **`copyWith` ignoring `null` values on cleared inputs** (`field: field ?? this.field`) | Dart's `??` operator treats `null` as "no argument passed, use existing value". When the user cleared an input, the model retained the old number in memory and did not save `NULL` to SQLite, so the old value reappeared after app restart. | Implemented official Dart Sentinel pattern (`static const Object _sentinel = Object();`) in `copyWith` across domain draft models (`OperatingConditionsDraft`, `BoilerDraft`, `MeasurementSlotDraft`). |
| **18** | **Duplicate text field widget implementations** (`DarkTextField` vs `DarkTextFormField`) | Multiple distinct text input widgets created inconsistent controller synchronization and validation borders across tabs. | Refactored `DarkTextField` to delegate directly to `DarkTextFormField`, giving all tabs the same zero-jump validation and real-time controller listener sync. |
| **19** | **Fragmented red error borders on multi-choice button groups** | Individual buttons each turned red separately on validation errors, creating a cluttered look instead of a unified group border like Tab Meting. | Created `TacticalGroupOutline` in `lib/core/widgets/tactical_group_outline.dart` to enclose button pairs/groups with a single, zero-layout-shift red border. |
| **20** | **Confrontational / contradictory signature exception controls** | Displaying permanent "Weigert" / "Afwezig" buttons right under the customer signature box looked awkward when presenting the device to customers, and allowed conflicting signed + refused states. | Implemented progressive disclosure via `CustomerSignatureSection`: exception choices are tucked behind a discreet chevron ("Klant kan niet ondertekenen? ▾") and completely hidden once the customer signs (mutual exclusivity). |
| **21** | **`pw.Spacer()` in fixed-height PDF bounding box** (`pdf_gebreken_handtekeningen_builder.dart`) | Adding 6 defect items wrapped text to line 2. `pw.Spacer()` collapsed to 0 and continuing text pushed the signature row down past the bottom border of the box, where the legal footer underneath painted over it, making signatures disappear/show blank. | Replaced `pw.Spacer()` with mathematically bounded Two-Zone Vertical Partitioning (Zone 1: fixed 46.5 pt for defects/remarks with font 5.2 pt; Zone 2: fixed 38.0 pt for signatures). Zone 1 can never push Zone 2, and signatures are permanently anchored at their exact coordinates. |
| **22** | **PDF Preview lacking touch pinch-to-zoom gestures in mobile dialog** | `PdfPreview` default constructor renders pages inside a `ListView.builder` that intercepts single-touch vertical scroll gestures and ignores two-finger pinch-to-zoom gestures, making small statutory text illegible on phones. | Switched to `PdfPreview.builder` with `InteractiveViewer` at 240 DPI, supporting 1.0x-5.0x multi-touch pinch-to-zoom, 1-finger pan, double-tap 2.5x toggle, and top-bar zoom controls (`+`, `-`, `Fit`). |
| **23** | **Redundant unawaited async DB call in widget `dispose()`** (`meting_tab.dart`) | `_debouncer.dispose()` already flushes pending saves. Calling `_saveToDatabase()` a second time in `dispose()` without await caused SQLite transactions to execute after widget disposal and database closure, throwing `Bad state: This database has already been closed`. | Removed redundant `_saveToDatabase()` in `dispose()`, letting `_debouncer.dispose()` handle the single synchronous flush. |
| **24** | **Burner type database enum leaking into PDF type line when integrated** | Official Flemish statutory template requires all 5 burner lines to remain completely blank when the boiler has an integrated burner. Mapping `burner_type` ('geintegreerd') into the `Type:` line violated the official government layout. | Added `final isSepBurner = str(boiler, 'burner_type') == 'afzonderlijk';` in `PdfDataMapper`. All 5 burner fields map to `''` when integrated. |
| **25** | **Redundant installation address printed when identical to customer address** | Under Flemish regulations, when installation address is identical to the customer address, the right-side installation box must be left blank. | Implemented `_hasSeparateInstallationAddress` in `PdfKlantBuilder` with 5-field normalization (`street`, `house_number`, `box_number`, `postal_code`, `city`). If identical, right-side address lines remain clean and blank. |
| **26** | **Unclosed `HttpClient` & dynamic dropdown state mismatch** (`basisregisters_service.dart` / `address_lookup_dialog.dart`) | Omitting `try ... finally { client.close(); }` on HTTP calls leaks socket descriptors on network errors/timeouts. Re-querying without keying `DropdownButtonFormField` causes Flutter to retain old unmapped selections and throw a duplicate/missing value exception. | Wrapped `HttpClient` in `try ... finally { client.close(); }`, implemented `operator ==` and `hashCode` on `AddressMatch`, and added `key: ValueKey(_matches)` with `initialValue: _selected` to reset state seamlessly on each search. |
| **27** | **Stale address verification & incomplete Basisregisters API hierarchy traversal** (`klant_form_controllers.dart`, `klant_tab_state_data.dart`, `basisregisters_service.dart`, `address_lookup_dialog.dart`) | Changing verified house numbers or toggling installation address retained old VEKA IDs; comparing only street & nr collapsed distinct apartment bus numbers; querying `/v2/adressen/{id}` failed to retrieve building/unit IDs because the API returns a link to `/v2/gebouweenheden?adresobjectid=`; blank postcode caused HTTP 400; socket timeout didn't guard stalled streams. | Implemented `isCurrentAddressVerified({required bool isSameAsCustomer})` to invalidate IDs on any field edit or address toggle; enforced 5-field address comparison in `applyLocation`; traversed `/v2/gebouweenheden?adresobjectid=` -> `/v2/gebouweenheden/{id}` for all candidates; added controller query listeners to clear stale results; enforced required postcode; guarded full request and stream lifecycle with `timeout()`. |
| **28** | **Prematurely treating ordinary offline states as uncertain in outbox dispatch** | Relying solely on `send()` for connection status caused ordinary offline basement visits to throw `SocketException` during send, marking jobs as `uncertain_timeout` and demanding manual technician confirmation of duplicate risk. | Implemented preflight connection check via `mailer.checkCredentials()` before claiming jobs. If offline (`SocketException` / timeout), the outbox run aborts immediately, keeping jobs `queued` with `attempt_count = 0`. |
| **29** | **Overloading existing classes past Single Responsibility & 250-line limit ("Fake Code Reuse")** | Cramming private document staging, versioning, size checks, and cleanup into `PdfFileSaver` (174 lines) bloated a public export class and risked breaching the 250-line rule. | Separated public exports (`PdfFileSaver`) from private internal archiving (`PdfArchiveService`), staging in `certificates/staging/` beside destination with length verification and startup orphan cleanup. |
| **30** | **Assuming cross-store atomicity between SQLite and OS KeyStore** | Treating SQLite and Android KeyStore as a single atomic transaction led to impossible rollback claims if SQLite failed after KeyStore was written. | Implemented staged credential protocol (`smtp_password_staged` $\to$ `smtp_password`) with `smtp_state` tracking in SQLite and deterministic startup recovery. |
| **31** | **Rhetorical or legalistic claims in technical specifications** | Terms like "juridisch bewijs" or "100% duplicate-proof" make unverifiable guarantees on protocols (like SMTP) that lack end-to-end delivery confirmation. | Use neutral, precise technical terminology: "bevroren certificaat-snapshot", "definitieve bezoekrecord", "best-effort botsingsreductie". |

---

## 2. 26-Point Post-Implementation Checklist

Run through these exact 20 verification checks before marking any tab, applet, or slice complete:

### [ ] 1. File Length Limit ($\le$ 250 Lines)
- [ ] No Dart file in `lib/` exceeds **250 lines**. Split large widgets into small, private `StatelessWidget` classes or sibling files.
- **PowerShell check command:**
  ```powershell
  Get-ChildItem -Path "lib" -Recurse -Filter "*.dart" | ForEach-Object { $c = (Get-Content $_.FullName).Count; if ($c -gt 240) { Write-Host "$c lines: $($_.FullName)" } }
  ```

### [ ] 2. Zero Silent Error Swallowing
- [ ] No empty `catch (_)` blocks anywhere.
- [ ] All errors in `catch` blocks must be logged via `debugPrint('[ClassName] method error: $e\n$stack')`.
- [ ] In UI `catch` blocks, ensure `if (mounted) setState(() => _isLoading = false);` is called so the screen never hangs on a permanent spinner.

### [ ] 3. Protected Async Database Calls
- [ ] Every database query, draft load, autosave routine, and profile update has its own `try / catch` block.
- [ ] Background debounced flushes must never throw unhandled async exceptions if SQLite encounters a transient lock.

### [ ] 4. Lifecycle & PageStorage State Safety
- [ ] If restoring scroll/expansion state in `didChangeDependencies`, guard it with `_hasRestoredState` so it only executes once.
- [ ] Always call `super.build(context)` when using `AutomaticKeepAliveClientMixin`.
- [ ] Cancel/flush all active `Timer?` or `Debouncer` instances in `dispose()`.
- [ ] Dispose all `TextEditingController` and `ScrollController` instances in `dispose()`.

### [ ] 5. Centralized Dutch UI Strings (`AppDictionary` & Feature Dictionaries)
- [ ] All user-visible labels, headers, hints, placeholders, buttons, and dialogs are in Dutch (Flemish).
- [ ] All UI strings are defined in `lib/app/localization/app_dictionary.dart` or feature-scoped dictionaries under `lib/app/localization/` (e.g. `meting_dictionary.dart`, `visit_history_dictionary.dart`, `email_delivery_dictionary.dart`).
- [ ] Zero hardcoded string literals anywhere inside widget trees (e.g., `'Opslaan'`, `'Annuleren'`, tab names, hints).
- [ ] English is strictly reserved for Dart code symbols, variable names, functions, and `///` comments.

### [ ] 6. Typography & Input Token Consistency
- [ ] All text inputs use `DarkInputBox.inputStyle` (`fontSize: 15`, Libron, pure text color).
- [ ] All text inputs use `DarkInputBox.decoration(...)` for borders, fills, and hint styles.
- [ ] Ensure input hint text style matches theme tokens (`fontSize: 15`).

### [ ] 7. Zero Font Styling Hacks
- [ ] Never apply custom `height: 1.xx` multiplier hacks to `TextStyle` in input boxes or labels.
- [ ] Let the Libron font use standard baseline metrics to prevent cross-device rendering glitches.

### [ ] 8. Database Schema & Migration Integrity
- [ ] All SQLite schema modifications include an `onUpgrade` migration step in `AppDatabase`.
- [ ] Never drop or recreate tables in production paths; preserve existing draft data.

### [ ] 9. Global Focus & Keyboard Dismissal
- [ ] Global tap-to-dismiss is handled via the root `MaterialApp.builder` with an opaque `GestureDetector`.
- [ ] Unfocus explicitly when opening navigation drawers.
- [ ] Set `ScrollViewKeyboardDismissBehavior.onDrag` on scrollable form lists (no per-field or per-screen redundant unfocus hacks).

### [ ] 10. Dedicated Widgets (Zero `_buildX()` Helpers)
- [ ] No `_buildX()` helper methods returning `Widget`.
- [ ] Extract small private `StatelessWidget` classes with `const` constructors to enable Flutter element tree caching and widget reconciliation.

### [ ] 11. Bento Rhythm & Consistent Spacing
- [ ] Every tab view list uses `padding: AppTheme.tabViewPadding` (12px top offset, 16px horizontal, 32px bottom breathing room).
- [ ] Every gap between consecutive Bento cards uses `const SizedBox(height: AppTheme.bentoCardSpacing)` (14px).
- [ ] Never use arbitrary inline padding or random heights between Bento cards.

### [ ] 12. Centralized Tactical Feedback (Toasts / SnackBars)
- [ ] Every transient notification must use `TacticalFeedback.showSuccess(...)`, `TacticalFeedback.showInfo(...)`, or `TacticalFeedback.showError(...)`.
- [ ] Never hand-roll custom `SnackBar`s or raw `ScaffoldMessenger.of(context).showSnackBar` with inline styling.

### [ ] 13. Reusable Tactical Square Buttons
- [ ] Every small (38–40px) square icon-only action button (e.g., QR scan, barcode, delete, search) must use `TacticalSquareButton`.
- [ ] Never build inline `Container → BoxDecoration → Icon` buttons with ad-hoc borders and paddings.

### [ ] 14. Zero Hardcoded Strings in Modals & Dialogs
- [ ] Modal slot titles, scanner error messages, and dialog bodies must reference dictionary constants in `app_dictionary.dart` or feature-scoped dictionaries under `lib/app/localization/` (`MetingDictionary`, `EmailDeliveryDictionary`, `VisitHistoryDictionary`).
- [ ] Never pass raw Dutch or English prose as strings to modal helper functions.

### [ ] 15. Standard Workflow Tab Container (Responsive 600px)
- [ ] Every workflow tab's scrollable body must use `WorkflowTabContainer(scrollKey: '...')`.
- [ ] Never write manual `Center → ConstrainedBox(maxWidth: 600) → ListView` boilerplate in tab body files.

### [ ] 16. Startup Pre-Warming & Gesture-Safe Data Flow (Zero I/O During Swipes)
- [ ] Multi-tab workflows must receive their active document/visit ID synchronously on Frame 1 from the shell or warmup cache.
- [ ] Individual tabs must **never** fire uncoordinated background database queries (`getOrCreateActiveDraft`, profile fetches) mid-gesture during swipe animations.
- [ ] Active workflow applets must be preserved in memory via `IndexedStack` (or `AutomaticKeepAliveClientMixin`) to prevent cold teardowns when navigating between Home and the applet.
- [ ] Core SQLite engine opening and shared profiles must be pre-warmed during startup (`AppWarmupService`) while the splash animation plays.

### [ ] 17. Nullable Fields in `copyWith` (Official Dart Sentinel Pattern)
- [ ] For any domain draft model that contains nullable properties (`double?`, `int?`, `String?`), **never** use `field: field ?? this.field` in `copyWith`.
- [ ] Always declare `static const Object _sentinel = Object();` and check `identical(field, _sentinel) ? this.field : field as Type?`.
- [ ] This guarantees that when a user clears an input, passing `null` explicitly assigns `null` and saves `NULL` to SQLite rather than secretly reverting to the old value.

### [ ] 18. Unified Form Input Validation & Controller Sync
- [ ] All text form inputs must use `DarkTextFormField` (or `DarkTextField`), which encapsulates both `DarkInputLabel` and zero-layout-shift error borders.
- [ ] Every form field must maintain real-time listener synchronization between `TextEditingController` and `FormFieldState` (`controller.addListener`) so simulated values, QR scans, and cleared inputs immediately update error borders and validators.

### [ ] 19. Unified Choice Group Validation (`TacticalGroupOutline`)
- [ ] Multi-choice button pairs or binary toggles (e.g. Tab "Start" activity buttons, Tab "Meting" binary checks) must enclose the entire button row/group inside a single `TacticalGroupOutline`.
- [ ] Individual buttons within the group should maintain their resting border, while `TacticalGroupOutline(hasError: ...)` highlights the entire group with a single zero-layout-shift `AppColors.errorRed` border on validation error.

### [ ] 20. Foolproof Signature Exception UX (Progressive Disclosure & Mutual Exclusivity)
- [ ] Customer signature blocks must hide exception actions (refusal, absence) when a valid signature is present to prevent contradictory states.
- [ ] When unsigned, administrative exception controls must be tucked behind a discreet progressive disclosure trigger rather than displayed prominently to customers.

### [ ] 21. Basisregisters & VEKA ID Governance (Zero Manual Entry & Automated Fail-Safe Flags)
- [ ] Technicians must **never** manually type `adresId`, `gebouwId`, or `gebouweenheidId`. These are strictly populated in the background via the Basisregisters API service (`BasisregistersService`).
- [ ] **Automated Fallback Flagging:**
  - If `gebouweenheidId` is missing or null, automatically derive `gebouweenheidIdNietGekend = true` (or `false` if found).
  - If `gebouwId` is missing or null, automatically derive `gebouwIdNietGekend = true` (or `false` if found).
- [ ] **Nieuwbouw & Offline Safe-Harbor:** Unmapped new developments, unassigned municipal house numbers, or offline basements must **never** block local certificate generation, digital signing, or PDF creation (Golden Rule #5). A missing `adresId` is flagged for manual VEKA web portal reporting or later re-sync, keeping the on-site workflow 100% operational. See [`BASISREGISTER_AND_VEKA_API_SPECIFICATION.md`](file:///c:/Users/Admin/Documents/hvac_V0.3/doc/BASISREGISTER_AND_VEKA_API_SPECIFICATION.md) for full endpoint and payload rules.

### [ ] 22. PDF Vertical Budgeting & Zero Elastic Overflow (`pw.Spacer()` Prohibition in Fixed Containers)
- [ ] **Never** use `pw.Spacer()` or unconstrained `pw.Expanded` inside fixed-height PDF bounding boxes that hold user-supplied multi-line text (e.g. defects, remarks).
- [ ] Always partition variable-content boxes into explicit, bounded vertical zones with fixed heights (e.g. Zone 1: Text bounded at 46.5 pt; Zone 2: Signatures fixed at 38.0 pt).
- [ ] This mathematically guarantees that text overflow can never displace, push down, or clip downstream elements such as signatures or legal footers.

### [ ] 23. PDF Text Budgeting vs Input Character Limits (`maxLength: 200` & Font Sizing)
- [ ] Input fields feeding into PDF text zones must enforce strict character boundaries (e.g., `maxLength: 200` with `MaxLengthEnforcement.enforced`).
- [ ] Text styling in the PDF builder must mathematically fit within `maxLines`: at font size 5.2 pt, a 544 pt line holds ~210 characters, guaranteeing that 200 characters never exceed 2 lines.

### [ ] 24. Single-Page A4 Precision Layout ($\le 825.89\text{ pt}$)
- [ ] The total sum of all statutory section heights, title bars, and inter-section gaps must strictly sum to $\le 825.89\text{ pt}$ (841.89 pt A4 height minus 16 pt vertical margins).
- [ ] Maintain a positive headroom of at least +1.5 to +2.0 pt to absorb minor sub-pixel font rendering variations across different PDF rasterizers.

### [ ] 25. Lifecycle Debouncer Disposal (Zero Unawaited Calls in `dispose()`)
- [ ] In widget `dispose()`, call `_debouncer.dispose()`, which automatically flushes any pending debounced callback.
- [ ] **Never** fire a second, unawaited `_saveToDatabase()` call in `dispose()`. Doing so triggers asynchronous SQLite transactions after the widget unmounts and the test database closes, resulting in `Bad state: This database has already been closed`.

### [ ] 26. Network Resource Safety & Dropdown Keying (`HttpClient` in `finally` & Keyed `DropdownButtonFormField`)
- [ ] Always close `HttpClient` instances inside an explicit `finally` block to prevent lingering socket descriptors or background timers on connection drops, timeouts, or HTTP failures.
- [ ] In dropdown menus populated by asynchronous API queries, key the `DropdownButtonFormField` with `key: ValueKey(_matches)` and implement value-based `operator ==` / `hashCode` on the DTO model to prevent Flutter dropdown value inconsistency exceptions.

### [ ] 27. Address Verification Invalidation & OSLO v2 Hierarchy Traversal
- [ ] Any manual alteration to verified address fields (street, house number, box number, zip, city) or toggling `isSameAsCustomer` must immediately invalidate registry verification status (`verificationStatus = 'unverified'`, `adresId = null`, etc.) to prevent stale registry IDs from sticking to modified locations.
- [ ] Compare all 5 address fields (`street`, `houseNumber`, `boxNumber`, `postalCode`, `city`) to determine if an installation location matches the customer residence; never compare only street and number, which falsely collapses distinct apartment units.
- [ ] Basisregisters API integration must follow the official v2 link hierarchy: `/v2/adresmatch` -> `/v2/gebouweenheden?adresobjectid={id}` -> `/v2/gebouweenheden/{id}` to reliably fetch `gebouweenheidId` and `gebouwId` for any candidate selected by the technician.
- [ ] Enforce required `postcode` on lookup dialog queries to prevent HTTP 400 Bad Request, clear stale search results when query fields change, and attach `.timeout()` to the full `HttpClient` request and response stream lifecycle.

### [ ] 28. SMTP Preflight & Offline Safety (`mailer.checkCredentials`)
- [ ] In `EmailDeliveryCoordinator.processOutbox()`, execute `mailer.checkCredentials(smtpServer, timeout: 4s)` before claiming jobs from SQLite.
- [ ] Explicitly recognize that `mailer.checkCredentials()` is an upfront preflight check (validating network and credentials), not a guarantee that a subsequent `send()` will succeed.
- [ ] If preflight fails due to offline/timeout (`SocketException`), abort the outbox run immediately. Jobs must remain in `queued` with `attempt_count = 0` for automatic retry on app resume.
- [ ] Only errors occurring *during or after* active transmission (`send()`) may transition to `uncertain_timeout`.

### [ ] 29. Dedicated Archiving & Staging Beside Destination (`certificates/staging/`)
- [ ] Stage temporary PDF writes in `certificates/staging/` on the same filesystem as `certificates/` to ensure fast, reliable rename without cross-volume copy races.
- [ ] Verify written file length against memory bytes before renaming to a unique timestamped filename.
- [ ] Run startup cleanup to safely delete orphaned `.tmp` staging files from previous crashed sessions.
- [ ] Keep public OS export (`PdfFileSaver`) strictly separate from private internal application data archiving (`PdfArchiveService`).

### [ ] 30. Staged Credential Protocol Across SQLite & KeyStore
- [ ] Do not assume atomic transactions across SQLite and Android KeyStore.
- [ ] Use a staged credential protocol (`smtp_password_staged` -> `smtp_password`) tracked via `smtp_state` in SQLite (`'unconfigured'`, `'staging'`, `'configured'`, `'needs_attention'`).
- [ ] Require both valid provider settings (host, port > 0, username) and an available active KeyStore password for `smtp_state == 'configured'`.
- [ ] Implement deterministic startup recovery in `EmailSettingsRepository.recoverCredentialsState()`. If SQLite is in `'staging'` but `smtp_password_staged` is missing, transition to `'needs_attention'` (never assume an old active password matches new settings). Block automatic email sending if `smtp_state != 'configured'`.

### [ ] 31. Neutral State-Machine Semantics over Rhetorical Claims
- [ ] State machines and technical documentation must use neutral, verifiable terminology ("bevroren certificaat-snapshot", "best-effort botsingsreductie") rather than unprovable superlatives or legalistic claims ("juridisch bewijs", "100% duplicate-proof").

### [ ] 32. Email Settings Domain Boundary & Platform Safety
- [ ] Outbound SMTP configuration belongs in **Instellingen** (`AppletType.technicianSettings`). Tab 3 (*Firma - Technicus*) is reserved strictly for company details and accreditation numbers printed on the certificate.
- [ ] `smtp_state = 'configured'` strictly signifies local completeness (valid provider fields + stored credential in KeyStore), allowing saving before testing. It does not imply connection or sender verification. `mailer.checkCredentials()` tests connectivity/authentication only; provider sender rejection is a delivery outcome that never blocks certificate saving or PDF generation.
- [ ] Separate SMTP authentication username (`smtp_username`) from visible message sender (`Message.from`). A custom login may be an account ID; never assume a login username is automatically a valid sender address.
- [ ] Visible sender address policy must require an explicitly valid email address (from `smtp_username` if it is an email, or falling back to the format-validated `technician_profile.email` if permitted by the provider). Never construct synthetic email addresses from usernames and hosts (`smtp_username@<smtp_host>`).
- [ ] `technician_profile.email` is format-validated upon entry, not verified via external handshake. An invalid or rejected sender address must block email delivery only; certificate saving and PDF archiving remain 100% independent (Golden Rule #5).
- [ ] Platform and SMTP services must return strongly typed outcomes; map typed outcomes to localized Flemish text in the UI layer (`AppDictionary` / `EmailDeliveryDictionary`).
- [ ] Constructor injection using the project's existing `ChangeNotifier` and Flutter `ListenableBuilder` approach: `TechnicianSettingsApplet` composes the notifier at the applet boundary and passes it via constructor to `TechnicianSettingsScreen(notifier: notifier)` and `EmailSettingsCard(notifier: notifier)`. Do not add an external state package (Provider/Riverpod), service locator (GetIt), or new architecture layer.
- [ ] App lifecycle triggers (`AppLifecycleState.resumed`) belong strictly at the UI boundary (`AppShellScreen`), never inside data coordinators.
- [ ] `flutter_secure_storage` guidance documents `path="FlutterSecureStorage"` (without extension) for SharedPreferences exclusions. Current codebase contains `FlutterSecureStorage.xml`. The exclusion remains unverified until confirmed via an end-to-end device backup/restore test.
- [ ] In outbox recovery (Slice 6.3 with v13 schema migration), manual resolution of an `uncertain_timeout` must set `status = 'resolved_manually'`, populating `resolved_at` with an ISO-8601 timestamp and `resolution_notes` with technician confirmation, while preserving prior `last_error` and `failure_reason` intact; never silently rewrite status to `'sent'`.

---

## 3. Mandatory 3-Gate Pre-Handoff Quality Gate

Every AI agent must strictly run and pass all three gates **before declaring any slice complete or asking the owner to test**. Never hand off based solely on a compilation pass.

### Gate 1: Static Hygiene & File Health
1. **Static Analysis:**
   - Execute `analyze_files` (or `flutter analyze`). Must exit with **0 errors, 0 warnings, 0 infos**.
2. **Strict File-Length Verification ($\le 250$ Lines):**
   - Run the PowerShell check:
     ```powershell
     Get-ChildItem -Path "lib" -Recurse -Filter "*.dart" | ForEach-Object { $c = (Get-Content $_.FullName).Count; if ($c -gt 240) { Write-Host "$c lines: $($_.FullName)" } }
     ```
   - Zero files in `lib/` or `test/` may exceed 250 lines. Extract modular widgets or models before handoff.

### Gate 2: Lifecycle & Resource Hygiene (Zero Leak Gate)
1. **Controller & Listener Disposal:**
   - Every `TextEditingController`, `FocusNode`, `AnimationController`, or `ScrollController` allocated in `initState()` must be disposed in `dispose()`.
2. **Network & Stream Safety:**
   - Every `HttpClient`, socket, or stream subscription must be guarded with `try ... finally { client.close(); }` or `cancel()`. Never allow unclosed network resources on exceptions or timeouts.
3. **Mounted Async Guards:**
   - Every `setState()` following an `await` must be guarded by `if (!mounted) return;`.
4. **Dynamic Collection & Dropdown Keying:**
   - Dropdowns populated by dynamic or async results must be keyed (`key: ValueKey(...)`) and the item model must implement `operator ==` and `hashCode` to prevent Flutter dropdown mismatch crashes.

### Gate 3: End-to-End Domain & Database Trace
1. **Full Domain Coverage (The 90/10 Rule):**
   - Verify that the feature works for both the primary real-world scenario (e.g. boiler at customer residence in 90% of visits) AND the secondary scenario (separate installation address in 10% of visits). Never build only for the sub-widget's happy path.
2. **End-to-End Database Roundtrip:**
   - Trace values: `UI Input -> Controller -> Domain Entity -> Repository -> SQLite Table -> Reopen Draft -> UI Restoration`.
   - Ensure no fields are dropped, zeroed, or defaulted to `null` unintentionally.
3. **Automated Tests:**
   - Run focused unit and widget tests for the changed logic.
4. **Stop-and-Wait Owner Verification:**
   - Provide 3–4 concrete, human-testable steps on device/emulator.
   - Stop and wait for the owner's explicit confirmation before touching the next slice.

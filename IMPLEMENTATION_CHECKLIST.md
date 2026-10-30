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

---

## 2. 15-Point Post-Implementation Checklist

Run through these exact 15 verification checks before marking any tab or slice complete:

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

### [ ] 5. Centralized Dutch UI Strings (`AppDictionary`)
- [ ] All user-visible labels, headers, hints, placeholders, buttons, and dialogs are in Dutch (Flemish).
- [ ] All UI strings are defined in `lib/app/localization/app_dictionary.dart` or `lib/app/localization/meting_dictionary.dart`.
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
- [ ] Modal slot titles, scanner error messages, and dialog bodies must reference dictionary constants (`MetingDictionary` / `AppDictionary`).
- [ ] Never pass raw Dutch or English prose as strings to modal helper functions.

### [ ] 15. Standard Workflow Tab Container (Responsive 600px)
- [ ] Every workflow tab's scrollable body must use `WorkflowTabContainer(scrollKey: '...')`.
- [ ] Never write manual `Center → ConstrainedBox(maxWidth: 600) → ListView` boilerplate in tab body files.

---

## 3. Verification & Handoff Protocol

Before handing off any slice or marking it complete:
1. **Static Analysis:**
   ```powershell
   & "C:\Users\Admin\Documents\Flutter-SDK\flutter\bin\flutter.bat" analyze --no-pub
   ```
   *(Must exit with 0 errors, 0 warnings).*
2. **Test Suite:**
   ```powershell
   & "C:\Users\Admin\Documents\Flutter-SDK\flutter\bin\flutter.bat" test --no-pub
   ```
   *(All tests must pass).*
3. **Strict Stop-and-Wait Policy:** Wait for the owner's verification and explicit go-ahead before touching the next slice.

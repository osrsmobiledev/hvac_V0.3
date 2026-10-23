# Implementation Checklist & Anti-Pattern Prevention (hvac_V0.3)

> **Purpose:** Short, high-impact reminders and verification checks to run after every slice or code modification. Derived from past code review findings and inspection fixes.

---

## 1. Past Mistakes & Root Causes (What Went Wrong & Why)

| # | Mistake / Anti-Pattern | Why It Was Wrong | What Was Fixed |
|---|------------------------|------------------|----------------|
| **1** | **File length exceeded 250 lines** (`bo2_time_spinner.dart` was 252 lines) | Violates hard rule in `AGENTS.md`. Large files hurt maintainability and increase AI context pollution. | Extracted `Bo2LaserDivider` and `Bo2WheelColumnLabels` to sibling file (`bo2_time_wheels.dart`). |
| **2** | **Silent exception swallowing** (`catch (_) {}`) | Swallowing errors leaves DB failures completely silent. Developers and users cannot tell why forms stay blank or unpopulated. | Added `debugPrint('[Class] method error: $e\n$stack')` and safe fallback states (`setState(() => _isLoading = false)`). |
| **3** | **Unprotected async calls** (Missing try/catch in `_loadDraftCustomerData` & `_saveToDatabase`) | An unexpected SQLite lock or migration glitch causes unhandled async crashes or silent autosave drops. | Wrapped both load and autosave routines in robust `try/catch` blocks. |
| **4** | **`PageStorage` read loop in `didChangeDependencies`** (`BentoMainSection` / `BentoSubSection`) | `didChangeDependencies` runs multiple times (theme/keyboard/orientation changes). It repeatedly overwrote user's active expand/collapse toggle. | Guarded with `_hasRestoredState` boolean flag to ensure state restores only once on mount. |
| **5** | **Hardcoded UI strings** (inline tab titles instead of `AppDictionary`) | Violates centralization rule. Changes to Dutch labels in `AppDictionary` wouldn't reflect on the tab bar. | Replaced inline static list with `AppDictionary.combustionTabs`. |
| **6** | **Theme / Component token mismatch** (`hintStyle` 14px in theme vs 15px in `DarkInputBox`) | Inconsistent typography sizes cause jarring visual baseline and scale shifts across inputs. | Aligned `hintStyle` `fontSize: 15` in `app_theme.dart` with `DarkInputBox`. |
| **7** | **Font styling hacks** (using arbitrary `height: 1.25` multipliers) | Caused uneven vertical alignment and visual rendering bugs with the Libron font. | Removed custom `height` multipliers; unified on standard `DarkInputBox.inputStyle`. |
| **8** | **Missing DB migration stub** (no `onUpgrade` in `AppDatabase`) | App would have trouble upgrading SQLite schemas for upcoming slices (e.g. `stooktoestel`). | Added an `onUpgrade` stub and migration instructions. |

---

## 2. Post-Implementation Checklist (Run After EVERY Slice)

Run through this 7-point checklist before marking any slice complete or handing off to the owner:

### [ ] 1. File Length Limit (Max 250 Lines)
- [ ] No Dart file in `lib/` exceeds **250 lines**.
- [ ] Large widgets are split into small, private `StatelessWidget` classes or modular sibling files.
- **PowerShell check command:**
  ```powershell
  Get-ChildItem -Path "lib" -Recurse -Filter "*.dart" | ForEach-Object { $c = (Get-Content $_.FullName).Count; if ($c -gt 240) { Write-Host "$c lines: $($_.FullName)" } }
  ```

### [ ] 2. Zero Silent Error Swallowing
- [ ] No empty `catch (_)` blocks anywhere.
- [ ] All database queries, draft loaders, and async disk saves have `try/catch`.
- [ ] Unexpected exceptions are logged via `debugPrint('[ClassName] method error: $e\n$stack')`.
- [ ] In UI `catch` blocks, ensure `if (mounted) setState(() => _isLoading = false);` is called so the screen never hangs on a permanent spinner.

### [ ] 3. Flutter Lifecycle & PageStorage Safety
- [ ] If restoring scroll/expansion state in `didChangeDependencies`, guard it with `_hasRestoredState` so it only executes once.
- [ ] Keep heavy logic, database queries, and PDF generation out of `build()` methods.
- [ ] Cancel all active `Timer?` debounce instances in `dispose()`.
- [ ] Dispose all `TextEditingController` and `ScrollController` instances in `dispose()`.

### [ ] 4. Dutch UI Text Centralization (`AppDictionary`)
- [ ] All user-visible labels, headers, hints, buttons, and dialogs are in Dutch (Flemish).
- [ ] All UI strings are defined in `lib/app/localization/app_dictionary.dart`.
- [ ] No hardcoded string literals inside widget trees (e.g., `'Opslaan'`, `'Annuleren'`, tab names).
- [ ] English is strictly reserved for code names, variable names, functions, and `///` comments.

### [ ] 5. Single Reusable Input Styling (No Hacks)
- [ ] All text inputs use `DarkInputBox.inputStyle` (`fontSize: 15`, Libron, pure text color).
- [ ] All text inputs use `DarkInputBox.decoration(...)` for borders, fills, and hint styles.
- [ ] Never apply custom `height: 1.xx` hacks to `TextStyle` in input boxes.
- [ ] Set proper `keyboardType` (text vs numeric/phone) and `textInputAction` (`next` vs `done`).
- [ ] Form screens wrapped in `GestureDetector(onTap: () => FocusScope.of(context).unfocus())`.

### [ ] 6. Offline-First Draft Safety & Debouncing
- [ ] Edits debounce (300ms–500ms) before writing to SQLite to prevent UI lag.
- [ ] Form state persists across tab switches (`AutomaticKeepAliveClientMixin` + SQLite auto-save).
- [ ] Profile (technician/company) data is strictly separated from visit-specific draft data.

### [ ] 7. Verification & Tests
- [ ] Run static analysis:
  ```powershell
  & "C:\Users\Admin\Documents\Flutter-SDK\flutter\bin\flutter.bat" analyze --no-pub
  ```
  *(Must exit with 0 errors, 0 warnings).*
- [ ] Run test suite:
  ```powershell
  & "C:\Users\Admin\Documents\Flutter-SDK\flutter\bin\flutter.bat" test --no-pub
  ```
  *(All tests must pass).*
- [ ] Commit cleanly with descriptive message and update `ROADMAP.md` handoff.
- [ ] **Strict Stop-and-Wait Policy:** Wait for the owner's verification and explicit go-ahead before touching the next slice.

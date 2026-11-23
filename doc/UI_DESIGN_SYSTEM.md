# HVAC UI Design System & Component Guidelines (hvac_V0.3)

> **Context Notice:** Consult this document **only when designing, creating, or modifying UI screens, form inputs, dialogs, or tactical components**. For general coding standards, consult `IMPLEMENTATION_CHECKLIST.md` and `AGENTS.md`.

---

## 1. Typography, Input Tokens & Fonts

### Typography & Input Token Consistency
* All text inputs must use `DarkInputBox.inputStyle` (`fontSize: 15`, Libron font family, pure text color `AppColors.textPrimary`).
* All text inputs must use `DarkInputBox.decoration(...)` for consistent borders, fills, and hint styles.
* Input hint text style must match theme tokens (`fontSize: 15`, `AppColors.textMuted`).

### Zero Font Styling Hacks
* **Never** apply custom `height: 1.xx` multiplier hacks to `TextStyle` in input boxes or labels.
* Let the Libron font use standard baseline metrics to prevent cross-device rendering glitches and baseline jumps.

---

## 2. Layout, Rhythm & Bento Grid Metrics

### Bento Rhythm & Spacing
* Every tab view list must use `padding: AppTheme.tabViewPadding` (12px top offset under AppBar, 16px horizontal margin, 32px bottom breathing room).
* Every gap between consecutive Bento cards must use `const SizedBox(height: AppTheme.bentoCardSpacing)` (14px).
* Never use arbitrary inline padding or random heights between Bento cards; keeping tokens centralized prevents vertical jumping when switching tabs.

### Standard Workflow Tab Container (Responsive 600px)
* Every workflow tab's scrollable body must use `WorkflowTabContainer(scrollKey: '...')`.
* Never write manual `Center → ConstrainedBox(maxWidth: 600) → ListView` boilerplate in tab body files. `WorkflowTabContainer` ensures uniform max-width centering on tablets and desktop while remaining full-width on mobile.

---

## 3. Focus, Keyboard & Gestures

### Global Focus & Keyboard Dismissal
* Global tap-to-dismiss is handled via the root `MaterialApp.builder` with an opaque `GestureDetector`.
* Unfocus explicitly whenever navigation drawers open.
* Always set `ScrollViewKeyboardDismissBehavior.onDrag` on scrollable form lists (avoid per-field or per-screen redundant unfocus hacks).

---

## 4. Reusable Tactical Components

### Centralized Tactical Feedback (Toasts / SnackBars)
* Every transient user notification must use `TacticalFeedback.showSuccess(...)`, `TacticalFeedback.showInfo(...)`, or `TacticalFeedback.showError(...)`.
* Never hand-roll custom `SnackBar`s or raw `ScaffoldMessenger.of(context).showSnackBar` with inline styling.

### Reusable Tactical Square Buttons
* Every small (38–40px) square icon-only action button (e.g., QR scan, barcode scanner, delete, search) must use `TacticalSquareButton`.
* Never build inline `Container → BoxDecoration → Icon` buttons with ad-hoc borders and paddings.

---

## 5. Form Inputs, Validation & Choice Groups

### Unified Form Input Validation & Controller Sync
* All text form inputs must use `DarkTextFormField` (or `DarkTextField`), which encapsulates `DarkInputLabel` and zero-layout-shift error borders.
* Every form field must maintain real-time listener synchronization between `TextEditingController` and `FormFieldState` (`controller.addListener`) so simulated values, QR scans, and cleared inputs immediately update error borders and validators.

### Unified Choice Group Validation (`TacticalGroupOutline`)
* Multi-choice button pairs or binary toggles (e.g. Tab "Start" activity buttons, Tab "Meting" binary checks) must enclose the entire button row/group inside a single `TacticalGroupOutline`.
* Individual buttons within the group should maintain their resting border, while `TacticalGroupOutline(hasError: ...)` highlights the entire group with a single zero-layout-shift `AppColors.errorRed` border on validation error.

---

## 6. Progressive Disclosure & Exceptions

### Foolproof Signature Exception UX (Progressive Disclosure & Mutual Exclusivity)
* Customer signature blocks must hide exception actions (refusal, absence) when a valid signature is present to prevent contradictory states.
* When unsigned, administrative exception controls must be tucked behind a discreet progressive disclosure trigger ("Klant kan niet ondertekenen? ▾") rather than displayed prominently to customers.

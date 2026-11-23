# Universal Flutter Architecture & Quality Checklist

> **Purpose:** Lean, universal quality checklist for Flutter application slices. Consult **Section 0** before writing code, adhere to **Section 1** during implementation, and execute **Section 2** before handoff. For archived past bug analyses, see `doc/LESSONS_LEARNED.md`. For UI tokens and component rules, see `doc/UI_DESIGN_SYSTEM.md`.

---

## Section 0 — Pre-Code Check (30 Seconds Before Coding)

Answer these 3 questions in your slice plan before touching application code:
1. **Negative States:** What happens when each toggle or prerequisite is OFF, empty, null, or offline?
2. **Lowest Data Boundary:** Which layer (DTO mapper, repository, or database schema) enforces the domain invariant even if the UI layer is bypassed?
3. **Scope & Files:** What is the single user-visible outcome and exact files to touch?

---

## Section 1 — 12 Universal Flutter Architecture Rules

1. **File Size & Single Responsibility ($\le 250$ lines):** Every Dart file in `lib/` and `test/` must stay $\le 250$ lines. Extract focused child widgets, models, or services rather than overloading existing classes.
2. **Dedicated Widgets Over `_buildX()` Helpers:** Never return widgets from private helper methods. Extract private `StatelessWidget` classes with `const` constructors to preserve widget element caching.
3. **Centralized Strings & Design Tokens:** Zero raw user-facing string literals in widget trees; centralize in localized dictionaries. Centralize colors, padding, and typography in theme tokens.
4. **Conditional Field Gating (UI + State + Payload):**
   - *UI:* Conditionally render child inputs with collection `if` (`if (hasParent && isEnabled) ...[...]`). Never leave orphaned controls visible.
   - *State/Controller:* Hiding a widget does NOT clear its `TextEditingController`. Explicitly call `controller.clear()` and dismiss the keyboard (`FocusScope.of(context).unfocus()`) on toggle-off, **unless** product specifications explicitly require draft retention across accidental toggles.
   - *Payload/DTO:* Prune dependent fields in mappers/builders (`child: (hasParent && isEnabled) ? child : null`). Never trust the UI alone to protect persisted or external state.
5. **Nullable `copyWith` Sentinel Pattern:** Domain models with nullable fields must declare `static const Object _sentinel = Object();` and check `identical(field, _sentinel) ? this.field : field as Type?` so passing `null` saves `NULL` instead of silently reverting.
6. **Dynamic Collections & Dropdown Keying:** Key dynamic/async dropdowns with `key: ValueKey(...)` and implement `operator ==` and `hashCode` on item models to prevent Flutter dropdown value inconsistency crashes.
7. **Upstream Validation & Idempotent Normalization:** Enforce strict field formats before persisting/freezing. Strip visual prefixes before prepending to make formatters idempotent.
8. **Strict Disposal, Single Debouncer Flush & `mounted` Guards:** Dispose all controllers, focus nodes, and timers in `dispose()`. If a debouncer flushes on dispose, never fire an unawaited secondary save. Guard all `setState` calls after an `await` with `if (!mounted) return;`.
9. **One-Shot Lifecycle Restores & Gesture-Safe I/O:** Guard `didChangeDependencies` restores with a boolean flag. Inject active entity IDs synchronously on Frame 1; never fire background queries during gestures or animations.
10. **Explicit Error Handling & Resource Cleanup:** Zero empty `catch (_) {}` blocks. Log errors with class context and reset loading spinners. Wrap `HttpClient`, sockets, and stream subscriptions in `try ... finally` with `.timeout()`.
11. **Safe Storage Migrations & Cross-Store Integrity:** Implement non-destructive `onUpgrade` migrations. When coordinating state across two distinct stores (e.g. SQLite + secure storage), never assume atomic transactions: use staged states and deterministic startup recovery.
12. **Offline-First & Preflight Safety:** Keep local creation, editing, and archiving independent of remote API availability. Run lightweight preflight checks before claiming outbox jobs so offline states remain cleanly queued without false failure counts.

---

## Section 2 — Mandatory 3-Tier Pre-Handoff Quality Gate

Run all three tiers before declaring any slice complete or asking for review.

### Tier 1: Automated Quality Gate
Execute the project gate command (`.\tool\check_gates.ps1`). It must exit with code 0:
- Gate 1A: Code formatting clean (`dart format`).
- Gate 1B: Static analysis clean with zero errors, warnings, or lints (`flutter analyze`).
- Gate 1C: Strict file length verification ($\le 250$ lines across all files in `lib/` and `test/`).
- Gate 1D: Mechanical anti-pattern & whitespace checks clean (zero git whitespace errors or banned patterns).
- Full automated test suite passes 100%.

### Tier 2: Adversarial Self-Audit on `git diff` (Mandatory Before Handoff)
Switch from builder mode to bug-hunter mode before submitting work:
1. **Toggle-Off & Missing-Prerequisite Sweep:** Mentally turn every toggle OFF and remove every optional entity (no recipient, no address, empty input, offline). Verify that no child control, memory buffer, or message leaks into UI, storage, or outbound payloads.
2. **Negative & Boundary Tests:** Every happy-path test requires a corresponding negative test proving gated-off or malformed inputs are hidden (`findsNothing`), rejected, and pruned from payloads.
3. **Roundtrip Trace:** Trace `UI Input -> Controller -> Model -> Repository -> Storage -> Reopen -> UI` (including clearing inputs to `null`).
4. **Lifecycle & Leak Check:** Inspect `git diff` for controller disposal, `if (!mounted)` guards, `try ... finally` cleanup, and Sentinel pattern usage.

### Tier 3: Owner Device Verification & Stop-and-Wait
1. Provide 3–4 concrete, human-testable steps on an emulator or physical device, including at least one negative or edge-case step.
2. **Strict Stop-and-Wait Policy:** Wait for the owner's explicit confirmation on device before moving to the next slice or making Git commits.

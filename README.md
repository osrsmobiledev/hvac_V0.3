# HVAC Maintenance App (`hvac_V0.3`)

An offline-first, adaptive (Phone & Tablet) Flutter application for Flemish HVAC technicians, featuring a **BO2 Tactical HUD / Dark Luxury Industrial** aesthetic.

Currently focused on the **Digitaal Verbrandingsattest** applet, hosted inside a multi-applet launcher shell with persistent navigation, local SQLite draft persistence, camera barcode/QR scanning, A4 PDF generation, and independent VEKA reporting tracking.

---

## Workspace Map (Read Selectively)

To prevent context window bloat, AI coding agents must follow the selective reading rules in `AGENTS.md`:

| File / Folder | Purpose & When to Read |
| :--- | :--- |
| **`AGENTS.md`** | **Master AI Rules.** Collaboration rules, strict one-slice-at-a-time policy, official Flutter 2-layer coding standards, adaptive layout rules, and core product invariants. |
| **`ROADMAP.md`** | **Active Slice Tracker.** Always read first. Contains the step-by-step build slices and the **Current Handoff** status at the bottom. |
| **`ARCHITECTURE.md`** | **Technical Blueprint.** Locked packages (`sqflite`, `mobile_scanner`, `pdf`, `printing`), folder layout, SQLite tables, state machines, and the re-wiring checklist for legacy components. |
| **`PROJECT_BRIEF.md`** | **Product Requirements.** High-level goals, legacy app pain points to avoid, and workflow separation rules. Read relevant sections when implementing features. |
| **`VERBRANDINGSATTEST_WORKFLOW.md`** | **Tab & Field Reference.** Detailed tab-by-tab breakdown (`Start` through `Voltooien`), Basisregisters lookup, Eurolyzer QR slots, and official VEKA API validation rules. Read only the section matching the active slice. |
| **`references/legacy/code/`** | **Visual Reference Components (Do Not Run Directly).** Contains the working legacy PDF builders, 24h time spinner (`bo2_time_spinner.dart`), theme colors, and Dutch dictionary to be adapted per `ARCHITECTURE.md`. |
| **`references/legacy/screenshots/`** | Screenshots of the legacy app for field reference. |
| **`references/official/`** | Official Flemish VEKA API documentation, Swagger YAML, and blank government PDF template. |

---

## How to Start a Session in Antigravity

Copy and paste this prompt into Antigravity to start or resume work:

```text
Read `AGENTS.md` and `ROADMAP.md` first. Do not read the other documentation files unless needed for the active slice.
Check the "Current Handoff" section at the bottom of `ROADMAP.md`, state the plan for the active slice (files to touch and what I will see on screen), and implement only that single slice. Stop and wait for my verification before moving to the next slice.```

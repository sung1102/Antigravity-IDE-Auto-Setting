# Change Log - Antigravity-IDE-Auto-Setting

All notable changes to the Antigravity Global Engineering Review Rules and Skills repository will be documented in this file.
This file is strictly **APPEND ONLY**. Never reorder, delete, or rewrite historical entries.

---

## [2026-10-21] Initial Release - Global Engineering Review Rules & Skills
- **Type**: Initial Setup
- **Base Commit**: `0f8f902`
- **Details**:
  - Initialized global engineering governance rule (`rules/engineering-governance.md`).
  - Implemented 5 engineering review skills: `engineering-review-orchestrator`, `software-architecture-review`, `rtl-hardware-review`, `protocol-stack-contract-review`, and `change-safety-and-verification`.
  - Added template checklists and report templates in `skills/*/resources/`.
  - Added cross-machine setup guide in `README.md`.
  - Bound and pushed repository to `https://github.com/sung1102/Antigravity-IDE-Auto-Setting.git`.

---

## [2026-10-21] Add Generic Project Onboarding Prompts Manual
- **Type**: Feature
- **Base Commit**: `d2c70d1`
- **Details**:
  - Added `templates/project-onboarding-prompts.md` containing generic prompt templates for Scenarios 1 (Brand-New), 2 (Legacy Onboarding), and 3 (Governance Upgrade).
  - Updated `README.md` to index the `templates/` directory and usage guide.

---

## [2026-10-21] Enforce Git-Only Backup Policy (Eliminate Physical Duplication)
- **Type**: Bugfix / Policy Alignment
- **Base Commit**: `6743b46`
- **Details**:
  - Updated `engineering-governance.md` Rule 3 to strictly enforce Git branch/tag backups and eliminate physical folder copies when Git is available.
  - Refactored `change-safety-and-verification/SKILL.md` to establish Git-only rollback procedures.
  - Updated `project-onboarding-prompts.md` Scenario 2 to use Git Baseline instead of local physical folder copies.
  - Updated `README.md` to declare the Git-only backup policy.

---

## [2026-10-21] Explicitly Include Change_Log.md in Legacy Onboarding Workflow
- **Type**: Bugfix / Template Enhancement
- **Base Commit**: `f0026e7`
- **Details**:
  - Updated `project-onboarding-prompts.md` Scenario 2 steps 4 and 5 to explicitly mandate creating or appending to `Change_Log.md` and generating `VerificationCoverageMatrix.md`.

---

## [2026-10-21] Align Repository with Project Governance Baseline (Scenario 3 Upgrade)
- **Type**: Governance Alignment
- **Base Commit**: `f0026e7`
- **Details**:
  - Created safety backup tag `backup/pre-governance-upgrade-20261021153717`.
  - Added `GEMINI.md` project memory index to anchor architectural navigation and governance rules.
  - Added `Change_Log.md` complying strictly with APPEND-ONLY rules.
  - Added `VerificationCoverageMatrix.md` tracking repository validation and linting items.
  - Verified 1-to-1 repository name mapping: `Antigravity-IDE-Auto-Setting`.

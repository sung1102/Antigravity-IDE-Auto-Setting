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


---

## [2026-11-25] Add Observed Baseline Replication & SSOT Retroactive Sync Skill
- **Type**: Feature / Governance Enhancement
- **Base Commit**: `48ea74d`
- **Details**:
  - Added new global skill `skills/observed-baseline-and-ssot-sync/SKILL.md` with `resources/baseline-ssot-checklist.md` and `resources/suspicious-behavior-report-template.md`.
  - Enforced Replicate-First discipline for LA/oscilloscope/packet captures: replicate observed behavior 100% before outer-layer adaptation; prohibit unauthorized addition/removal of control steps; mandate `PLAN_ONLY` suspicious-behavior reporting before altering observed sequences.
  - Enforced Truth Priority Hierarchy (Tier 1 > Tier 2 > Tier 3) and mandatory Retroactive Sweep on confirmation to update or deprecate stale docs, configs, and duplicate snapshots.
  - Integrated references into `rules/engineering-governance.md`, `engineering-review-orchestrator`, `protocol-stack-contract-review`, `change-safety-and-verification`, `templates/project-onboarding-prompts.md`, `GEMINI.md`, and `README.md`.


---

## [2026-11-25] Add Repo Self-Verification Lever & Verification Harness Builder Skill
- **Type**: Feature / Verification & Guardrail Enhancement
- **Base Commit**: `b5f2db6`
- **Details**:
  - Synced workspace and GitVault mirror from `48ea74d` to `b5f2db6` (`observed-baseline-and-ssot-sync`) and created backup branch `backup/Antigravity-IDE-Auto-Setting_20261125_165735`.
  - Added deterministic self-verification script `scripts/verify-repo.ps1` checking rules frontmatter, skill directory/name alignment, relative resource links, markdown code fence pairing, `GEMINI.md`/`README.md` index synchronization, and `Change_Log.md` Append-Only integrity.
  - Added global skill `skills/verification-harness-builder/SKILL.md` with `resources/feature-map-template.md` and `resources/verify-skill-template.md` to establish project-level executable verification levers, behavior-level Feature Maps, Doc Drift vs Product Bug triage, and Prose-to-Guardrail error escalation.
  - Integrated references into `rules/engineering-governance.md`, `skills/engineering-review-orchestrator/SKILL.md`, `skills/change-safety-and-verification/SKILL.md`, `templates/project-onboarding-prompts.md`, `GEMINI.md`, and `README.md`.

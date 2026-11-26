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


---

## [2026-11-25] Enhance Orchestrator Collaboration, Change Hygiene, and Guardrail Snippets (Option B)
- **Type**: Enhancement / Process & Verification Hardening
- **Base Commit**: `d1cf786`
- **Details**:
  - Created Git safety backup branch `backup/Antigravity-IDE-Auto-Setting_20261125_183252`.
  - Upgraded `skills/engineering-review-orchestrator/SKILL.md` and `resources/change-plan-template.md` with Phase 1/3 Sharpen & In-Your-Own-Words alignment, Phase 2 parallel read-only `research` subagent tracing, and Phase 5 `browser` verification + Blind Verification guidance.
  - Upgraded `skills/change-safety-and-verification/SKILL.md` and `resources/verification-template.md` with Minimal Clean Diff & Unslop discipline, explicit separation of `Regression` vs `New Behavior Proof`, and `Guardrail Escalation` tracking.
  - Added `skills/verification-harness-builder/resources/guardrail-snippets.md` providing deterministic templates for Git `pre-commit`, C#/WPF (`Directory.Build.props`, `.editorconfig`), RTL (`verilator`, `iverilog`/`vvp`), and Python (`ruff`, `pytest`), and indexed it in `SKILL.md`, `GEMINI.md`, and `README.md`.


---

## [2026-11-25] Self-Dogfooding Alignment, README Drift Fix & Pre-Commit Gate
- **Type**: Dogfooding / SSOT Alignment & Guardrail Hardening
- **Base Commit**: `8f53ec7`
- **Details**:
  - Created Git safety backup branch `backup/Antigravity-IDE-Auto-Setting_20261125_184026`.
  - Applied `verification-harness-builder` to this repository itself by adding `docs/Feature_Map.md`, `.agents/skills/verify-Antigravity-IDE-Auto-Setting/SKILL.md`, and `.githooks/pre-commit`.
  - Fixed SSOT Doc Drift in `README.md` (updated Scenario 1–3 summary table from stale `01~03` to `01~04` + `Feature_Map.md` + `.agents/skills/verify-*`, updated directory tree, and documented `git config core.hooksPath .githooks`).
  - Upgraded `scripts/verify-repo.ps1` (7 checks) to validate `.agents/skills/*/SKILL.md` schema, self-dogfooding asset presence, SSOT index coverage, and block stale `01~03` drift in `README.md`.
  - Updated `GEMINI.md` Key Modules Map and `VerificationCoverageMatrix.md`.


---

## [2026-11-26] Full Repo Optimization (Report B P0-P2) & Architecture Workflow Guide
- **Type**: Optimization / Documentation & Guardrail Hardening
- **Base Commit**: `e8eb91e`
- **Details**:
  - Created Git safety backup branch `backup/Antigravity-IDE-Auto-Setting_20261126_100318`.
  - Added `.gitattributes` to enforce LF on `.sh`/`.githooks/*` and CRLF on `.ps1`/`.md`/`.json`/`.xml`/`.props`, eliminating cross-platform line-ending warnings.
  - Updated `templates/project-onboarding-prompts.md` and `skills/change-safety-and-verification/SKILL.md` with dual Windows PowerShell and Bash backup commands.
  - Added Antigravity native `.agents/hooks.json` lifecycle guardrail snippet to `skills/verification-harness-builder/resources/guardrail-snippets.md`.
  - Closed the guardrail loop across `software-architecture-review` (also fixed `INotifyPropertyChanged` typo), `rtl-hardware-review`, and `protocol-stack-contract-review`.
  - Added `docs/Architecture_and_Workflow.md` and README Section 2 overview diagram detailing the layered architecture, `MODE` transitions, Phases 1–5 closed loop, all 7+1 skills, and delta onboarding paths.
  - Standardized local verify skill name to lowercase-hyphenated `.agents/skills/verify-antigravity-ide-auto-setting/SKILL.md`, made `GEMINI.md` path portable (`%USERPROFILE%\.gemini\config`), and upgraded `scripts/verify-repo.ps1` to validate lowercase skill names, `docs/*.md` links, `.gitattributes`, and `Architecture_and_Workflow.md`.


---

## [2026-11-26] Add Non-Destructive Cross-PC Mount & V1-to-V2 Sync Tool
- **Type**: Feature / Cross-Machine Deployment & Custom-Skill Protection
- **Base Commit**: `40cb48c`
- **Details**:
  - Created Git safety backup branch `backup/Antigravity-IDE-Auto-Setting_20261126_103142`.
  - Added `scripts/sync-config.ps1` and `scripts/sync-config.sh` handling fresh installs, non-destructive in-place mounts (preserving `mcp_config.json`, `plugins/`, `projects/`, and user-built custom skills), and safe V1-to-V2 Git fast-forward upgrades (guarding local tracked edits with `-BackupOnLocalModify`).
  - Added `-TrackedOnly` switch to `scripts/verify-repo.ps1` so target machines with personal untracked skills pass verification cleanly, and added `sync-config.ps1`/`.sh` to SSOT index & Dogfooding checks.
  - Updated `README.md`, `GEMINI.md`, `docs/Feature_Map.md`, `docs/Architecture_and_Workflow.md`, and `templates/project-onboarding-prompts.md` (with Step 0 global-brain version pre-flight).


---

## [2026-11-26] Fix CP950/Big5 PowerShell UTF-8 Decoding Mismatch in Verify & Sync Scripts
- **Type**: Bugfix / Windows Codepage Encoding Hardening
- **Base Commit**: `6f95631`
- **Details**:
  - Created Git safety backup branch `backup/Antigravity-IDE-Auto-Setting_20261126_111432`.
  - Fixed false-positive failure in `scripts/verify-repo.ps1` Check 6 (`Historical line 103 modified`) triggered on Taiwanese Windows PowerShell (`CP950`/`Big5`) where `git show HEAD:Change_Log.md` UTF-8 output (containing `U+2013` en-dash on line 103) was decoded as CP950.
  - Added `Invoke-GitUtf8Text` (`System.Diagnostics.Process` with `StandardOutputEncoding = UTF8`) in `scripts/verify-repo.ps1` and set UTF-8 console/pipeline encoding guards in both `scripts/verify-repo.ps1` and `scripts/sync-config.ps1`.

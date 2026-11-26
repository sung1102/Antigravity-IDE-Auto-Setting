# Verification Coverage Matrix - Antigravity-IDE-Auto-Setting

This matrix records the verification state of rules, skills, templates, and documentation in this repository.
Real execution evidence only: `PASS` | `FAIL` | `BLOCKED` | `NOT RUN`.

| 驗證項目 / 模組 | 驗證層級 | 執行命令 / 驗證方式 | 狀態 | Exit Code | 證據摘要 |
|---|---|---|---|---|---|
| Rule YAML 語法檢驗 | Static Lint | `powershell -ExecutionPolicy Bypass -File .\scripts\verify-repo.ps1` | PASS | 0 | `1 rule file(s) valid`（`trigger: always_on` 語法正確，含 Rule 1~6） |
| 8 大全域 + 1 在地 Skill 結構 | Schema Check | `powershell -ExecutionPolicy Bypass -File .\scripts\verify-repo.ps1` | PASS | 0 | `8 global + 1 local skill(s) match folder names & schema (9 total)`（含 `weekly-project-review-and-roadmap`） |
| Resource 範本與跨技能相對路徑引用 | Link Integrity | `powershell -ExecutionPolicy Bypass -File .\scripts\verify-repo.ps1` | PASS | 0 | `89 relative reference(s) verified`（涵蓋 `GEMINI.md` / `README.md` / `docs/*.md` / `SKILL.md` / 技能內 `scripts/`） |
| 全倉庫 Markdown 程式碼圍欄配對 | Markdown Lint | `powershell -ExecutionPolicy Bypass -File .\scripts\verify-repo.ps1` | PASS | 0 | `30 markdown file(s) have balanced fences`（含週報模板與 `/automation` 指引） |
| SSOT 索引同步與 Change_Log Append-Only | Governance Gate | `powershell -ExecutionPolicy Bypass -File .\scripts\verify-repo.ps1` | PASS | 0 | `GEMINI.md`/`README.md` 涵蓋全部 8+1 技能、文件、`.gitattributes`、`pre-commit` 與 `sync-config`；143 行歷史保留（共 155 行） |
| 自我套用資產與 README 漂移攔截 | Dogfooding Gate | `powershell -ExecutionPolicy Bypass -File .\scripts\verify-repo.ps1` | PASS | 0 | `Feature_Map.md`、`Architecture_and_Workflow.md`、`.gitattributes`、`sync-config`、`.agents/skills/verify-*`、`.githooks/pre-commit` 均存在且無漂移 |
| CP950/Big5 主控台相容驗證 | Encoding Gate | 強制 `[Console]::OutputEncoding = GetEncoding(950)` 實跑 `verify-repo.ps1` | PASS | 0 | UTF-8 與強制 CP950 下一般模式及 `-TrackedOnly` 均為 `7/7 checks passed`（`CP950_RC=0`） |
| 跨機無損掛載與 V1→V2 升級測試 | Integration Test | `scripts/sync-config.ps1`（Case A/B/C1/C2 夾具實測） | PASS | 0 | 實測保留 `mcp_config.json`、`plugins/` 與自建技能；碰撞與修改檔先備份不硬蓋；`-TrackedOnly` 通過 |
| 週期唯讀快照腳本實測 (`.ps1` / `.sh`) | Script Test | 強制 `CP950` 跑 `collect-weekly-snapshot.ps1` & `sh -n` 驗 `.sh` | PASS | 0 | 快照輸出近 7 天提交、缺口與技術債（`SNAP_CP950_RC=0`）；`.sh` 語法檢驗通過 |
| 前次遠端基準確認與同步 (`2c4afa3`) | VCS Sync | `sync-config.ps1` & `git rev-parse HEAD` | PASS | 0 | 本機工作區、GitVault 與 `~/.gemini/config` 已於該輪對齊至 `2c4afa3` |
| 本次週報技能 Pre-Commit 與推送 | VCS / Hook Gate | `git commit`（觸發 `.githooks/pre-commit`）& `git push` | NOT RUN | - | 待本次變更 commit 時實測 Hook 攔截與執行推送，於回覆紀錄回報真實 Exit Code |
| 跨平台掛載腳本驗證 (PowerShell) | Integration Test | PowerShell 命令測試 `backup_$ts` 與 `git clone` 語法 | PASS | 0 | Windows PowerShell 腳本語法檢驗通過 |
| 跨平台掛載腳本驗證 (Bash) | Portability Test | Bash 腳本語法檢查 | NOT RUN | - | 本機為 Windows 環境，尚未於 Linux/macOS 環境實測 |

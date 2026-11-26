# Verification Coverage Matrix - Antigravity-IDE-Auto-Setting

This matrix records the verification state of rules, skills, templates, and documentation in this repository.
Real execution evidence only: `PASS` | `FAIL` | `BLOCKED` | `NOT RUN`.

| 驗證項目 / 模組 | 驗證層級 | 執行命令 / 驗證方式 | 狀態 | Exit Code | 證據摘要 |
|---|---|---|---|---|---|
| Rule YAML 語法檢驗 | Static Lint | `powershell -ExecutionPolicy Bypass -File .\scripts\verify-repo.ps1` | PASS | 0 | `1 rule file(s) valid`（`trigger: always_on` 語法正確，含 Rule 1~6） |
| 7 大全域 + 1 在地 Skill 結構 | Schema Check | `powershell -ExecutionPolicy Bypass -File .\scripts\verify-repo.ps1` | PASS | 0 | `7 global + 1 local skill(s) match folder names & schema (8 total)`（均符合小寫連字號規範） |
| Resource 範本與跨技能相對路徑引用 | Link Integrity | `powershell -ExecutionPolicy Bypass -File .\scripts\verify-repo.ps1` | PASS | 0 | `70 relative reference(s) verified`（涵蓋 `GEMINI.md` / `README.md` / `docs/*.md` / `SKILL.md`） |
| 全倉庫 Markdown 程式碼圍欄配對 | Markdown Lint | `powershell -ExecutionPolicy Bypass -File .\scripts\verify-repo.ps1` | PASS | 0 | `27 markdown file(s) have balanced fences`（含 `Architecture_and_Workflow.md` 與護欄範本） |
| SSOT 索引同步與 Change_Log Append-Only | Governance Gate | `powershell -ExecutionPolicy Bypass -File .\scripts\verify-repo.ps1` | PASS | 0 | `GEMINI.md`/`README.md` 涵蓋全部 7+1 技能、文件、`.gitattributes`、`pre-commit` 與 `sync-config`；120 行歷史保留（共 132 行） |
| 自我套用資產與 README 漂移攔截 | Dogfooding Gate | `powershell -ExecutionPolicy Bypass -File .\scripts\verify-repo.ps1` | PASS | 0 | `Feature_Map.md`、`Architecture_and_Workflow.md`、`.gitattributes`、`sync-config`、`.agents/skills/verify-*`、`.githooks/pre-commit` 均存在且無漂移 |
| 跨機無損掛載與 V1→V2 升級測試 | Integration Test | `scripts/sync-config.ps1`（Case A/B/C1/C2 夾具實測） | PASS | 0 | 實測保留 `mcp_config.json`、`plugins/` 與自建技能；碰撞與修改檔先備份不硬蓋；`-TrackedOnly` 通過 |
| 前次遠端基準確認與同步 (`40cb48c`) | VCS Sync | `git rev-parse HEAD` & GitVault 同步 | PASS | 0 | 工作區、GitVault 與 `~/.gemini/config` 均已對齊至 `40cb48c`（GitHub 推送需互動憑證） |
| 本次掛載工具 Pre-Commit 與推送 | VCS / Hook Gate | `git commit`（觸發 `.githooks/pre-commit`）& `git push` | NOT RUN | - | 待本次變更 commit 時實測 Hook 攔截與執行推送，於回覆紀錄回報真實 Exit Code |
| 跨平台掛載腳本驗證 (PowerShell) | Integration Test | PowerShell 命令測試 `backup_$ts` 與 `git clone` 語法 | PASS | 0 | Windows PowerShell 腳本語法檢驗通過 |
| 跨平台掛載腳本驗證 (Bash) | Portability Test | Bash 腳本語法檢查 | NOT RUN | - | 本機為 Windows 環境，尚未於 Linux/macOS 環境實測 |

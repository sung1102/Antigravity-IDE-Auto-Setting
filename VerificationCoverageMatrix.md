# Verification Coverage Matrix - Antigravity-IDE-Auto-Setting

This matrix records the verification state of rules, skills, templates, and documentation in this repository.
Real execution evidence only: `PASS` | `FAIL` | `BLOCKED` | `NOT RUN`.

| 驗證項目 / 模組 | 驗證層級 | 執行命令 / 驗證方式 | 狀態 | Exit Code | 證據摘要 |
|---|---|---|---|---|---|
| Rule YAML 語法檢驗 | Static Lint | `powershell -ExecutionPolicy Bypass -File .\scripts\verify-repo.ps1` | PASS | 0 | `1 rule file(s) valid`（`trigger: always_on` 語法正確，含 Rule 1~6） |
| 7 大全域 + 1 在地 Skill 結構 | Schema Check | `powershell -ExecutionPolicy Bypass -File .\scripts\verify-repo.ps1` | PASS | 0 | `7 global + 1 local skill(s) match folder names & schema (8 total)`（均符合小寫連字號規範） |
| Resource 範本與跨技能相對路徑引用 | Link Integrity | `powershell -ExecutionPolicy Bypass -File .\scripts\verify-repo.ps1` | PASS | 0 | `62 relative reference(s) verified`（涵蓋 `GEMINI.md` / `README.md` / `docs/*.md` / `SKILL.md`） |
| 全倉庫 Markdown 程式碼圍欄配對 | Markdown Lint | `powershell -ExecutionPolicy Bypass -File .\scripts\verify-repo.ps1` | PASS | 0 | `27 markdown file(s) have balanced fences`（含 `Architecture_and_Workflow.md` 與護欄範本） |
| SSOT 索引同步與 Change_Log Append-Only | Governance Gate | `powershell -ExecutionPolicy Bypass -File .\scripts\verify-repo.ps1` | PASS | 0 | `GEMINI.md`/`README.md` 涵蓋全部 7+1 技能、文件、`.gitattributes` 與 `pre-commit`；105 行歷史保留（共 120 行） |
| 自我套用資產與 README 漂移攔截 | Dogfooding Gate | `powershell -ExecutionPolicy Bypass -File .\scripts\verify-repo.ps1` | PASS | 0 | `Feature_Map.md`、`Architecture_and_Workflow.md`、`.gitattributes`、`.agents/skills/verify-*`、`.githooks/pre-commit` 均存在且無 `01~03` 漂移 |
| 前次遠端基準確認與同步 (`e8eb91e`) | VCS Sync | `git ls-remote origin` / `git status -sb` | PASS | 0 | GitHub `main`、GitVault 與 `~/.gemini/config` 已確認對齊至 `e8eb91e` |
| 本次全面優化 Pre-Commit 與推送 | VCS / Hook Gate | `git commit`（觸發 `.githooks/pre-commit`）& `git push` | NOT RUN | - | 待本次變更 commit 時實測 Hook 攔截與執行推送，於回覆紀錄回報真實 Exit Code |
| 跨平台掛載腳本驗證 (PowerShell) | Integration Test | PowerShell 命令測試 `backup_$ts` 與 `git clone` 語法 | PASS | 0 | Windows PowerShell 腳本語法檢驗通過 |
| 跨平台掛載腳本驗證 (Bash) | Portability Test | Bash 腳本語法檢查 | NOT RUN | - | 本機為 Windows 環境，尚未於 Linux/macOS 環境實測 |

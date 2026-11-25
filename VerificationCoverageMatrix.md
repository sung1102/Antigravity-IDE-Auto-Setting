# Verification Coverage Matrix - Antigravity-IDE-Auto-Setting

This matrix records the verification state of rules, skills, templates, and documentation in this repository.
Real execution evidence only: `PASS` | `FAIL` | `BLOCKED` | `NOT RUN`.

| 驗證項目 / 模組 | 驗證層級 | 執行命令 / 驗證方式 | 狀態 | Exit Code | 證據摘要 |
|---|---|---|---|---|---|
| Rule YAML 語法檢驗 | Static Lint | `powershell -ExecutionPolicy Bypass -File .\scripts\verify-repo.ps1` | PASS | 0 | `1 rule file(s) valid`（`trigger: always_on` 語法正確，含 Rule 1~6） |
| 7 大 Skill 目錄結構與 frontmatter | Schema Check | `powershell -ExecutionPolicy Bypass -File .\scripts\verify-repo.ps1` | PASS | 0 | `7 skill(s) match folder names & schema`（含 `verification-harness-builder`） |
| Resource 範本與跨技能相對路徑引用 | Link Integrity | `powershell -ExecutionPolicy Bypass -File .\scripts\verify-repo.ps1` | PASS | 0 | `36 relative reference(s) verified`（涵蓋 `GEMINI.md` / `README.md` / `SKILL.md`） |
| 全倉庫 Markdown 程式碼圍欄配對 | Markdown Lint | `powershell -ExecutionPolicy Bypass -File .\scripts\verify-repo.ps1` | PASS | 0 | `23 markdown file(s) have balanced fences`（含三大情境 `XXXX` 範本） |
| SSOT 索引同步與 Change_Log Append-Only | Governance Gate | `powershell -ExecutionPolicy Bypass -File .\scripts\verify-repo.ps1` | PASS | 0 | `GEMINI.md`/`README.md` 涵蓋全部 7 技能與 `verify-repo.ps1`；68 行歷史記錄完整保留（總計 80 行） |
| 既有遠端基準確認與同步 (`b5f2db6`) | VCS Sync | `git ls-remote origin` / `git pull --ff-only` | PASS | 0 | GitHub `main` 已確認為 `b5f2db6`；GitVault mirror 與工作區已同步對齊 |
| 本次新變更遠端推送與本機同步 | VCS Integration | `git push` & `git pull --ff-only` | NOT RUN | - | 待本次變更 commit 後執行推送，並於本次回覆之變更紀錄回報真實 Exit Code |
| 跨平台掛載腳本驗證 (PowerShell) | Integration Test | PowerShell 命令測試 `backup_$ts` 與 `git clone` 語法 | PASS | 0 | Windows PowerShell 腳本語法檢驗通過 |
| 跨平台掛載腳本驗證 (Bash) | Portability Test | Bash 腳本語法檢查 | NOT RUN | - | 本機為 Windows 環境，尚未於 Linux/macOS 環境實測 |

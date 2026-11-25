# Verification Coverage Matrix - Antigravity-IDE-Auto-Setting

This matrix records the verification state of rules, skills, templates, and documentation in this repository.
Real execution evidence only: `PASS` | `FAIL` | `BLOCKED` | `NOT RUN`.

| 驗證項目 / 模組 | 驗證層級 | 執行命令 / 驗證方式 | 狀態 | Exit Code | 證據摘要 |
|---|---|---|---|---|---|
| Rule YAML 語法檢驗 | Static Lint | PowerShell YAML frontmatter 解析 | PASS | 0 | `trigger: always_on` 語法正確，Rule 1~6 完整 |
| 6 大 Skill 目錄結構與 frontmatter | Schema Check | PowerShell 遍歷 `skills/*/SKILL.md` | PASS | 0 | 6 個 Skill 資料夾與 `name` 100% 一致 |
| Resource 範本與檢核清單引用 | Link Integrity | PowerShell 檢查 `SKILL.md` 相對路徑引用 | PASS | 0 | 所有 `resources/` 及跨技能相對路徑均存在且有效 |
| 專案導入手冊 (Templates) 語法 | Markdown Lint | PowerShell 檢查 `templates/*.md` 程式碼圍欄配對 | PASS | 0 | 6 個圍欄成對平衡，包含三大情境 `XXXX` 填空提示詞 |
| Git 遠端推送與追蹤 | VCS Integration | `git push origin main` | NOT RUN | - | 依使用者要求，待確認差異後再執行 commit 與 push |
| 跨平台掛載腳本驗證 (PowerShell) | Integration Test | PowerShell 命令測試 `backup_$ts` 與 `git clone` 語法 | PASS | 0 | Windows PowerShell 腳本語法檢驗通過 |
| 跨平台掛載腳本驗證 (Bash) | Portability Test | Bash 腳本語法檢查 | NOT RUN | - | 本機為 Windows 環境，尚未於 Linux/macOS 環境實測 |

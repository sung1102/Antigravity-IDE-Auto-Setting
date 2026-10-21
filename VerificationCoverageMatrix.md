# Verification Coverage Matrix - Antigravity-IDE-Auto-Setting

This matrix records the verification state of rules, skills, templates, and documentation in this repository.
Real execution evidence only: `PASS` | `FAIL` | `BLOCKED` | `NOT RUN`.

| 驗證項目 / 模組 | 驗證層級 | 執行命令 / 驗證方式 | 狀態 | Exit Code | 證據摘要 |
|---|---|---|---|---|---|
| Rule YAML 語法檢驗 | Static Lint | PowerShell YAML frontmatter 解析 | PASS | 0 | `trigger: always_on` 語法正確，已於 Antigravity 載入生效 |
| 5 大 Skill 目錄結構與 frontmatter | Schema Check | PowerShell 遍歷 `skills/*/SKILL.md` | PASS | 0 | 5 個 Skill 資料夾與 name 100% 一致 |
| Resource 範本與檢核清單引用 | Link Integrity | 檢查 `SKILL.md` 相對路徑引用 | PASS | 0 | 所有 `resources/` 檔案均存在且路徑正確 |
| 專案導入手冊 (Templates) 語法 | Markdown Lint | 檢查 `templates/*.md` 程式區塊與格式 | PASS | 0 | 格式正確，包含三大情境 `XXXX` 填空提示詞 |
| Git 遠端推送與追蹤 | VCS Integration | `git push origin main` | PASS | 0 | 遠端倉庫 `https://github.com/sung1102/Antigravity-IDE-Auto-Setting.git` 分支 `main` 追蹤一致 |
| 跨平台掛載腳本驗證 (PowerShell) | Integration Test | PowerShell 命令測試 `backup_$ts` 與 `git clone` 語法 | PASS | 0 | Windows PowerShell 腳本語法檢驗通過 |
| 跨平台掛載腳本驗證 (Bash) | Portability Test | Bash 腳本語法檢查 | NOT RUN | - | 本機為 Windows 環境，尚未於 Linux/macOS 環境實測 |

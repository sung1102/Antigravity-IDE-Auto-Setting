# Feature & Verification Map - Antigravity-IDE-Auto-Setting
> 本文件為 `Antigravity-IDE-Auto-Setting` 自我套用 `verification-harness-builder` 規範之行為級功能與驗證地圖。
> 若與本倉庫實際檔案（Tier 1）衝突，以實碼與實跑結果為準，並嚴格區分 **Doc Drift** 與 **Product Bug**。

## 1. 專案驗證快速入口 (Quick Verification Entry)
- **專案關鍵名稱 (Project Key Name)**：`Antigravity-IDE-Auto-Setting`
- **一鍵自動化驗證槓桿 (Verify Lever)**：`powershell -ExecutionPolicy Bypass -File .\scripts\verify-repo.ps1`
- **專案專屬驗證技能**：`.agents/skills/verify-antigravity-ide-auto-setting/SKILL.md`
- **Git 提交自動攔截門檻**：`.githooks/pre-commit`（透過 `git config core.hooksPath .githooks` 啟用，並由 `.gitattributes` 鎖定 LF 行尾）
- **外部環境依賴**：Windows PowerShell 5.1+ / PowerShell 7+（Linux/macOS Bash 掛載檢查與需互動憑證之 GitHub 推送除外）。

---

## 2. 功能行為與驗證對照表 (Feature Map)

| Feature ID | 功能名稱 | 觸發入口 (檔案 / 規則 / 腳本) | 驗證槓桿與操作步驟 (How to Drive) | 預期可觀察硬證據 (Expected Proof) | 已知地雷 / 保護契約 (Pitfalls & Invariants) |
|---|---|---|---|---|---|
| `F-01` | 全域長駐工程治理規則 | `rules/engineering-governance.md` | 執行 `verify-repo.ps1` Check 1 (`Rules Frontmatter`) | `[PASS] Rules Frontmatter`（含 `trigger: always_on` 與 `description`） | 不得過度膨脹常駐提示詞；需維持 `MODE:` 強制標記與 Git-only 回滾鐵則 |
| `F-02` | 7 大全域工程技能與模板路由 | `skills/*/SKILL.md` 及 `resources/*.md` | 執行 `verify-repo.ps1` Check 2 & 3 (`Skills Schema` / `Link Integrity`) | 所有技能資料夾名與 frontmatter `name` 一致，且所有相對路徑存在 | 不可變更既有技能 `name` 而不更新 `GEMINI.md`/`README.md` 與呼叫引用 |
| `F-03` | 三大情境專案導入手冊 | `templates/project-onboarding-prompts.md` | 執行 `verify-repo.ps1` Check 4 (`Markdown Fences`) & Check 7 | 圍欄成對平衡；`README.md` 摘要與三大情境內容一致（無 `01~03` 殘留漂移） | 保留所有 `XXXX` 佔位符與既有情境流程，不破壞使用者習慣 |
| `F-04` | 倉庫靜態校驗槓桿與負向攔截 | `scripts/verify-repo.ps1` | 正向跑本倉；負向以 `-SkipGitAppendCheck` 跑毀損夾具 | 正向 Exit Code `0`；負向偵測錯名/斷鏈/圍欄失衡/漂移並回傳 Exit Code `1` | 必須相容 Windows PowerShell 5.1（勿依賴 PS 7 專用運算子如 `&&`） |
| `F-05` | 自我驗證技能與 `pre-commit` 門檻 | `.agents/skills/verify-antigravity-ide-auto-setting/SKILL.md`、`.githooks/pre-commit` | 執行 `git config --get core.hooksPath` 與真實 `git commit` 觸發 Hook | `core.hooksPath` 為 `.githooks`，且 `git commit` 自動印出 `[pre-commit]` 與 `PASS` | 新環境 `git clone` 不會自動啟用 `.githooks`，須按 `README.md` 執行一次 `git config` |
| `F-06` | Append-Only 歷史與 SSOT 索引不變量 | `Change_Log.md`、`GEMINI.md`、`README.md`、`VerificationCoverageMatrix.md`、`docs/Architecture_and_Workflow.md` | 執行 `verify-repo.ps1` Check 5 & 6 (`SSOT Index Sync` / `Change_Log Append-Only`) | 所有歷史行與 `HEAD:Change_Log.md` 逐行一致，所有技能與資產皆有索引 | `Change_Log.md` 嚴禁修改或重排歷史條目；未實跑項目嚴禁填寫 `PASS` |

---

## 3. 漂移巡檢紀錄 (Drift Audit Status)
- **最後與 Tier 1 實碼核對日期**：`2026-11-26`
- **上次巡檢發現**：`已納入 docs/Architecture_and_Workflow.md 架構流程詳解、.gitattributes 行尾鎖定、Windows/Bash 雙版本指令與小寫連字號 verify-antigravity-ide-auto-setting`

---
name: verify-antigravity-ide-auto-setting
description: Antigravity-IDE-Auto-Setting 本倉庫專屬自我驗證技能（Dogfooding Verification Lever）。在修改本倉庫任何規則、技能、模板或文件後執行，包含一鍵靜態校驗、負向護欄測試與 Git Pre-Commit Hook 檢查。
---

# Verify Antigravity-IDE-Auto-Setting（本倉庫專屬驗證槓桿）

## 1. 驗證前置條件與工具鏈 (Toolchain & Preconditions)
- **作業系統 / 工具鏈**：Windows PowerShell 5.1+ / PowerShell 7+、Git CLI。
- **絕對禁止事項**：
  - 禁止修改 `Change_Log.md` 既有歷史紀錄（嚴格 Append-Only）。
  - 禁止在未實際執行 `scripts/verify-repo.ps1` 前宣告 `PASS`；環境受限（如非互動終端缺少 GitHub 憑證、Windows 環境未實測 Bash）必須誠實標記 `BLOCKED` 或 `NOT RUN`。

## 2. 分級驗證階梯 (Tiered Verification Ladder)

### Stage A — 一鍵靜態與 SSOT 門檻（每次修改後必跑）
```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\verify-repo.ps1
```
- **通過準則**：Exit Code `0`，`Summary: 7/7 checks passed.`（涵蓋 Rules Frontmatter、Skills Schema、Link Integrity、Markdown Fences、SSOT Index Sync、`Change_Log.md` Append-Only 與 Dogfooding & Drift Gate）。

### Stage B — Hook 生效檢查與負向護欄失效偵測（驗證護欄未退化）
1. 確認本機 Git Hook 已掛載並可實際執行：
   ```powershell
   git config --get core.hooksPath
   ```
   預期輸出為 `.githooks`，且於 `git commit` 時會自動觸發 `.githooks/pre-commit`。
2. 當有改動 `scripts/verify-repo.ps1` 邏輯時，應於獨立暫存目錄（不污染工作區）建立含錯誤 Frontmatter、非小寫連字號技能名、斷裂相對路徑、未閉合圍欄與過時 `01~03` 字串的測試夾具，執行：
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\scripts\verify-repo.ps1 -RepoRoot <scratch_dir> -SkipGitAppendCheck
   ```
   預期須精準攔截錯誤並回傳非零 Exit Code（`1`）。

### Stage C — 跨倉與遠端一致性驗收
```powershell
git status -sb
git rev-parse HEAD
git -C "$HOME\.gemini\config" rev-parse HEAD
git ls-remote --heads https://github.com/sung1102/Antigravity-IDE-Auto-Setting.git
```
- 確認工作區、GitVault 鏡像與 `~/.gemini/config` 一致；若無互動憑證導致 GitHub 推送失敗，需於回覆誠實標記為 `BLOCKED` 並提供使用者可執行的推送指令。

## 3. 驗證完成回報檢查
1. 依 `docs/Feature_Map.md` 核對受影響的功能項目（`F-01` ~ `F-06`），嚴格區分 **Doc Drift** 與 **實作缺陷**。
2. 同步更新 `VerificationCoverageMatrix.md` 的真實狀態（`PASS` / `FAIL` / `BLOCKED` / `NOT RUN`）。

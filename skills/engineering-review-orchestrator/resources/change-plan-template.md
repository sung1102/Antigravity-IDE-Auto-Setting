# Change Plan Template（變更規劃模板）
> 若專案已有特定規劃模板，以專案規格與使用者要求優先，並明確指出差異。

## 1. 變更範圍與非目標 (Scope & Non-Goals)
- **專案關鍵名稱 (Project Key Name)**：`<本地資料夾或主專案檔名>`
- **必要修正 (Must-Fix Scope)**：
- **可選改善 (Optional Improvements)**：
- **明確不修改範圍 (Non-Goals / Frozen Components)**：

## 2. 候選方案比較 (Candidate Solutions)
| 評估維度 | 方案 A（推薦最小變更） | 方案 B（替代方案） |
|---|---|---|
| 修改檔案與 Symbol | | |
| 對公共 API / 協定契約影響 | | |
| 對時序 / 效能影響 | | |
| 回歸風險與可回滾性 | | |

## 3. 同名備份與回滾策略 (1-to-1 Named Backup & Rollback Plan)
- **本地專案目錄 / 主檔名**：`<Project_Key_Name>`
- **對應 GitHub 私人倉庫名稱**：`<GitHub_Account>/<Project_Key_Name>.git`（確保同名對應）
- **預計 Git 備份分支 / Tag 名稱**：`backup/<Project_Key_Name>_YYYYMMDD_HHMMSS`（Git 專案嚴禁實體拷貝）
- **一鍵回滾指令**：

## 4. 分階段實作計畫 (Phased Implementation Steps)
- **Stage 1**：修改範圍 → 預期 `git diff` 檢查點 → 階段驗證命令
- **Stage 2**：修改範圍 → 預期 `git diff` 檢查點 → 階段驗證命令

## 5. 可量測驗收條件與測試計畫 (Measurable Acceptance Criteria & Verification)
- **目標重述與不變紅線 (In-Your-Own-Words)**：`<一句話確認核心目標與絕對不可破壞的既有契約>`
- **新行為直接證明 (New Behavior Proof)**：`<具體指令 / Replay / 模擬步驟與預期可觀察硬證據>`
- **既有功能回歸測試 (Regression Scope)**：`<確保未破壞黃金路徑之測試範圍>`
- **邊界條件與錯誤路徑測試**：`<超時、斷線、異常封包、邊界值測試>`
- **獨立盲審需求 (Blind Verification)**：`[ 低風險單輪驗證 | 高風險建議獨立視角檢視 Diff 與證據 ]`

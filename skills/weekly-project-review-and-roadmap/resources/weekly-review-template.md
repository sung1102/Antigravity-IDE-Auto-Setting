# Weekly Review & Roadmap Template（專案週結、全盤排查與下週規劃模板）
> 原則：所有完成事項與健康狀態皆須附真實 Git / `Change_Log.md` / 驗證輸出證據；未實測項目標記 `NOT RUN` 或 `BLOCKED`。

## A. 本週已確認進度 (Confirmed Weekly Progress)
- **統計區間**：`YYYY-MM-DD ~ YYYY-MM-DD`（Commit 範圍：`<base>..HEAD`）
- **關鍵交付成果**：
  - `[Commit / Change_Log 條目]`：`<功能或修復說明>`（影響模組：`<路徑>`）
- **本週驗證槓桿實跑結果**：
  - 執行命令：`<實際執行之自檢 / 測試 / 模擬指令>`
  - 狀態與 Exit Code：`[ PASS (0) | FAIL (...) | BLOCKED | NOT RUN ]`

---

## B. 本週遺留缺口、漂移與風險 (Open Gaps, Drift & Risks)
1. **未完成／未實測驗證項目（來自 `VerificationCoverageMatrix.md`）**：
   - `<項目>`：`[ NOT RUN | BLOCKED | FAIL ]` — 原因與解除條件：`<...>`
2. **文件與地圖漂移（Doc Drift Check）**：
   - `[ 無漂移 | 需同步: <docs/Feature_Map.md / GEMINI.md / docs/ 路徑> ]`
3. **工作區與版本衛生（Git Hygiene）**：
   - 未提交修改 / 尚未推送遠端之提交 / 過期可評估清理之 `backup/*` 分支清單：`<...>`

---

## C. 全專案功能優化與硬化建議清單 (Optimization & Hardening Radar)

| 優先級 | 類型 (`Bug風險` / `驗證硬化` / `架構Debt` / `文件漂移`) | 具體目標檔案 / Symbol | 現況觀察與根因 | 建議優化或硬化方案 (含預期效益) |
|---|---|---|---|---|
| **P0** | | | | |
| **P1** | | | | |
| **P2** | | | | |

---

## D. 下週執行規劃 (Next-Week Actionable Roadmap)
| 順序 | 目標項目 | 預設進入 `MODE` | 對應依賴 / 前置條件 | 可量測完成標準 (Acceptance Criteria) |
|---|---|---|---|---|
| **1** | | `TRACE_ONLY` / `PLAN_ONLY` / `IMPLEMENT` | | |
| **2** | | | | |
| **3** | | | | |

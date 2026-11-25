# Feature & Verification Map（行為級功能與驗證地圖模板）
> 用途：補充 `GEMINI.md` 的靜態檔案索引，讓 AI 與工程師明確知道「每個關鍵功能從哪裡觸發、如何用驗證槓桿驅動、預期看到什麼硬證據」。
> 若與線上已驗證實碼（Tier 1）衝突，依 `observed-baseline-and-ssot-sync` 以 Tier 1 為準，並區分 **Doc Drift** 與 **Product Bug**（嚴禁改寫地圖掩蓋 Bug）。

## 1. 專案驗證快速入口 (Quick Verification Entry)
- **專案關鍵名稱 (Project Key Name)**：`<XXXX_專案名稱>`
- **建置 / Lint 命令**：`<例如：dotnet build -warnaserror / verilator --lint-only -Wall>`
- **一鍵自動化驗證槓桿 (Verify Lever)**：`<例如：.\scripts\verify.ps1 / pytest / make sim>`
- **硬體／外部環境依賴（無則寫無）**：`<例如：需連接 FT601Q 開發板與邏輯分析儀，離線僅可跑 Golden Trace Replay>`

---

## 2. 功能行為與驗證對照表 (Feature Map)

| Feature ID | 功能名稱 | 觸發入口 (UI / CLI / API / Packet / RTL Top) | 驗證槓桿與操作步驟 (How to Drive) | 預期可觀察硬證據 (Expected Proof) | 已知地雷 / 保護契約 (Pitfalls & Invariants) |
|---|---|---|---|---|---|
| `F-01` | `<核心黃金路徑功能>` | `<檔案:Symbol 或指令>` | `<執行哪支測試/Replay/Sim>` | `<Exit Code 0 + 預期 Log / Byte / 波形>` | `<不可破壞的契約或時序條件>` |
| `F-02` | `<邊界與錯誤回復路徑>` | `<檔案:Symbol 或錯誤碼>` | `<注入超時/異常封包/Reset>` | `<安全降級且無資源洩漏/Latch>` | `<常見誤區，例如禁止阻塞主迴圈>` |

---

## 3. 漂移巡檢紀錄 (Drift Audit Status)
- **最後與 Tier 1 實碼核對日期**：`YYYY-MM-DD`
- **上次巡檢發現**：`[ 無漂移 | 已修正 Doc Drift: ... | 發現 Product Bug: ... ]`

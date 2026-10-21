---
description: 全域工程治理規範。適用於所有軟體、韌體、RTL（Verilog/SystemVerilog/VHDL）與通訊協定專案的審核、追蹤、規劃、實作與驗證。
trigger: always_on
---

# Global Engineering Governance Rule

面對任何軟體、桌面/UI、後端/API、韌體/驅動、通訊協定或 RTL/FPGA/ASIC 工作時，必須嚴格遵守以下核心鐵則：

1. **自動技能調度**：優先載入 `engineering-review-orchestrator` 主控技能，並依專案實證（而非僅憑資料夾名稱）調用 `software-architecture-review`、`rtl-hardware-review`、`protocol-stack-contract-review` 與 `change-safety-and-verification`。
2. **模式明確與唯讀優先**：每次回覆開頭必須標示 `MODE: TRACE_ONLY | PLAN_ONLY | IMPLEMENT | VERIFY_ONLY`。遇到原因不明、跨層、協定、硬體時序、併發或高風險問題時，預設先 `TRACE_ONLY`，禁止猜測性修改程式碼。
3. **實作前強制同名備份（GitHub 優先 + 本機保底）**：任何會改動程式碼、RTL、設定或規格的實作階段前，必須先檢查 `git status`，保留使用者未提交變更。優先使用與「本地專案資料夾/主檔名」**完全同名**的 GitHub 私人倉庫建立可回滾分支/標籤；無 GitHub 時詢問是否綁定/新建同名私人倉庫，或建立以「`<專案名稱>_backup_YYYYMMDD_HHMMSS`」命名的本機完整備份，確保人工查閱能一對一直覺對應。
4. **保護既有資產與歷史紀錄**：
   - 嚴禁擅自破壞既有功能、公共 API、協定契約或黃金路徑（Golden Path）。
   - `Change_Log.md` / `CHANGELOG.md` 一律採 **APPEND ONLY**（僅能附加於末尾，嚴禁刪除、重排或改寫歷史）。
   - 若專案有 `VerificationCoverageMatrix.md`，必須同步更新真實狀態，嚴禁填寫虛構測試結果。
5. **證據分級與誠實回報**：嚴格區分 `CONFIRMED`（有直接證據）、`INFERRED`（推論與根據）、`UNKNOWN / NOT PROVEN`（現有證據無法證明）。未實際執行的測試標為 `NOT RUN`，環境受限標為 `BLOCKED`，無真實執行/模擬/合成/板端證據時，絕對不可宣稱 PASS。

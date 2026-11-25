---
name: verify-XXXX_專案名稱
description: XXXX_專案名稱 的專案級實執行驗證技能（Verification Lever）。在執行 IMPLEMENT 後驗收或 VERIFY_ONLY 時載入，確保透過真實執行、模擬或重播取得硬證據，嚴禁僅憑編譯成功宣告 PASS。
---

# Verify XXXX_專案名稱（專案專屬驗證槓桿）

## 1. 驗證前置條件與工具鏈 (Toolchain & Preconditions)
- **作業系統 / 工具鏈**：`<Windows PowerShell / .NET SDK / Python / Verilator / Vivado>`
- **絕對禁止事項**：
  - 不得在未執行真實命令前宣告 `PASS`。
  - 不得為了讓測試通過而刪除斷言、放寬 Lint 或修改 `docs/Feature_Map.md` 掩蓋產品缺陷。

## 2. 分級驗證階梯 (Tiered Verification Ladder)

### Stage A — 低成本靜態門檻（每次修改後必跑）
```powershell
# 放入實際執行的 Lint / 編譯嚴格檢查命令，例如：
# dotnet build --no-restore -p:TreatWarningsAsErrors=true
# verilator --lint-only -Wall rtl/top.sv
```
- **通過準則**：Exit Code `0`，無新增警告或 Latch / 靜態分析錯誤。

### Stage B — 核心行為驗證槓桿（Build the Lever）
```powershell
# 放入可離線或實機執行的行為驗證腳本，例如：
# .\scripts\verify.ps1
# python tests/replay_golden_trace.py --vector captures/baseline.json
# iverilog -g2012 -o sim.vvp tb/tb_top.sv rtl/*.sv && vvp sim.vvp
```
- **通過準則**：實際觸發業務流程／封包重播／Self-Checking Testbench，明確輸出 `PASS` 證據與關鍵統計（嚴禁只看 `BYPASS`）。

### Stage C — 實機 / 互動式驗收（若適用）
- **Web / UI 專案**：啟動本地介面並檢查 DOM 狀態、Console Errors 與 Network 回應（無背景例外或未處理 Rejection）。
- **硬體 / 板端專案**：若目前環境無實體板卡或邏輯分析儀，對應項目於 `VerificationCoverageMatrix.md` 一律標註 `NOT RUN` 或 `BLOCKED`。

## 3. 驗證完成回報檢查
1. 依 `docs/Feature_Map.md` 核對受影響的功能項目（區分 **Regression 綠燈** 與 **本次新增/修復行為證據**）。
2. 若在驗收中發現重複性錯誤，依 `verification-harness-builder` 提議將檢查硬化至 Stage A/B 腳本或編譯規則。
3. 同步更新 `VerificationCoverageMatrix.md` 的真實狀態（`PASS` / `FAIL` / `BLOCKED` / `NOT RUN`）。

---
name: weekly-project-review-and-roadmap
description: 專案每週進度盤點、驗證缺口稽核、全專案技術債與優化排查、以及下週執行路線規劃技能（含唯讀快照腳本與 /automation 週報排程指引）。當使用者詢問本週進度、下週規劃、專案健檢或功能優化建議時自動調用。
---

# Weekly Project Review & Optimization Roadmap（專案週結、全盤排查與下週規劃技能）

當使用者詢問「這週進度如何」、「幫我整理本週進度與下週規劃」、「全面排查還有哪裡可以優化」時，自動依本技能執行**有證據支撐的唯讀盤點**，嚴禁憑空猜測或虛構未執行的測試結果。

---

## 一、 核心操作鐵則

1. **唯讀優先（`TRACE_ONLY` → `PLAN_ONLY`）**：週報彙整與優化排查過程中，**嚴禁擅自修改任何產品程式碼、RTL 或公共協定契約**。
2. **事實分級與不造假**：僅將實際查到的 Git 提交、`Change_Log.md` 紀錄與實測 `PASS` 列為已完成；`VerificationCoverageMatrix.md` 中的 `NOT RUN`、`BLOCKED`、`FAIL` 必須如實揭露。
3. **可執行優化而非空泛建議**：每條優化建議必須附上「具體檔案路徑／行號或模組」、「問題原因」與「可落地的硬化／修正方向」（優先參照 `../verification-harness-builder/resources/guardrail-snippets.md`）。

---

## 二、 5 步週期自動排查流程

### Step 1 — 執行唯讀快照腳本（高訊噪比蒐證首選）
先執行本技能內建的跨平台唯讀快照腳本（只會讀取 Git 與已追蹤檔案，不改動任何檔案），一次取得近 7 天交付軌跡、`backup/*` 分支、`Change_Log`、`VerificationCoverageMatrix` 缺口、`Feature_Map` 與 `TODO`/`FIXME`/`HACK` 分佈：
- **Windows (PowerShell)**：
  ```powershell
  powershell -ExecutionPolicy Bypass -File "$HOME\.gemini\config\skills\weekly-project-review-and-roadmap\scripts\collect-weekly-snapshot.ps1" -ProjectRoot . -Days 7
  ```
- **macOS / Linux (Bash)**：
  ```bash
  bash "$HOME/.gemini/config/skills/weekly-project-review-and-roadmap/scripts/collect-weekly-snapshot.sh" . 7
  ```
*(若在無 `~/.gemini/config` 的獨立測試環境，可將路徑替換為本技能實際目錄下的 `scripts/collect-weekly-snapshot.ps1` / `.sh`。)*

### Step 2 — 實跑專案可執行驗證槓桿
檢查快照輸出的驗證入口（`.agents/skills/verify-*/`、`<ProjectRoot>/scripts/verify.ps1`、本倉 `scripts/verify-repo.ps1` 或現有 Unit Test / Lint / Batch Sim），實跑一次確認本週結束時系統真實健康度；無法執行者標為 `NOT RUN` 或 `BLOCKED`。

### Step 3 — `Feature_Map` 與文件漂移巡檢（Doc Drift Audit）
對照近 7 天改動最頻繁的檔案清單，檢查專案 `docs/Feature_Map.md`、`GEMINI.md`、`README.md` 與 `docs/` 是否出現未同步過時記述或未覆蓋的新增功能。

### Step 4 — 領域技術債與功能優化排查
依專案實證技術棧結合對應審核清單（`../software-architecture-review/`、`../rtl-hardware-review/`、`../protocol-stack-contract-review/`）與快照列出的 `TODO`/`FIXME`/`HACK`，抽查近一週高頻修改區域是否存在：
- 尚未硬化為編譯器／Linter／腳本門檻的重複性錯誤；
- 軟體資源釋放／非同步逾時、RTL Latch／位寬／CDC、協定 Length／Replay 缺口；
- 未清理之過期 `backup/*` 分支或未推送至遠端之本地提交。

### Step 5 — 產出週報與下週路線規劃
依 `resources/weekly-review-template.md` 輸出結構化報告：
- **即時對話模式**：直接依標準架構回報於對話視窗供使用者確認排程。
- **週報存檔／排程模式**：若使用者明確要求存檔（或透過 `/automation` 自動執行），將報告寫入目標專案 `docs/weekly/YYYY-Www.md`（不覆蓋既有歷史週報）。

---

## 三、 搭配 `/automation` 全自動每週執行
若希望 Antigravity 每週固定時間自動掃描主力專案並產出週報，請參閱 `resources/automation-prompt-guide.md` 搭配 `/automation` 指令設定週期排程。

# GEMINI.md - Antigravity-IDE-Auto-Setting 專案記憶索引

本檔案為 `Antigravity-IDE-Auto-Setting`（Antigravity 全域工程審核規則與技能庫）的專案記憶與架構導覽地圖。後續 AI 進入本倉庫進行任何檢視、維護或升級時，**強制優先讀取本文件作為事實基準**，絕不盲目全盤掃描。

---

## 一、 專案核心基本資料
- **專案名稱**：`Antigravity-IDE-Auto-Setting`
- **本地掛載路徑**：`~/.gemini/config`（Windows: `C:\Users\csshih\.gemini\config`）
- **GitHub 私人倉庫**：`https://github.com/sung1102/Antigravity-IDE-Auto-Setting.git`
- **核心職責**：存放 Antigravity / Antigravity IDE 的全域工程審核規則（Rules）、技能組（Skills）與三大情境專案導入通用提示詞手冊（Templates），支援軟體、韌體、通訊協定與 RTL 硬體專案。

---

## 二、 核心模組導覽地圖 (Key Modules Map)

| 目錄 / 模組 | 角色與職責 | 關鍵檔案 | 觸發方式 / 指令 |
|---|---|---|---|
| `rules/` | 全域長駐工程治理規範 | `rules/engineering-governance.md` | `trigger: always_on`（每次對話自動生效） |
| `skills/engineering-review-orchestrator/` | 主控審查與調度中樞 | `SKILL.md`, `resources/trace-report-template.md`, `resources/change-plan-template.md` | `/engineering-review-orchestrator` 或自然語言症狀描述 |
| `skills/software-architecture-review/` | 軟體、API、WPF/MVVM、非同步架構審核 | `SKILL.md`, `resources/software-checklist.md` | `/software-architecture-review` 或軟體 Bug/例外關鍵字 |
| `skills/rtl-hardware-review/` | Verilog/VHDL、FPGA、CDC 跨時脈、握手時序審核 | `SKILL.md`, `resources/rtl-checklist.md` | `/rtl-hardware-review` 或硬體/RTL/CDC 關鍵字 |
| `skills/protocol-stack-contract-review/` | 通訊協定、USB/FIFO、Register Map、ACK 語義審核 | `SKILL.md`, `resources/protocol-checklist.md` | `/protocol-stack-contract-review` 或封包/長度/暫存器關鍵字 |
| `skills/change-safety-and-verification/` | 變更安全、Git 優先回滾備份、真實驗證制度 | `SKILL.md`, `resources/verification-template.md` | 改動程式碼（`IMPLEMENT`）或驗證時強制調用 |
| `templates/` | 三大情境專案導入通用提示詞手冊 | `templates/project-onboarding-prompts.md` | 複製填入 `XXXX` 貼至 IDE 對話框 |
| `README.md` | 跨電腦掛載、同步更新與手冊導覽說明 | `README.md` | 查閱一鍵掛載指令 |

---

## 三、 全域工程紅線與不可破壞條件 (Protected Invariants)

1. **回覆模式標記（MODE）**：每次回覆開頭必須明確標示 `MODE: TRACE_ONLY | PLAN_ONLY | IMPLEMENT | VERIFY_ONLY`。
2. **TRACE_ONLY 唯讀優先**：遇到原因不明、跨層、協定、硬體時序、併發或高風險問題時，預設先 `TRACE_ONLY`，嚴禁猜測性改碼。
3. **版本回滾（Git 優先，嚴禁重複實體拷貝）**：
   - 凡具備 Git 之專案，一律以 Git 分支（`backup/<Project_Key_Name>_YYYYMMDD_HHMMSS`）或標籤作為回滾點。
   - **全面禁止在硬碟重複建立實體備份資料夾**（僅非 Git 且使用者明確拒絕 Git 時為唯一例外）。
4. **黃金路徑保護**：嚴禁擅自破壞既有功能、公共 API、協定契約或既定黃金路徑。
5. **Change_Log 嚴格 APPEND ONLY**：只能在末尾追加紀錄，嚴禁重排、改寫或刪除歷史。
6. **誠實證據分級**：嚴格區分 `CONFIRMED`（有直接證據）、`INFERRED`（推論及根據）、`UNKNOWN / NOT PROVEN`（未證實）；測試結果非真實執行不得宣稱 `PASS`。

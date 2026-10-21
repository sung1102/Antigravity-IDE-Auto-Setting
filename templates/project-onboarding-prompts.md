# 專案導入與 AI 協同開發通用提示詞手冊 (Project Onboarding Prompts)

本手冊提供三大開發情境的標準填空範本。使用者只需複製對應情境區塊，將所有 `XXXX` 替換為實際專案資訊，直接貼入 Antigravity IDE 對話視窗即可啟動自動化流程。

---

## 情境 1：全新專案從零開發 (Brand-New Project)
> **適用時機**：建立全新專案，由 AI 協助初始化架構、建立 Git、綁定同名 GitHub 私人倉庫並設定工程防護基線。

### 複製下方提示詞：
```text
我要從零開始建立一個全新工程專案，請依全域工程審核技能組規範執行自動初始化：

【專案基本資料】
- 專案名稱：XXXX_專案名稱
- 對應 GitHub 私人倉庫：https://github.com/XXXX_GITHUB帳號/XXXX_專案名稱.git
- 目標技術棧：XXXX_程式語言與硬體架構（例如：C# WPF / Verilog RTL / Python API）
- 核心功能目標：XXXX_簡要描述系統主要功能與目標
- 通訊與外設介面：XXXX_通訊介面（例如：USB 3.0 FIFO / UART / PCIe / I2C / 無）

【請依序執行以下流程】
1. 在本機專案目錄執行 git init，依技術棧自動建立標準 .gitignore。
2. 建立專案骨幹、README.md、Change_Log.md（初始化第一筆記錄）與 VerificationCoverageMatrix.md。
3. 建立專案記憶索引檔 GEMINI.md：
   - 記錄專案目標、核心架構邊界與紅線保護規則。
   - 標明後續 AI 每次進入專案時優先讀取之文件索引。
4. 建立初始專案骨幹與 Hello World / Loopback 驗證結構，完成 Stage 1 驗證。
5. 綁定同名 GitHub 遠端私人倉庫並執行首次推送：
   git add .
   git commit -m "first commit: initialize XXXX_專案名稱 with engineering governance"
   git branch -M main
   git remote add origin https://github.com/XXXX_GITHUB帳號/XXXX_專案名稱.git
   git push -u origin main
6. 依標準 7 大區塊格式回報建置結果。
```

---

## 情境 2：既有本地舊專案轉移納管 (Legacy Project Onboarding)
> **適用時機**：本機已有現成軟體、韌體或 RTL 代碼，需由 AI 執行唯讀逆向分析、產出架構與通訊文件，並推送到同名 GitHub 私人倉庫納管。

### 複製下方提示詞：
```text
我要將本地既有的舊專案納管至 GitHub，並由你進行系統架構逆向分析，產出基準技術文件供後續開發查閱。
【注意：本次為純唯讀分析與文件產出，絕不可修改或刪除任何既有程式碼、RTL 或組態檔！】

【專案基本資料】
- 本地專案名稱：XXXX_舊專案名稱
- 對應 GitHub 私人倉庫：https://github.com/XXXX_GITHUB帳號/XXXX_舊專案名稱.git
- 硬體/RTL 目錄與模組：XXXX_硬體代碼目錄與核心模組（例如：rtl/ 資料夾下的 Top 模組，無則填無）
- 軟體專案名稱與目錄：XXXX_軟體代碼目錄與主應用（例如：src/ 桌面工具或韌體代碼）
- 軟硬體傳輸介面：XXXX_通訊協定與實體介面（例如：USB / FTDI FIFO / Register 讀寫）
- 凍結不可動之黃金路徑：XXXX_需保留的既有介面或暫存器契約

【請依序執行以下流程】
1. 建立本機同名時間戳備份：XXXX_舊專案名稱_backup_YYYYMMDD_HHMMSS。
2. 掃描大型暫存檔（編譯暫存、波形、.runs、bin/obj），產生專屬 .gitignore。
3. 執行 MODE: TRACE_ONLY 深度分析（調用 software/rtl/protocol 審核技能），生成下列文件：
   - docs/01_Hardware_RTL_Architecture.md：模組階層、Clock/Reset、FSM 與資料流（若無 RTL 則略過）。
   - docs/02_Software_Architecture.md：UI/業務呼叫鏈、核心模組、通訊包裝層。
   - docs/03_Protocol_and_Register_Map.md：封包格式、Length 定義、暫存器對照表。
4. 在專案根目錄建立 GEMINI.md 專案記憶索引：
   - 摘要系統架構與關鍵通訊參數。
   - 明確設定紅線指示：後續 AI 進入本專案處理問題時，強制先讀取 docs/ 內之技術文件作為事實基準，不重複全盤掃描。
5. 初始化 Git 並推送到 GitHub 私人倉庫：
   git init
   git add .
   git commit -m "first commit: import XXXX_舊專案名稱 with full architecture baseline docs"
   git branch -M main
   git remote add origin https://github.com/XXXX_GITHUB帳號/XXXX_舊專案名稱.git
   git push -u origin main
6. 依標準 7 大區塊格式回報分析結論、文件清單與推送狀態。
```

---

## 情境 3：既有專案升級新範本規範 (Upgrade Existing AI Project)
> **適用時機**：專案原本就已在 Git/GitHub 上由 AI 協同開發，現在需要對齊最新版全域工程審核規範、Append-only 變更紀錄與專案索引 `GEMINI.md`。

### 複製下方提示詞：
```text
本專案已在 Git 納管開發中，現在需要升級並導入最新版全域工程審核規範與 GEMINI.md 索引架構。
【注意：本次升級僅限治理文件與工作流對齊，嚴禁變更任何既有商業邏輯、API 契約或 RTL 行為！】

【專案基本資料】
- 專案名稱：XXXX_專案名稱
- 當前 Git 狀態：XXXX_當前分支與遠端狀態（例如：已有 origin main，工作區乾淨）
- 既有紀錄檔位置：XXXX_既有變更紀錄路徑（例如：根目錄 Change_Log.md，若無則由 AI 新建）

【請依序執行以下流程】
1. 執行 git status 與 git diff，確認無未提交的衝突內容。
2. 建立升級安全備份標籤：git tag backup/pre-governance-upgrade-$(date +%Y%m%d%H%M%S)。
3. 檢視並升級專案治理文件：
   - 檢查/新建 GEMINI.md：整合全域工程審核規則（強制 MODE 標記、TRACE_ONLY 優先、真實證據分級），並建立專案關鍵模組導覽地圖。
   - 檢查/建立 Change_Log.md：確保符合「APPEND ONLY（僅限末尾追加）」原則，記錄本次規範升級。
   - 檢查/建立 VerificationCoverageMatrix.md：依現有測試與驗證項目建立矩陣骨幹（未實跑者標記 NOT RUN）。
4. 檢查遠端倉庫與分支命名是否符合「專案名稱 1 對 1 同名映射」規範。
5. 提交並推送治理升級變更：
   git add GEMINI.md Change_Log.md VerificationCoverageMatrix.md
   git commit -m "chore: align XXXX_專案名稱 with global engineering review governance"
   git push origin main
6. 依標準 7 大區塊格式回報升級結果。
```

---
name: verification-harness-builder
description: 專案級可執行驗證槓桿（Verification Lever）、行為級 Feature Map、重複錯誤硬化升級（Deterministic Guardrails）與驗證資產維護技能。在開立新專案、納管/升級舊專案、建立 .agents/skills/verify-<project>/ 或同類錯誤重複發生需升級為自動檢查時調用。
---

# Verification Harness Builder（專案驗證槓桿與錯誤硬化技能）

光靠「編譯通過」或手寫人工 Checklist，不足以讓 AI 自主完成可靠驗收；而把越來越多文字警告塞進 `GEMINI.md` / `AGENTS.md`，只會讓模型在長對話後忘記規則。

本技能將跨專案的實務驗證經驗制度化為三大支柱：
1. **Build the Lever（建置可執行驗證槓桿）**：讓 AI 能親自啟動、驅動與驗證真實行為，取得可重現證據。
2. **Feature Map & Drift Audit（行為地圖與漂移巡檢）**：明確記錄「如何觸發與驗證每個功能」，並區分「文件漂移」與「真實缺陷」。
3. **Prose-to-Guardrail Escalation（重複錯誤硬化律）**：同類錯誤發生第 2 次時，從散文提醒升級為編譯器、Linter、Assertion 或驗證腳本門檻。

---

## 一、 四大技術棧「驗證槓桿（Verification Lever）」建置標準

在開立或納管專案時，依專案技術棧於專案內建立**非互動式、一鍵可重複執行、明確回傳 Exit Code** 的驗證入口（例如 `<ProjectRoot>/scripts/verify.ps1`、`Makefile` `verify` target 或 `tests/` runner）：

### 1. 桌面軟體 / 應用服務（C# / WPF / C++ / Python）
- **編譯安全門檻**：優先啟用高嚴格度靜態門檻（例如 C# `.csproj` 啟用 `Nullable` 與 `<TreatWarningsAsErrors>`、`.editorconfig` / Roslyn Analyzer 禁止 `async void`；C++ 啟用 `/W4` 或 `-Wall -Wextra`；Python 啟用 `ruff` / `mypy` / `pytest`）。
- **可驅動驗證入口**：除單元測試外，針對桌面/UI/背景服務建立 **Headless Service Self-Test、CLI `--smoke-test` 或 UI 自動化驅動腳本**（如 FlaUI / WinAppDriver / Loopback 模擬通道），能實際觸發核心業務流程並輸出結構化執行日誌與視窗狀態，嚴禁只用 `dotnet build` 成功代替行為驗收。

### 2. 通訊協定 / 韌體整合（USB / UART / SPI / I2C / eDP / Register Map）
- **Golden Trace Replay 測試器**：將實機 / 邏輯分析儀（LA）/ Sniffer 抓回並通過 Tier 1 確認的封包序列，轉存為確定性測試向量（Deterministic Golden Vectors），建立可離線重播的 CLI Replay / Virtual Responder 測試。
- **契約不變量斷言**：驗證每次修改 Parser、TL/AL 分層或封包組裝後，逐 Byte Payload、Length 編碼、Endianness、ZLP/Padding 邊界與 Timeout 清除邏輯 100% 吻合基準向量。

### 3. RTL / FPGA / ASIC（Verilog / SystemVerilog / VHDL）
- **非互動式 Lint + Batch Simulation Lever**：建立一鍵執行的批次腳本（依專案工具鏈選用 `verilator --lint-only -Wall` / Verible / `iverilog`+`vvp` / Vivado `xsim` batch），物理攔截 Inferred Latch、阻塞/非阻塞混用、位寬截斷與未連接端口。
- **Self-Checking Testbench**：Testbench 必須具備自動比對預期與實測輸出，於終端機明確列印 `PASS` 或 `FAIL`（附帶首個出錯拍數與訊號值）並回傳非零 Exit Code，使 AI 不需人工開啟 GUI 波形即可執行快速回歸。
- **誠實邊界**：模擬 / Lint 通過僅代表模擬層 `PASS`；未實際執行 Synthesis / STA / 板端實測者，仍須於 `VerificationCoverageMatrix.md` 標註 `NOT RUN` 或 `BLOCKED`。

### 4. Web / 前後端應用
- **前後端端到端槓桿**：後端 API 測試腳本（含真實 HTTP Status 與 Payload 驗證）＋ 前端於 `VERIFY_ONLY` 階段實際啟動本地伺服器並透過瀏覽器自動化工具檢查 DOM 渲染、關鍵使用者流程、Console Errors 與 Network 請求結果。

---

## 二、 專案專屬驗證技能與 Feature Map（`.agents/skills/verify-<Project_Key_Name>/`）

為避免接手 AI 在大型專案中盲目全盤掃描或猜測「怎麼測這個功能」，應在專案內建立兩項標準資產：

1. **行為級 Feature Map（`docs/Feature_Map.md`）**：參照 `resources/feature-map-template.md`，為每個關鍵功能回答 4 件事：
   - **功能定義與保護契約**：此功能做什麼、不可破壞的邊界為何。
   - **觸發入口**：對應的 UI 路徑 / CLI 命令 / API Endpoint / 封包指令 / RTL Top 端口。
   - **AI 驗證槓桿指令**：如何用專案既有腳本或模擬器實際驅動並驗證。
   - **已知地雷與實測前提**：常見誤區、時序限制或硬體前置條件。
2. **專案級驗證技能（`.agents/skills/verify-<Project_Key_Name>/SKILL.md`）**：參照 `resources/verify-skill-template.md`，定義該專案從「環境啟動 → 低成本快速驗證 → 核心行為驗證 → 證據輸出」的標準步驟。

---

## 三、 抗腐化維護與「Doc Drift vs Product Bug」判定鐵則

每次完成重大功能修改、架構重構或於 `VERIFY_ONLY` 巡檢時，執行以下維護紀律：
1. **分頭比對實際碼與地圖**：對照修改後的源碼、`Feature_Map.md` 與驗證腳本輸出，檢查是否出現過時路徑或指令。
2. **嚴格區分「文件漂移」與「真實缺陷」**：
   - **Doc Drift（文件/腳本漂移）**：產品行為已依授權合法更新，僅地圖路徑、指令參數或舊預期值未更新 → 同步更新 `Feature_Map.md` 與驗證腳本（並遵守 `observed-baseline-and-ssot-sync` 回溯規則）。
   - **Product Bug（真實缺陷）**：產品實作違反契約、崩潰或與實測基準不符 → **絕對禁止修改 `Feature_Map.md` 或放寬測試斷言來讓紅燈變綠燈**，必須停下並回報真實錯誤。

---

## 四、 重複錯誤硬化協議（Prose-to-Guardrail Escalation）

當同一個專案中出現 **第 2 次以上同類 AI/人為失誤**（例如：忘記傳遞 `CancellationToken`、WPF 背景執行緒更新 UI、RTL 遺漏 `default` 分支、忘記同步更新 `GEMINI.md` 模組索引或覆寫歷史 `Change_Log`）：
1. **禁止只追加散文提醒**：不要僅在 `GEMINI.md` 或 `SKILL.md` 多加一條「請記得不要犯 X」。
2. **強制升級為決定性護欄（Deterministic Guardrail）**：在 `PLAN_ONLY` 提出並將檢查寫入以下至少一層：
   - **語法/型別/編譯層**：開啟更嚴格的編譯器警告為錯誤、靜態 Analyzer 或型別約束。
   - **Lint/腳本層**：將檢查邏輯加入專案的 `<ProjectRoot>/scripts/verify` 或 `verify-repo` 腳本，使違規時直接回傳非零 Exit Code。
   - **測試層**：針對該故障模式補上一支最小確定性回歸測試（Regression Test）。

---

## 五、 模板參考
- 行為級功能與驗證地圖模板：`resources/feature-map-template.md`
- 專案專屬驗證技能模板：`resources/verify-skill-template.md`
- 跨技術棧決定性護欄實戰範本：`resources/guardrail-snippets.md`

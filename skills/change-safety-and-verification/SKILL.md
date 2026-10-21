---
name: change-safety-and-verification
description: 變更安全保護、同名一對一映射備份（本地專案名=GitHub倉庫名=備份名）、全新/現有本地專案自動版本控制、Append-Only 變更紀錄與真實驗證制度技能。在開立新專案、執行程式碼/RTL/韌體修改（IMPLEMENT）及驗收測試（VERIFY_ONLY）時強制調用。
---

# Change Safety and Verification（變更安全與同名備份驗證制度技能）

負責所有工程專案共同的版本初始化、同名一對一映射備份、工作區保護、歷史紀錄維護與真實驗證制度。任何專案開立、實作與驗證階段都必須嚴格遵守本技能規範。

## 一、 核心命名鐵則：「本地專案 ↔ GitHub 倉庫 ↔ 備份檔案」同名一對一映射
為了讓工程師在人工查閱本地資料夾與 GitHub 遠端倉庫時能直覺、快速一對一對應，所有備份與建倉操作強制遵循以下同名規則：

1. **提取專案關鍵名稱 (`<Project_Key_Name>`)**：
   - 以專案的**本地根目錄資料夾名稱**（或主專案檔名，如 `<Name>.sln`、`<Name>.xpr`、`<Name>.bpr`）作為唯一基準關鍵字。
2. **GitHub 遠端倉庫同名原則**：
   - **自動新建私人倉庫時**：GitHub 倉庫名稱必須與 `<Project_Key_Name>` **完全一致**（例如本地資料夾為 `Jupiter_eDP_Analyzer`，遠端倉庫即為 `https://github.com/<帳號>/Jupiter_eDP_Analyzer.git`）。
   - **綁定現有閒置倉庫時**：若使用者提供一個閒置倉庫（如 `temp-repo-1`），Agent 在綁定時應主動詢問或協助執行 `gh repo rename <Project_Key_Name>` 將該 GitHub 倉庫同步改名為 `<Project_Key_Name>`，確保遠端與本地名稱 100% 對齊。
3. **分支、標籤與本機備份資料夾同名原則**：
   - **Git 備份分支 / Tag 名稱**：強制包含專案名與時間戳，格式為 `backup/<Project_Key_Name>_YYYYMMDD_HHMMSS`。
   - **本機完整備份資料夾名稱**：強制格式為 `<Project_Key_Name>_backup_YYYYMMDD_HHMMSS`（嚴禁只寫 `backup_日期` 導致人工無法辨識屬於哪個專案）。

## 二、 依專案狀態自動分流的備份流程
在**開立新專案**，或**每一個會改動程式碼、RTL、專案設定、重要規格檔的實作階段開始前**，Agent 必須先自動執行環境檢查（`git status`、`git remote -v`、`gh auth status`），並依下列三種狀態自動處理：

### 狀態 A：全新開發專案（Brand-New Project）
1. 自動在專案根目錄執行 `git init`，建立標準 `.gitignore`。
2. 取得本地專案名稱 `<Project_Key_Name>`，主動詢問使用者：
   - 「正在初始化新專案 `<Project_Key_Name>`。請問要由我直接**自動建立同名的 GitHub 私人倉庫（`<Project_Key_Name>`）**，還是綁定您**現有的閒置 GitHub 倉庫（並自動改名為 `<Project_Key_Name>`）**？（若暫不連網，將直接建立本地同名基準備份 `<Project_Key_Name>_backup_YYYYMMDD_HHMMSS`）」。
3. 依使用者回覆，自動執行 `gh repo create <Project_Key_Name> --private --source=. --remote=origin --push` 或綁定遠端。

### 狀態 B：現有本地專案（Existing Local Project，尚未綁定 GitHub 遠端）
1. **保護未提交工作**：若已有本地 Git，先檢查 `git status` 與 `git diff`；**絕對禁止**將使用者未提交的變更混入本次修改，也**絕對禁止**擅自執行 `git reset --hard`、`git clean` 或覆蓋檔案。
2. **本機同名保底備份先行**：在改動任何檔案前，先自動建立帶專案名稱與時間戳的本機完整備份 `<Project_Key_Name>_backup_YYYYMMDD_HHMMSS/`。
3. **GitHub 同名倉庫綁定詢問**：主動向使用者確認：
   - 「偵測到本地專案 `<Project_Key_Name>` 尚未綁定 GitHub 遠端：
     1. **綁定閒置倉庫並同步改名**：請貼上閒置 GitHub 倉庫網址，我將綁定並協助將倉庫名稱對齊為 `<Project_Key_Name>`（設為私人）。
     2. **自動新建同名私人倉庫**：回覆『新建私人倉庫』，我將自動建立同名 Private Repo `<Project_Key_Name>` 並推送備份。
     3. **僅用本地同名備份**：回覆『本地備份』，直接使用 `<Project_Key_Name>_backup_YYYYMMDD_HHMMSS` 繼續執行。」

### 狀態 C：已綁定 GitHub 遠端的現有專案（GitHub-Linked Project）
1. 檢查 `git status` 保護未提交變更，並核對本地 `<Project_Key_Name>` 與 `git remote -v` 的倉庫名稱是否一致（若不一致，於報告中提醒對應關係）。
2. 自動建立同名時間戳備份分支或標籤 `backup/<Project_Key_Name>_YYYYMMDD_HHMMSS`，記錄基準 Commit SHA 與一鍵還原指令。

## 三、 分階段最小變更與黃金路徑保護
1. **小步分階段實作（Phased Implementation）**：
   - 將修改拆分為職責單一的小階段；每階段完成後立即檢查 `git diff` 並執行最低成本驗證，確認無誤才進下一階段。
   - 驗證失敗時立即停在安全狀態並分析根因，**嚴禁用大量額外猜測性修改掩蓋第一個錯誤**。
2. **保護凍結元件與黃金路徑（Golden Path Protection）**：
   - 修改共用介面、核心傳輸引擎、共用解析器、全域時序/時脈/Reset、公共 API 或既有黃金路徑前，必須先提出 **Architecture Exception（架構例外與風險說明）** 並取得使用者明確同意。

## 四、 歷史紀錄與驗證覆蓋矩陣維護規則
1. **`Change_Log.md` / `CHANGELOG.md` 採 APPEND ONLY（僅限末尾追加）**：
   - 新增變更紀錄**只能附加在檔案最末尾**，**嚴禁**重排、改寫、刪除或壓縮任何既有歷史內容。
2. **`VerificationCoverageMatrix.md` 維護**：
   - 若已存在驗證覆蓋矩陣，必須隨修改同步更新對應列、測試證據與缺口；**絕對禁止用虛構測試結果填滿矩陣**。

## 五、 真實驗證狀態與誠實回報
每次變更或驗證後，必須依 `resources/verification-template.md` 回報，並嚴格使用以下四種狀態標記：
- **`PASS`**：已實際執行命令，Exit Code 為 0 且輸出結果符合預期證據。
- **`FAIL`**：已實際執行但發生錯誤，附上第一個真實錯誤訊息。
- **`BLOCKED`**：因缺少實體硬體板卡、EDA License、儀器或權限限制無法執行。
- **`NOT RUN`**：本次尚未執行的測試、模擬或實測項目。
- **鐵則**：硬體未上板實測前，板端驗證項目一律標為 `NOT RUN` 或 `BLOCKED`，**絕不可標記為 `PASS`**。

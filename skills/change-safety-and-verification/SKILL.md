---
name: change-safety-and-verification
description: 變更安全保護、Git 優先版本回滾（嚴禁重複實體拷貝）、同名一對一映射、全新/現有本地專案自動版本控制、Append-Only 變更紀錄與真實驗證制度技能。在開立新專案、執行程式碼/RTL/韌體修改（IMPLEMENT）及驗收測試（VERIFY_ONLY）時強制調用。
---

# Change Safety and Verification（變更安全與版本驗證制度技能）

負責所有工程專案共同的版本初始化、Git 優先回滾備份、工作區保護、歷史紀錄維護與真實驗證制度。任何專案開立、實作與驗證階段都必須嚴格遵守本技能規範。

## 一、 專案層級自動備份制度（Git 優先，嚴禁重複實體拷貝）

在開立新專案，或每次執行 `IMPLEMENT` 改動檔案前，強制依循以下原則建立回滾點：

### 核心鐵則
1. **禁止冗餘拷貝**：若專案已有 Git 或即將初始化 Git，**禁止複製整包實體專案資料夾**。大型工程（FPGA/桌面應用）複製實體資料夾會耗損磁碟空間與 I/O，Git 的 Commit、Branch 與 Tag 已具備完整快照功能。
2. **Git 回滾點規範**：
   - 備份分支名稱：`backup/<Project_Key_Name>_YYYYMMDD_HHMMSS`
   - 備份 Tag 名稱：`tag/backup_<Project_Key_Name>_YYYYMMDD_HHMMSS`

### 依專案狀態自動處理流程
- **狀態 A：全新開發專案**：
  直接執行 `git init`，建立 `.gitignore`，產生初始專案結構後進行 First Commit 並推送到同名 GitHub 私人倉庫。**不產生任何實體備份資料夾。**
- **狀態 B：現有本地專案（尚未綁定 GitHub）**：
  1. 檢查是否有本地 Git。若無，以現況直接執行 `git init` 並 commit 作為「原始基準版本（Baseline）」，或依使用者意願建立/綁定同名 GitHub 私人倉庫。
  2. 變更前建立備份分支：`git branch backup/<Project_Key_Name>_$(date +%Y%m%d_%H%M%S)`。
  3. **禁止建立實體備份資料夾**。
- **狀態 C：已綁定 GitHub 的現有專案**：
  直接建立備份分支並推送至遠端：`git branch backup/<Project_Key_Name>_$(date +%Y%m%d_%H%M%S)`。
- **狀態 D（唯一降級例外）：非 Git 且拒絕使用 Git**：
  僅當使用者明確要求不使用 Git 時，才複製實體資料夾 `<Project_Key_Name>_backup_YYYYMMDD_HHMMSS` 作為保底。

## 二、 分階段最小變更與黃金路徑保護
1. **小步分階段實作（Phased Implementation）**：
   - 將修改拆分為職責單一的小階段；每階段完成後立即檢查 `git diff` 並執行最低成本驗證，確認無誤才進下一階段。
   - 驗證失敗時立即停在安全狀態並分析根因，**嚴禁用大量額外猜測性修改掩蓋第一個錯誤**。
2. **保護凍結元件與黃金路徑（Golden Path Protection）**：
   - 修改共用介面、核心傳輸引擎、共用解析器、全域時序/時脈/Reset、公共 API 或既有黃金路徑前，必須先提出 **Architecture Exception（架構例外與風險說明）** 並取得使用者明確同意。

## 三、 歷史紀錄與驗證覆蓋矩陣維護規則
1. **`Change_Log.md` / `CHANGELOG.md` 採 APPEND ONLY（僅限末尾追加）**：
   - 新增變更紀錄**只能附加在檔案最末尾**，**嚴禁**重排、改寫、刪除或壓縮任何既有歷史內容。
2. **`VerificationCoverageMatrix.md` 維護**：
   - 若已存在驗證覆蓋矩陣，必須隨修改同步更新對應列、測試證據與缺口；**絕對禁止用虛構測試結果填滿矩陣**。

## 四、 真實驗證狀態與誠實回報
每次變更或驗證後，必須依 `resources/verification-template.md` 回報，並嚴格使用以下四種狀態標記：
- **`PASS`**：已實際執行命令，Exit Code 為 0 且輸出結果符合預期證據。
- **`FAIL`**：已實際執行但發生錯誤，附上第一個真實錯誤訊息。
- **`BLOCKED`**：因缺少實體硬體板卡、EDA License、儀器或權限限制無法執行。
- **`NOT RUN`**：本次尚未執行的測試、模擬或實測項目。
- **鐵則**：硬體未上板實測前，板端驗證項目一律標為 `NOT RUN` 或 `BLOCKED`，**絕不可標記為 `PASS`**。

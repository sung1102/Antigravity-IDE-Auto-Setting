---
name: software-architecture-review
description: 軟體架構與程式碼審核技能。適用於 C/C++、Borland C++ Builder、C#/.NET、WPF/MVVM、Python、Java、JavaScript/TypeScript、Web、後端、API、資料處理與桌面應用軟體的錯誤追查、架構審查、併發分析與最小安全重構。
---

# Software Architecture Review（軟體架構審核技能）

適用於一般應用軟體、桌面/UI、後端/API 與系統工具。在開始審查或修改前，必須先依據**真實程式碼**建立呼叫鏈（Call Chain）與資料流（Data Flow），嚴禁憑空猜測。

## 一、 核心審查維度

### 1. 呼叫鏈與資料所有權 (Call Chain & Data Ownership)
- 明確標出問題入口（Entry Point）、主要呼叫鏈、狀態來源（State Source）、資料所有權（Ownership）、輸入/輸出格式與錯誤傳播路徑（Error Propagation）。
- 檢查例外是否被靜默吞掉（Swallowed Exceptions）或失去原始上下文。

### 2. 模組邊界與架構契約 (Boundaries & Contracts)
- 檢查模組責任、分層邊界（UI / Domain / Service / HAL / Data Access）、依賴方向、介面契約與向下相容性。
- 優先重用專案既有可用路徑（Golden Path / 正式 Service 或 Helper），嚴禁繞過既有架構另建重複輪子。

### 3. 併發、非同步與資源生命週期 (Concurrency, Async & Lifecycle)
- 深入檢查 `async/await`、執行緒（Threads/Tasks）、事件（Events）、鎖（Locks/Mutex/Semaphore）、取消機制（`CancellationToken`）、逾時（Timeout）與重入（Reentrancy）。
- 排查競態條件（Race Conditions）、死鎖（Deadlock）、`async void` 未捕捉例外、事件重複訂閱未退訂（導致記憶體洩漏）以及 `IDisposable` / 智慧指標 / 句柄（Handle/Stream/USB Pipe）的釋放完整性。

### 4. 資料邊界、編碼與安全性 (Bounds, Encoding & Safety)
- 逐一核對空值（Nullability）、範圍、長度、陣列索引越界、整數溢位/截位、字串編碼（UTF-8/ASCII/Unicode）、大小端（Endianness）、結構體對齊（Struct Packing）與格式版本相容性。
- 檢查日誌完整性與敏感資訊安全性。

### 5. 桌面 UI 與 MVVM 專項檢查 (WPF / C# / Desktop UI)
- 檢查 `View` / `ViewModel` / `Service` / `DI` 綁定關係與生命週期。
- 檢查跨執行緒更新 UI 是否正確透過 `Dispatcher`（或 `SynchronizationContext`），避免背景執行緒直接操作 `ObservableCollection` 或 UI 元件引發崩潰。
- 檢查 `ICommand` 的 `CanExecute` 狀態同步、屬性變更通知（`INofityPropertyChanged`）是否觸發無限迴圈或高頻重繪。
- **鐵則**：不得為了修改方便而將既有 UI/MVVM 架構全部推翻重寫。

## 二、 變更與驗證原則
1. 先查明現有測試、建置方式（MSBuild / .NET CLI / CMake / Make / pytest / npm）、靜態分析與專案命名慣例。
2. 優先採用**最小、可回滾、可驗證**的變更。
3. 維持既有功能與公共 API 簽章，除非使用者明確批准破壞性調整（Breaking Changes）。
4. 詳細逐項檢查請對照 `resources/software-checklist.md`。

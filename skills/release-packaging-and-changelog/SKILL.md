---
name: release-packaging-and-changelog
description: 軟體執行檔與 RTL/FPGA 燒錄檔之版本發布門檻、SW↔FW↔RTL 相容矩陣與雙向追溯、SHA256 校驗、發布套件打包與 Release Notes/Change_Log 自動紀錄技能。當準備發布版本、整理燒錄檔/執行檔、建立 Git Tag、產出更新日誌或盤點版本對應關係時自動調用。
---

# Release Packaging, Artifact Traceability & Changelog（版本發布打包、燒錄與執行檔追溯暨日誌生成技能）

當使用者準備為**軟體專案（`.exe` / `.msi` / `.zip` / 安裝包）**、**韌體（`.hex` / `.bin` / `.elf`）**或**硬體 RTL/FPGA（`.bit` / `.mcs` / `.bin` / `.sof` / `.pof` / `.pdi` / `.ltx`）**發布版本、整理交付物、產出更新功能說明與版本對應紀錄時，自動調用本技能，確保「每個發布檔案都能反查確切 Git Commit、通過品質門檻、且絕不遺漏更新說明與硬軟韌相容邊界」。

---

## 一、 核心發布鐵則（Protected Invariants）

1. **Clean Worktree 發布門檻**：正式版（GA）嚴禁在含有未提交改動（Dirty Worktree）的狀態下打包，確保每個交付檔可 100% 追溯到唯一 `commit_sha`（僅本技能腳本的 `-AllowDirty` / `--allow-dirty` 允許用於內部草稿測試，且 Manifest 必須標記 `is_dirty: true`）。
2. **大型二進位檔不汙染 Git 歷史**：`.bit`、`.mcs`、`.bin`、`.sof`、`.exe`、`.msi`、`.zip` 等交付物**禁止直接 `git add` 進程式碼分支**；本機發布套件統一輸出至已加入 `.gitignore` 的 `releases/<Project>_<Version>/`（或由使用者上傳至 GitHub Releases），Git 倉庫僅追蹤輕量化 `docs/releases/<Version>_Release_Notes.md`、`release-manifest.json`（或歸檔於 `docs/releases/`）、`Change_Log.md`（嚴格 Append-Only）與 Annotated Git Tag。
3. **禁止捏造或美化未驗證狀態**：若 RTL STA 尚未確認 `WNS >= 0` / `TNS == 0`，或尚未完成實體板端燒錄與軟體聯測，**嚴禁宣稱為正式版（GA）或填寫 `PASS`**；必須誠實標記 `NOT RUN` / `BLOCKED` 並將版本號降級為 `-rc.N` 預發布版。
4. **雙軌版本與 SW ↔ FW ↔ RTL 可追溯性**：允許 Host 軟體、MCU 韌體與 FPGA RTL 各自演進獨立版號，但每次系統對外發布必須建立統一 Release Tag（`vMAJOR.MINOR.PATCH` 或 `-rc.N`），明確列出最低相容版本並核對執行時期可讀的版本指紋。

---

## 二、 5 步標準發布流水線（Release Pipeline）

### Step 1 — 發布前守門檢查（Release Gate）
依據 `resources/release-checklist.md` 與專案實證技術棧執行前檢（優先調用專案在地的 `.agents/skills/verify-<project>/`）：
1. **Git 與工作區狀態**：確認 `git status --short` 潔淨，且專案 `.gitignore` 已排除 `releases/` 與大型二進位副檔名。
2. **Software / Host 端檢查**：
   - Release 組態編譯無新增警告/錯誤，核心 Unit/Integration Tests 與靜態檢查 `PASS`。
   - 確認二進位檔內嵌版號（`AssemblyVersion` / `ProductVersion` / `package.json` / `__version__` / CLI `--version`）與本次版號一致。
3. **Firmware 端檢查（若適用）**：
   - 輸出 `.hex`/`.bin`/`.elf` 並核對 Flash/RAM 使用率、Bootloader Header/CRC 及韌體版號常數。
4. **RTL / FPGA 端檢查（若適用）**：
   - 確認目標 FPGA 元件型號、封裝與腳位約束（`.xdc` / `.qsf`）與最新硬體版本一致。
   - 確認 Synthesis & Implementation 完成，**STA 靜態時序滿足 `WNS >= 0`、`TNS == 0`、`WHS >= 0`、`THS == 0`**，CDC/Reset 無未豁免違規。
   - 確認讀寫暫存器（如 `HW_VER`、`GIT_HASH`、`BUILD_TIMESTAMP`）已注入本次或對應基底版本資訊；若含 ILA 除錯核，同步備齊 `.ltx` 探針檔。

### Step 2 — 版本號決策與 SW ↔ FW ↔ RTL 相容矩陣核對
1. 依 SemVer 決定本次發布版號：
   - **MAJOR**（`vX.0.0`）：跨層協定/暫存器定義不相容變更、腳位重大更動或軟體架構破壞性升級；
   - **MINOR**（`vX.Y.0`）：向下相容之新功能或性能優化；
   - **PATCH**（`vX.Y.Z`）：向下相容之 Bug 修復；
   - **`-rc.N` 後綴**：程式碼或綜合已完成，但實體上板/長期壓測尚未完成（`NOT RUN` / `BLOCKED`）。
2. 建立或更新 **SW ↔ FW ↔ RTL 相容矩陣**（見 `resources/release-manifest-example.json`），寫明最低相容下限（如 `min_compatible_fw`、`min_compatible_rtl`），避免現場混燒造成系統死鎖。

### Step 3 — 執行打包腳本與 SHA-256 校驗鎖定
使用本技能提供的跨平台打包腳本，將分散在各編譯目錄的執行檔與燒錄檔集中至 `releases/<Project>_<Version>/`（自動避免覆蓋未授權目錄），一次計算 **SHA-256** 並生成 `SHA256SUMS.txt`、`release-manifest.json` 與自上個 Tag 以來提交紀錄之 `Release_Notes_DRAFT.md`：
- **Windows (PowerShell)**：
  ```powershell
  powershell -ExecutionPolicy Bypass -File "$HOME\.gemini\config\skills\release-packaging-and-changelog\scripts\create-release-bundle.ps1" -ProjectRoot . -Version v1.2.0 -ArtifactPaths ".\build\App.exe,.\fpga\out\top.bit,.\fpga\out\top.mcs"
  ```
- **macOS / Linux (Bash)**：
  ```bash
  bash "$HOME/.gemini/config/skills/release-packaging-and-changelog/scripts/create-release-bundle.sh" . v1.2.0 ./build/app ./fpga/out/top.bit ./fpga/out/top.mcs
  ```
*(若所有交付檔位於單一輸出資料夾，Windows 可改傳 `-ArtifactDir "<輸出目錄>"`；若於無 `~/.gemini/config` 的獨立測試環境，請改用本技能目錄下的 `scripts/create-release-bundle.ps1` / `.sh`。)*

### Step 4 — 產出正式 Release Notes、Append-Only `Change_Log.md` 與 SSOT 同步
1. 依 `resources/release-notes-template.md` 審閱並補全腳本產出的草稿，將最終版本存檔至專案受 Git 追蹤的 `docs/releases/<Version>_Release_Notes.md`（同步保留副本於 `releases/<Project>_<Version>/Release_Notes.md`），內容必須包含：
   - **更新摘要 / 新功能 / 問題修復 / Breaking Changes**；
   - **SW ↔ FW ↔ RTL 相容矩陣與讀取指紋**；
   - **各交付檔案名稱、用途（JTAG vs QSPI Flash / Host 安裝）、檔案大小與 SHA-256**；
   - **各項測試與實測真實狀態（`PASS` / `FAIL` / `NOT RUN` / `BLOCKED`）與 STA `WNS`/`TNS`**；
   - **安裝／燒錄 SOP 與緊急退版回滾步驟（Rollback SOP）**。
2. 嚴格以 **APPEND ONLY** 方式將本次發布摘要追加至專案 `Change_Log.md` 最末尾（絕對禁止修改既有歷史行），並視需要更新 `VerificationCoverageMatrix.md` 與 `docs/Feature_Map.md`。
3. 依據 `../observed-baseline-and-ssot-sync/SKILL.md` 執行最後一次 SSOT 核對，確保暫存器手冊、`README.md` 版本號與本次發布一致。

### Step 5 — Git 提交、Annotated Tag 與選擇性 GitHub Release
1. 提交輕量受追蹤資產（`docs/releases/`、`Change_Log.md`、`VerificationCoverageMatrix.md`、`release-manifest.json` 副本等），建立帶完整資訊的 Annotated Tag：
   ```bash
   git tag -a vX.Y.Z -m "Release vX.Y.Z (SW x.y.z / FW a.b.c / RTL m.n.p)"
   ```
2. 推送主分支與 Tag 至遠端倉庫（`git push origin main` 與 `git push origin vX.Y.Z`）。
3. 若團隊使用 GitHub Releases 託管大型 `.exe`/`.bit`/`.mcs` 交付檔，可於驗證通過並經使用者授權後，執行 `gh release create vX.Y.Z releases/<Project>_vX.Y.Z/* --notes-file docs/releases/vX.Y.Z_Release_Notes.md` 將發布包掛載為 Release Assets（或依專案需求加上 `--prerelease`）。

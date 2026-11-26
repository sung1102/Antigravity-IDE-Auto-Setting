# Release Pre-Flight Checklist（SW / FW / RTL 發布前守門清單）

每次準備對外發布或內部交付燒錄檔／執行檔前，依序核對以下項目；任一紅線未過不得宣稱正式版（GA）。

---

## 1. 版本控制與倉庫潔淨度（Git & Clean Worktree）
- [ ] `git status --short` 無未提交修改（Dirty Worktree 嚴禁打包正式版，確保 `commit_sha` 可重現）。
- [ ] 專案 `.gitignore` 已排除 `releases/` 及大型二進位檔（`*.bit`, `*.mcs`, `*.bin`, `*.sof`, `*.pof`, `*.pdi`, `*.exe`, `*.msi`, `*.zip`），不汙染 Git 歷史。
- [ ] `Change_Log.md` / `CHANGELOG.md` 準備以 **APPEND ONLY** 追加本次版本條目（禁止修改歷史行）。

## 2. 軟體端（Host / Desktop / API / CLI）
- [ ] 以 Release 組態編譯完成，無新增致命警告或未處理例外路徑。
- [ ] 自動化單元測試／整合測試／`.agents/skills/verify-<project>/` 全部實跑 `PASS`（不可僅跑 Debug Mock 就代稱整合通過）。
- [ ] 二進位內嵌版號（`AssemblyVersion` / `ProductVersion` / `package.json` / `pyproject.toml` / `--version`）與本次發布版號一致。
- [ ] 相依函式庫或驅動（如 FTDI D3XX/D2XX、VC++ Redistributable、.NET Runtime、USB 驅動版號）已於 Release Notes 明確列出需求。

## 3. 韌體端（MCU / Embedded FW，若適用）
- [ ] Release 編譯完成並產出指定格式（`.hex` / `.bin` / `.elf` / `.img`）。
- [ ] 檢查 Linker Map 的 Flash / RAM 使用率與 Stack Margin 在安全上限內。
- [ ] Bootloader Header / CRC / 韌體版號常數正確寫入且可透過查詢指令回讀。
- [ ] 與上位機（SW）及 FPGA（RTL）之封包結構／Register Map 版號相容確認完成。

## 4. 硬體 / RTL / FPGA 端（若適用）
- [ ] Target Device（元件型號、速度等級、封裝）與載板硬體版本（Board Rev）確認無誤。
- [ ] 腳位約束（`.xdc` / `.qsf`）與時脈約束已鎖定且與最新原理圖一致。
- [ ] 綜合（Synthesis）與布局布線（Implementation / Place & Route）無未審查之 Latch、Critical Warning 或多驅動衝突。
- [ ] **STA 靜態時序收斂確認**：
  - [ ] Setup：`WNS >= 0.000 ns` 且 `TNS == 0.000 ns`
  - [ ] Hold：`WHS >= 0.000 ns` 且 `THS == 0.000 ns`
- [ ] CDC（跨時脈域）與 Reset 同步器報告已審核完畢（`async_reg` 與 false path / max_delay 約束正確）。
- [ ] 已同時產出所有必要燒錄檔（例如：JTAG 除錯 `.bit`、QSPI Flash 固化 `.mcs`/`.bin`、ILA 探針 `.ltx` 視需要）。
- [ ] RTL 唯讀識別暫存器（如 `HW_VER`、`GIT_HASH`、`BUILD_TIMESTAMP`）已反映本次建置版本，可供上位機軟體讀取驗證。

## 5. 上板聯合驗證與誠實狀態規範
- [ ] SW ↔ FW ↔ RTL 全鏈路實體上板驗證結果：
  - 若實測完整通過 → 可發布為 `vX.Y.Z`（GA 正式版）。
  - 若硬體不在手邊、尚未燒錄或僅完成模擬 → 誠實標為 `NOT RUN` / `BLOCKED`，版本號必須加上 `-rc.N`（如 `v1.2.0-rc1`）並於 Release Notes 註明風險。

## 6. 交付封存與回滾準備
- [ ] 透過 `create-release-bundle.ps1` / `.sh` 產出 `SHA256SUMS.txt` 與 `release-manifest.json`。
- [ ] 已在 `docs/releases/<Version>_Release_Notes.md` 寫明燒錄步驟（Flash 型號、位址、SPI 模式或安裝精靈步驟）。
- [ ] 已備妥「上一穩定版本號與對應燒錄/安裝檔」於回滾章節，確保現場異常時可快速退版。

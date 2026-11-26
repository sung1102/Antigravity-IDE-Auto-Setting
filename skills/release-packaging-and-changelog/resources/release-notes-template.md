# Release Notes — <Project_Name> <vX.Y.Z>

- **發布日期**：`YYYY-MM-DD HH:mm (UTC+08:00)`
- **發布類型**：`GA 正式版` / `Pre-release 候選版 (-rc.N)`
- **Git 基準提交**：`<short_sha>`（完整 SHA：`<commit_sha>`，分支：`<branch>`，上一版本 Tag：`<previous_tag>`）
- **發布摘要（一句話說明本次核心價值）**：`<說明本次版本解決了什麼核心問題或新增什麼關鍵能力>`

---

## 一、 軟硬韌版本對應與相容矩陣（SW ↔ FW ↔ RTL Compatibility）

| 層級 / 元件 | 本次發布版號 / 識別碼 | 內嵌可讀指紋（Runtime / Register） | 最低相容限制 / 備註 |
|---|---|---|---|
| **Software（上位機）** | `<e.g. v1.2.0>` | `About / --version` = `<1.2.0>` | 需搭配 FW `>= 1.1.0`、RTL `HW_VER >= 0x0102` |
| **Firmware（MCU 韌體）** | `<e.g. v1.1.2 / N/A>` | `GET_FW_VER` = `<0x010102>` | `<封包協定 v2.0>` |
| **RTL / FPGA（硬體邏輯）** | `<e.g. HW_VER 0x0102>` | `REG 0x00 HW_VER` = `<0x00010200>` / `GIT_HASH` = `<short_sha>` | Target: `<e.g. xc7a100tfgg484-2>` |

---

## 二、 交付檔案與 SHA-256 校驗清單

> [!IMPORTANT]
> 部署或燒錄前，務必比對檔案的 **SHA-256 校驗碼**（比對同資料夾內 `SHA256SUMS.txt`），確保檔案傳輸過程未損毀或錯用舊檔。

| 檔名 | 類型 / 用途 | 適用目標 / 燒錄設定 | 檔案大小 (Bytes) | SHA-256 |
|---|---|---|---|---|
| `<App_vX.Y.Z.exe>` | Software 執行檔 / 安裝包 | Windows 10/11 x64 | `<size>` | `<sha256>` |
| `<top_vX.Y.Z.bit>` | FPGA SRAM 暫存燒錄檔 | JTAG 線上測試（斷電失效） | `<size>` | `<sha256>` |
| `<top_vX.Y.Z.mcs>` | FPGA Flash 固化映像檔 | QSPI Flash (`SPIx4`, offset `0x00000000`) | `<size>` | `<sha256>` |
| `<top_vX.Y.Z.ltx>` | ILA 除錯探針檔（選用） | Vivado Hardware Manager | `<size>` | `<sha256>` |

---

## 三、 更新內容詳情（Changelog Details）

### 1. 新增功能（Added）
- **[SW/FW/RTL]** `<功能描述與對應檔案/模組>`

### 2. 問題修復（Fixed）
- **[SW/FW/RTL]** `<修復症狀、根因與改善結果>`

### 3. 優化與架構調整（Changed / Improved）
- **[SW/FW/RTL]** `<效能、時序裕量、或介面穩定性提升說明>`

### 4. 重大變更與升級注意（Breaking Changes / Migration Notes）
- `<若無破壞性變更請寫「無」；若有則明確說明協定欄位、暫存器位址或設定檔遷移方式>`

---

## 四、 驗證狀態與實測證據（Verification & Timing Summary）

| 檢查項目 | 狀態 | 實測關鍵數據 / 備註 |
|---|---|---|
| **軟體建置與自動化測試** | `PASS` / `FAIL` / `NOT RUN` | `<測試工具、案例數與結果摘要>` |
| **RTL 模擬（Testbench）** | `PASS` / `NOT RUN` / `N/A` | `<覆蓋項目與波形檢查結果>` |
| **FPGA 綜合與 STA 時序收斂** | `PASS` / `NOT RUN` / `N/A` | `WNS = <x.xxx> ns`, `TNS = <0.000> ns`, `WHS = <x.xxx> ns`, `THS = <0.000> ns` |
| **實體板端聯調（SW + FW + RTL）** | `PASS` / `NOT RUN` / `BLOCKED` | `<硬體實測項目或未測試風險說明>` |

---

## 五、 安裝／燒錄作業與快速回滾步驟（Install, Flash & Rollback SOP）

### A. 安裝／燒錄步驟
1. 下載發布套件並驗證 `SHA256SUMS.txt` 無誤。
2. **FPGA / 韌體端**：透過 `<Vivado Hardware Manager / Quartus Programmer / DFU 工具>` 將 `<*.mcs / *.bit / *.hex>` 燒錄至目標晶片，斷電重啟後讀取 `HW_VER` / `GIT_HASH` 確認更新成功。
3. **軟體端**：關閉舊版程式後執行 `<App_vX.Y.Z.exe>`（確認 `.NET / 驅動` 已安裝），連線後核對畫面顯示的軟硬韌版本一致。

### B. 異常緊急回滾（Rollback SOP）
- 若現場發現不相容或異常，立即停止擴散，並從上一穩定版本（Tag: `<previous_tag>`，套件目錄 `releases/<Project>_<previous_tag>/`）執行退版：
  1. 重新燒錄舊穩定版 Flash 映像檔 `<prev_top.mcs>` 並重新上電；
  2. 降回舊版執行檔 `<Prev_App.exe>`；
  3. 記錄現場異常現象、時間與 `release-manifest.json` 內容以利 `TRACE_ONLY` 追查。

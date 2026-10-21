# Antigravity-IDE-Auto-Setting

本倉庫存放 Antigravity / Antigravity IDE 的**全域工程審核規則（Global Rules）、技能組（Global Skills）與專案導入通用提示詞手冊（Templates）**，適用於跨軟體（C# / WPF / C++ / Python）、韌體、通訊協定（USB / eDP / I2C / SPI / Register Map）與硬體 RTL（Verilog / SystemVerilog / VHDL / FPGA）專案。

---

## 一、 目錄結構

掛載至本機 `~/.gemini/config` 後，目錄結構如下：

```text
~/.gemini/config/
├── README.md                                              # 跨電腦掛載、同步與手冊導覽
├── templates/
│   └── project-onboarding-prompts.md                      # 三大情境專案導入通用提示詞手冊 (含 XXXX 填空範本)
├── rules/
│   └── engineering-governance.md                          # 全域工程治理規則 (trigger: always_on)
└── skills/
    ├── engineering-review-orchestrator/                   # A. 主控調度技能
    │   ├── SKILL.md
    │   └── resources/
    │       ├── trace-report-template.md
    │       └── change-plan-template.md
    ├── software-architecture-review/                      # B. 軟體架構審核技能
    │   ├── SKILL.md
    │   └── resources/
    │       └── software-checklist.md
    ├── rtl-hardware-review/                               # C. RTL 與硬體審核技能
    │   ├── SKILL.md
    │   └── resources/
    │       └── rtl-checklist.md
    ├── protocol-stack-contract-review/                    # D. 通訊協定契約審核技能
    │   ├── SKILL.md
    │   └── resources/
    │       └── protocol-checklist.md
    └── change-safety-and-verification/                    # E. 變更安全、版本備份與驗證技能
        ├── SKILL.md
        └── resources/
            └── verification-template.md
```

---

## 二、 如何使用「專案導入通用提示詞手冊」

當您要啟動專案時，打開 `~/.gemini/config/templates/project-onboarding-prompts.md`，依情境複製範本，填入對應的專案資訊即可：

| 情境編號 | 適用場景 | 核心動作 |
|---|---|---|
| **情境 1** | 全新專案開發 | 建立專案骨幹、初始化 Git、綁定 GitHub 私人庫、產生 `GEMINI.md` |
| **情境 2** | 舊專案納管至 GitHub | Git 基準建置、唯讀逆向分析、產出 `docs/` 01~03 架構/通訊文件並推送 |
| **情境 3** | 現有專案升級 AI 規範 | 保留原始功能，升級 `GEMINI.md`、`Change_Log.md` 與驗證覆蓋矩陣 |

所有範本內的 `XXXX` 均為填空佔位符，替換為實際名稱後直接貼入 Antigravity IDE 對話框即可執行。

---

## 三、 工程安全與版本回滾原則（Git 優先，嚴禁重複實體拷貝）

日常開發或變更時，全域技能遵循嚴格互斥的回滾原則：
1. **以 Git 分支/標籤為唯一回滾機制**：
   - 只要專案已具備 Git 或即將初始化 Git，**一律使用 Git 分支（`backup/<Project_Key_Name>_YYYYMMDD_HHMMSS`）或標籤作為備份回滾點，嚴禁在本地硬碟複製任何實體備份資料夾**（避免大型 FPGA/桌面應用耗損磁碟空間與 I/O）。
2. **實體資料夾備份之唯一例外**：
   - 僅當專案無 Git 且使用者明確指示不使用 Git 時，才允許建立本機帶時間戳的實體資料夾備份作為最後保底手段。

---

## 四、 在新電腦上一鍵掛載

換到新電腦時，在終端機執行對應指令即可完成部署：

### Windows (PowerShell)
```powershell
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
if (Test-Path "$HOME\.gemini\config") { Move-Item "$HOME\.gemini\config" "$HOME\.gemini\backup_$timestamp" }
git clone https://github.com/sung1102/Antigravity-IDE-Auto-Setting.git "$HOME\.gemini\config"
```

### macOS / Linux (Bash)
```bash
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
[ -d "$HOME/.gemini/config" ] && mv "$HOME/.gemini/config" "$HOME/.gemini/backup_$TIMESTAMP"
git clone https://github.com/sung1102/Antigravity-IDE-Auto-Setting.git "$HOME/.gemini/config"
```

---

## 五、 跨電腦同步更新

- **在新電腦拉取最新設定與手冊**：
  ```bash
  cd ~/.gemini/config && git pull origin main
  ```
- **推送修改後的設定或範本**：
  ```bash
  cd ~/.gemini/config && git add . && git commit -m "chore: update config" && git push origin main
  ```

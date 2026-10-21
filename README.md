# Antigravity-IDE-Auto-Setting

本倉庫存放 Antigravity / Antigravity IDE 的**全域工程審核規則（Global Rules）與技能組（Global Skills）**，適用於跨軟體（C# / WPF / C++ / Python）、韌體、通訊協定（eDP / USB / I2C / SPI / Register Map）與硬體 RTL（Verilog / SystemVerilog / VHDL / FPGA）專案。

---

## 一、 目錄結構

將本倉庫掛載至使用者家目錄下的 `~/.gemini/config` 後，結構如下：

```text
~/.gemini/config/
├── README.md                                              # 跨電腦掛載與同步說明
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
    └── change-safety-and-verification/                    # E. 變更安全、同名備份與驗證技能
        ├── SKILL.md
        └── resources/
            └── verification-template.md
```

---

## 二、 在其他電腦（新電腦）一鍵掛載方式

Antigravity 的全域設定認本機的 `~/.gemini/config` 路徑。換到新電腦時，請任選以下一種方式掛載：

### 方式 1：直接貼提示詞給新電腦的 Antigravity IDE 自動掛載
打開新電腦的 Antigravity IDE（File -> Open Folder 開啟使用者家目錄），在 Agent 模式貼上：

> 請幫我將這台電腦的 Antigravity 全域設定（`~/.gemini/config`）掛載並同步自我的 GitHub 倉庫：`https://github.com/sung1102/Antigravity-IDE-Auto-Setting.git`
> 1. 若本機 `~/.gemini/config` 已存在，請先備份至 `~/.gemini/backup_YYYYMMDD_HHMMSS`。
> 2. 將 `https://github.com/sung1102/Antigravity-IDE-Auto-Setting.git` clone 到本機的 `~/.gemini/config`。
> 3. 驗證 `rules/` 與 `skills/` 底下的檔案皆已就緒並向我回報。

### 方式 2：使用終端機指令快速掛載

#### Windows (PowerShell)
```powershell
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
if (Test-Path "$HOME\.gemini\config") {
    Move-Item "$HOME\.gemini\config" "$HOME\.gemini\backup_$timestamp"
}
git clone https://github.com/sung1102/Antigravity-IDE-Auto-Setting.git "$HOME\.gemini\config"
```

#### macOS / Linux (Bash)
```bash
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
if [ -d "$HOME/.gemini/config" ]; then
    mv "$HOME/.gemini/config" "$HOME/.gemini/backup_$TIMESTAMP"
fi
git clone https://github.com/sung1102/Antigravity-IDE-Auto-Setting.git "$HOME/.gemini/config"
```

---

## 三、 日常跨電腦同步更新指令

- **拉取最新規則與技能（在其他電腦）**：
  ```bash
  cd ~/.gemini/config && git pull origin main
  ```
- **推送修改後的規則與技能**：
  ```bash
  cd ~/.gemini/config
  git add .
  git commit -m "chore: update engineering skills"
  git push origin main
  ```

---

## 四、 專案開發與同名備份對應規則

日常開啟任何工程專案時，Agent 會依 `change-safety-and-verification` 自動遵守**「同名一對一映射原則」**：
- **本地專案資料夾名稱（或主專案檔名）** = **GitHub 私人倉庫名稱** = **本地時間戳備份前綴名稱**（`<ProjectName>_backup_YYYYMMDD_HHMMSS`）。
- 人工查閱時可直接以專案名稱在本地端與 GitHub 遠端之間一對一直覺檢索。

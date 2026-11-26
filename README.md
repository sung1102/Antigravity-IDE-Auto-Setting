# Antigravity-IDE-Auto-Setting

本倉庫存放 Antigravity / Antigravity IDE 的**全域工程審核規則（Global Rules）、技能組（Global Skills）與專案導入通用提示詞手冊（Templates）**，適用於跨軟體（C# / WPF / C++ / Python）、韌體、通訊協定（USB / eDP / I2C / SPI / Register Map）與硬體 RTL（Verilog / SystemVerilog / VHDL / FPGA）專案。

---

## 一、 目錄結構

掛載至本機 `~/.gemini/config` 後，目錄結構如下：

```text
~/.gemini/config/
├── README.md                                              # 跨電腦掛載、架構總覽與手冊導覽
├── .gitattributes                                         # 跨平台行尾規範（.sh/.githooks=LF, .ps1/.md=CRLF）
├── .githooks/
│   └── pre-commit                                         # Git 提交自動門檻（呼叫 scripts/verify-repo.ps1）
├── .agents/
│   └── skills/
│       └── verify-antigravity-ide-auto-setting/
│           └── SKILL.md                                   # 本倉庫專屬自我驗證技能 (Dogfooding Lever)
├── docs/
│   ├── Architecture_and_Workflow.md                       # 技能應用架構圖、五階段閉環流程與詳細說明
│   └── Feature_Map.md                                     # 本倉庫行為級功能與驗證地圖
├── scripts/
│   ├── sync-config.ps1                                    # Windows 無損掛載與 V1->V2 升級工具（保留自建技能與 MCP）
│   ├── sync-config.sh                                     # macOS / Linux 無損掛載與 V1->V2 升級工具
│   └── verify-repo.ps1                                    # 本倉庫一鍵靜態驗證槓桿（支援 -TrackedOnly）
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
    ├── change-safety-and-verification/                    # E. 變更安全、版本備份與驗證技能
    │   ├── SKILL.md
    │   └── resources/
    │       └── verification-template.md
    ├── observed-baseline-and-ssot-sync/                   # F. 實測原樣仿照與 SSOT 回溯同步技能
    │   ├── SKILL.md
    │   └── resources/
    │       ├── baseline-ssot-checklist.md
    │       └── suspicious-behavior-report-template.md
    └── verification-harness-builder/                      # G. 專案驗證槓桿、Feature Map 與錯誤硬化技能
        ├── SKILL.md
        └── resources/
            ├── feature-map-template.md
            ├── verify-skill-template.md
            └── guardrail-snippets.md
```

---

## 二、 技能應用架構與核心流程總覽

本套件採 **「全域長駐紅線 → 主控調度 → 領域／治理技能 → 專案在地驗證槓桿」** 分層運作，完整架構圖、各技能詳細觸發條件與實戰路線請見 [`docs/Architecture_and_Workflow.md`](docs/Architecture_and_Workflow.md)：

```text
[rules/engineering-governance.md (Always-On) + 專案 GEMINI.md]
        │
        ▼
[engineering-review-orchestrator] ──► 自動判定 MODE: TRACE_ONLY -> PLAN_ONLY -> IMPLEMENT -> VERIFY_ONLY
        │
        ├── 依技術棧調度領域審查：software-architecture-review / rtl-hardware-review / protocol-stack-contract-review
        ├── 實測仿照與防漂移　：observed-baseline-and-ssot-sync（先 100% 原樣仿照；可疑退回 PLAN_ONLY；Tier 1>2>3 回溯同步）
        ├── 版本與最小變更安全：change-safety-and-verification（Git-only 回滾、Unslop、Change_Log Append-Only）
        └── 專案驗證槓桿建置　：verification-harness-builder
                                 └── 產出專案在地 docs/Feature_Map.md + .agents/skills/verify-* + 硬性 Lint/Hook 門檻
```

---

## 三、 如何使用「專案導入通用提示詞手冊」

當您要啟動專案時，打開 `~/.gemini/config/templates/project-onboarding-prompts.md`，依情境複製範本，填入對應的專案資訊即可：

| 情境編號 | 適用場景 | 核心動作 |
|---|---|---|
| **情境 1** | 全新專案開發 | 建立專案骨幹與編譯/Lint 門檻、初始化 Git、綁定 GitHub 私人庫、產生 `GEMINI.md`、`docs/Feature_Map.md` 與 `.agents/skills/verify-*` |
| **情境 2** | 舊專案納管至 GitHub | Git 基準建置、唯讀逆向分析、產出 `docs/` `01~04` 架構/通訊/Feature Map 文件、`.agents/skills/verify-*` 並推送 |
| **情境 3** | 現有專案升級 AI 規範 | 保留原始功能，升級 `GEMINI.md`、`docs/Feature_Map.md`、`.agents/skills/verify-*`、`Change_Log.md`、驗證覆蓋矩陣與錯誤硬化檢查 |

所有範本內的 `XXXX` 均為填空佔位符，替換為實際名稱後直接貼入 Antigravity IDE 對話框即可執行。

---

## 四、 工程安全與版本回滾原則（Git 優先，嚴禁重複實體拷貝）

日常開發或變更時，全域技能遵循嚴格互斥的回滾原則：
1. **以 Git 分支/標籤為唯一回滾機制**：
   - 只要專案已具備 Git 或即將初始化 Git，**一律使用 Git 分支（`backup/<Project_Key_Name>_YYYYMMDD_HHMMSS`）或標籤作為備份回滾點，嚴禁在本地硬碟複製任何實體備份資料夾**（避免大型 FPGA/桌面應用耗損磁碟空間與 I/O）。
2. **實體資料夾備份之唯一例外**：
   - 僅當專案無 Git 且使用者明確指示不使用 Git 時，才允許建立本機帶時間戳的實體資料夾備份作為最後保底手段。

---

## 五、 跨電腦首次掛載與 V1 → V2 升級（不刪除自建技能與 MCP）

請記住一個核心順序：**先更新電腦上的 `~/.gemini/config`（共用大腦），再去開各專案套用提示詞**。
本倉庫內建跨平台無損同步工具（`scripts/sync-config.ps1` / `scripts/sync-config.sh`），會**完整保留**該電腦原有的 `mcp_config.json`、`config.json`、`plugins/`、`projects/` 以及**未與官方撞名的個人自建技能（如 `skills/<your-custom-skill>/`）**，不再整包搬走資料夾。

### 情況 A：已用 Git 掛載過舊版（V1 → V2 一鍵升級）
直接在該電腦執行一行同步工具即可升級並自動啟用 `.githooks` 與驗證（`-TrackedOnly` 會忽略您的額外自建技能，不會誤報錯誤）：
- **Windows (PowerShell)**：
  ```powershell
  powershell -ExecutionPolicy Bypass -File "$HOME\.gemini\config\scripts\sync-config.ps1"
  ```
- **macOS / Linux (Bash)**：
  ```bash
  bash "$HOME/.gemini/config/scripts/sync-config.sh"
  ```
*(若該電腦曾直接修改過官方追蹤檔，工具會安全中止並列出清單保護您的修改；確認覆蓋升級可加上 `-BackupOnLocalModify` / `--backup-on-local-modify` 先自動備份再升級。)*

### 情況 B：全新電腦，或曾經手動複製舊版 V1（沒有 `.git`）的電腦
執行下方單行指令，會先下載至暫存並**原位無損接管 `~/.gemini/config`**（僅備份撞名的舊版官方檔至 `~/.gemini/backup_pre_mount_*`，自建技能與 `mcp_config.json` 原封不動）：
- **Windows (PowerShell)**：
  ```powershell
  $t="$env:TEMP\agy-cfg-$(Get-Date -Format 'yyyyMMddHHmmss')"; git clone https://github.com/sung1102/Antigravity-IDE-Auto-Setting.git $t; if ($LASTEXITCODE -eq 0) { powershell -ExecutionPolicy Bypass -File "$t\scripts\sync-config.ps1" }; if (Test-Path $t) { Remove-Item -Recurse -Force $t }
  ```
- **macOS / Linux (Bash)**：
  ```bash
  t="$(mktemp -d)" && git clone https://github.com/sung1102/Antigravity-IDE-Auto-Setting.git "$t" && bash "$t/scripts/sync-config.sh" && rm -rf "$t"
  ```

### 情況 C：分享給他人／團隊其他開發者使用
- 由於 `https://github.com/sung1102/Antigravity-IDE-Auto-Setting.git` 為私人倉庫，對方電腦須具備存取權限（或指定內部鏡像／隨身碟路徑）：
  ```powershell
  powershell -ExecutionPolicy Bypass -File ".\scripts\sync-config.ps1" -RepoUrl "<團隊倉庫網址或本機路徑>"
  ```

---

## 六、 維護本規則庫與手動自檢

- **修改規則、技能或範本後跑一鍵自檢**（Windows PowerShell；已啟用 `.githooks/pre-commit` 時 `git commit` 亦會自動攔截）：
  ```powershell
  powershell -ExecutionPolicy Bypass -File .\scripts\verify-repo.ps1
  ```
- **推送修改後的設定或範本**（PowerShell）：
  ```powershell
  git -C "$HOME\.gemini\config" status -sb; git -C "$HOME\.gemini\config" add .; git -C "$HOME\.gemini\config" commit -m "chore: update config"; git -C "$HOME\.gemini\config" push origin main
  ```

# Deterministic Guardrail Snippets（跨技術棧決定性護欄實戰範本）
> 用途：當專案出現重複錯誤（第 2 次以上），依 `verification-harness-builder` 禁止只補寫 Markdown 警告，應選用下方對應技術棧的硬性護欄，讓違反規範時由工具直接阻斷（Non-zero Exit Code）。

---

## 1. Git `pre-commit` Hook 範本（阻斷未通過自檢的提交）
將以下內容放入專案的 `.git/hooks/pre-commit`（或版本控管 `.githooks/pre-commit` 搭配 `git config core.hooksPath .githooks`）：

```sh
#!/bin/sh
echo "[pre-commit] Running project verification lever..."
if [ -f "./scripts/verify-repo.ps1" ]; then
  powershell -ExecutionPolicy Bypass -File "./scripts/verify-repo.ps1" || exit 1
elif [ -f "./scripts/verify.ps1" ]; then
  powershell -ExecutionPolicy Bypass -File "./scripts/verify.ps1" || exit 1
elif [ -f "./Makefile" ] && grep -q "^verify:" ./Makefile; then
  make verify || exit 1
fi
```

---

## 2. C# / .NET / WPF 嚴格門檻範本
### A. `Directory.Build.props`（編譯警告即錯誤 + Nullable 強制檢查）
```xml
<Project>
  <PropertyGroup>
    <Nullable>enable</Nullable>
    <TreatWarningsAsErrors>true</TreatWarningsAsErrors>
    <AnalysisLevel>latest</AnalysisLevel>
    <EnforceCodeStyleInBuild>true</EnforceCodeStyleInBuild>
  </PropertyGroup>
</Project>
```

### B. `.editorconfig`（阻斷常見非同步與資源管理錯誤）
```ini
[*.cs]
# 建議搭配 Microsoft.VisualStudio.Threading.Analyzers（VSTHRD100 禁用 async void 等）
dotnet_diagnostic.CA2000.severity = error  # Dispose objects before losing scope
dotnet_diagnostic.CA2007.severity = warning
dotnet_diagnostic.CS4014.severity = error  # Missing await on async call
```

---

## 3. Verilog / SystemVerilog RTL Lint 與 Batch Simulation 範本
### A. 嚴格靜態 Lint 門檻（`verilator`）
```sh
verilator --lint-only -Wall -Werror-LATCH -Werror-WIDTH -Werror-PINMISSING -Irtl rtl/top.sv
```
- 物理阻斷：Inferred Latch（`LATCH`）、位寬不匹配截斷（`WIDTH`）、實例化漏接端口（`PINMISSING`）。

### B. Self-Checking Testbench Batch 驗收骨架（`iverilog` / `vvp`）
```powershell
$ErrorActionPreference = 'Stop'
iverilog -g2012 -Wall -o build/sim.vvp tb/tb_top.sv rtl/*.sv
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$out = vvp build/sim.vvp
$out | Write-Host
if ($LASTEXITCODE -ne 0 -or ($out -join "`n") -notmatch 'ALL_TESTS_PASSED') {
    Write-Error 'RTL simulation failed or ALL_TESTS_PASSED marker missing!'
    exit 1
}
```

---

## 4. Python / 後端服務快速門檻範本
```powershell
$ErrorActionPreference = 'Stop'
ruff check .
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
pytest -q
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
```

---

## 5. Antigravity 原生 `.agents/hooks.json` 生命週期護欄範本
> 說明：與僅在 `git commit` 觸發的 `.githooks/pre-commit` 不同，`.agents/hooks.json` 會在 Agent 工具執行前後與結束前**同步阻塞執行**（支援 `SessionStart`、`PreToolUse`、`PostToolUse`、`PreInvocation`、`PostInvocation`、`Stop`；僅建議放入快速低成本檢核，避免拖慢每輪推論）。

```json
{
  "post-edit-lint": {
    "PostToolUse": [
      {
        "matcher": "edit_file|write_file",
        "hooks": [
          {
            "type": "command",
            "command": "powershell -ExecutionPolicy Bypass -File ./scripts/quick-lint.ps1",
            "timeout": 15
          }
        ]
      }
    ]
  },
  "stop-verify-gate": {
    "enabled": false,
    "Stop": [
      {
        "type": "command",
        "command": "powershell -ExecutionPolicy Bypass -File ./scripts/check-stop-guard.ps1",
        "timeout": 15
      }
    ]
  }
}
```
- **注意事項**：
  - `Stop` Hook 若回傳 `{"decision": "continue", "reason": "..."}` 會強制 Agent 繼續迴圈；撰寫 `check-stop-guard` 腳本時務必檢查傳入 JSON 的 `continuationActive` 欄位，避免無窮迴圈。
  - Windows 環境中 `hooks.json` 的 `command` 係透過 `cmd /c` 執行（工作目錄為 `.agents/`），請確保腳本路徑與 exit code 處理相容。

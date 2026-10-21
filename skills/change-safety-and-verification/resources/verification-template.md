# Change & Verification Record Template（同名備份與驗證紀錄模板）
> 若專案已有特定紀錄格式，以專案規格與使用者要求優先，並明確指出差異。

## 1. 同名一對一映射備份表 (1-to-1 Named Backup Mapping)
| 識別維度 | 實際名稱 / 路徑（人工查閱對照） |
|---|---|
| **本地專案資料夾名稱 (`<Project_Key_Name>`)** | `<例如：Jupiter_eDP_Analyzer>` |
| **本地主專案檔案名稱** | `<例如：Jupiter_eDP_Analyzer.sln / .xpr>` |
| **對應 GitHub 私人倉庫名稱與網址** | `<例如：https://github.com/sung1102/Jupiter_eDP_Analyzer.git>` |
| **Git 備份分支 / Tag 名稱** | `backup/<Project_Key_Name>_YYYYMMDD_HHMMSS` |
| **本機時間戳備份完整路徑** | `<路徑>/<Project_Key_Name>_backup_YYYYMMDD_HHMMSS` |
| **基準版本 (Base Commit SHA)** | `<Commit Hash>` |
| **備份時間 (Timestamp)** | `YYYY-MM-DD HH:MM:SS` |
| **一鍵還原指令 (Rollback Command)** | `git checkout ...` 或 `Copy-Item ...` |

## 2. 修改檔案清單與相容性 (Modified Files & Compatibility)
| 檔案路徑 | 修改目的 | 影響範圍 / Symbol | 既有功能與公共 API 相容性 |
|---|---|---|---|
| | | | 完整保留 / 需注意：... |

## 3. 驗證執行結果 (Verification Execution Matrix)
| 驗證層級 (Build / Unit Test / Sim / Lint / Synth / Board) | 執行命令 | 狀態 (`PASS` / `FAIL` / `BLOCKED` / `NOT RUN`) | Exit Code | 真實證據摘要 (Log / 波形 / 報告路徑) |
|---|---|---|---|---|
| | | | | |

## 4. 文件更新與殘留風險 (Documentation & Residual Risks)
- **Change_Log.md 更新**：[ 已採 Append-Only 更新於末尾 | 本次無需更新 ]
- **VerificationCoverageMatrix.md 更新**：[ 已同步更新真實狀態 | 專案無此檔案 ]
- **待確認事項 / 板端實測需求 (`UNKNOWN / NOT PROVEN`)**：
  - 

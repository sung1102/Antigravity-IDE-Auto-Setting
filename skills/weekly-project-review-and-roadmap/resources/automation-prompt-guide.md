# `/automation` 每週自動週報排程設定指引

搭配 Antigravity 內建 `/automation` 指令，可讓系統每週固定時間在背景自動啟動獨立對話、執行 `weekly-project-review-and-roadmap` 並把週報寫進指定專案的 `docs/weekly/YYYY-Www.md`。

---

## 一、 建立步驟（在目標專案或任意對話中輸入 `/automation`）
1. 在 Antigravity 對話窗輸入 `/automation`。
2. 依精靈提示依序選擇：
   - **Cadence**：`Weekly`
   - **Day & Time**：例如每週五 `17:00`（週結）或每週一 `09:00`（週規劃），時區確認為 `Asia/Taipei`（`CRON_TZ=Asia/Taipei`）。
   - **Task Prompt**：貼入下方範本並將 `<專案絕對路徑>` 與 `<專案名稱>` 替換為真實值。
3. **關鍵步驟 — 同意進行一次「試跑（Test Run）」**：
   - 背景排程啟動後會自動拒絕未曾核准的終端命令。務必於精靈最後一步選擇試跑一次，讓系統自動記錄唯讀 Git、快照腳本與專案驗證指令的白名單權限，最後於 **Automations Dashboard** 啟用該排程即可。

---

## 二、 排程任務專用自我完結提示詞範本（Self-Contained Prompt）
> 注意：每次排程觸發皆為全新無歷史記憶的對話，因此提示詞必須寫明目標路徑、唯讀邊界與輸出檔案位置。

```text
請載入 ~/.gemini/config/skills/weekly-project-review-and-roadmap/SKILL.md，對專案「<專案名稱>」（根目錄：<專案絕對路徑>）執行每週唯讀盤點、驗證排查與下週規劃：

1. 嚴守唯讀原則：絕不可修改任何產品程式碼、RTL、組態檔或 Change_Log.md。
2. 先執行唯讀快照腳本收集近 7 天 Git 提交、VerificationCoverageMatrix.md 缺口、Feature_Map 與 TODO/FIXME 標記：
   powershell -ExecutionPolicy Bypass -File "$HOME\.gemini\config\skills\weekly-project-review-and-roadmap\scripts\collect-weekly-snapshot.ps1" -ProjectRoot "<專案絕對路徑>" -Days 7
3. 依專案現有驗證槓桿（.agents/skills/verify-*/ 或 scripts/verify*.ps1）實跑唯讀驗證取得真實健康狀態。
4. 依 weekly-review-template.md 產出完整週報（涵蓋本週進度、缺口漂移、P0~P2 優化建議與下週排程），並將報告儲存至 "<專案絕對路徑>/docs/weekly/<YYYY-Www>.md"（依當週 ISO 週數命名，不覆蓋過往週報）。
```

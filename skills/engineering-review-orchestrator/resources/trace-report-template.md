# Trace Report Template（唯讀追查報告模板）
> 若專案已有特定報告慣例，以專案規格與使用者要求優先，並明確指出差異。

## 1. 問題與邊界定義
- **專案關鍵名稱 (Project Key Name)**：`<本地資料夾或主專案檔名>`
- **觀察到的症狀 (Observed Symptom)**：
- **預期正常行為 (Expected Behavior)**：
- **不允許破壞的功能/介面 (Protected Invariants)**：
- **首個真實錯誤點 (First Root Error in Log/Trace)**：

## 2. 端到端證據鏈 (End-to-End Evidence Chain)
1. **入口點 (Entry Point)**：`檔案路徑:行號` → `Symbol/Module`
2. **中間傳遞 (Call / Data / Signal Path)**：`檔案路徑:行號` → `狀態轉換或訊號握手`
3. **異常發生點 (Failure Point)**：`檔案路徑:行號` → `具體條件或日誌輸出`

## 3. 事實分級 (Fact Classification)
- **[CONFIRMED 已確認事實]**（附直接程式碼行號、波形或 Log 證據）：
  - 
- **[INFERRED 合理推論]**（附推論邏輯與間接根據）：
  - 
- **[UNKNOWN / NOT PROVEN 未知或未證實]**（目前缺少的關鍵證據）：
  - 

## 4. 根因假設與排除過程 (Hypothesis & Elimination)
| 假設編號 | 假設內容 | 支持證據 | 反駁證據 | 當前狀態 (Confirmed / Eliminated / Pending) |
|---|---|---|---|---|
| H1 | | | | |
| H2 | | | | |

## 5. 下一個最具區辨力的檢查 (Next Discriminating Check)
- **檢查目標 Symbol / 訊號 / 暫存器**：
- **檢查方法（唯讀）**：
- **判定準則**：若觀察到 A 則證明 H1；若觀察到 B 則證明 H2。

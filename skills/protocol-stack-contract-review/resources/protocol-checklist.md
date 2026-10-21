# Protocol Stack & Register Contract Checklist
> 若本表與專案特定通訊規格書衝突，以專案規格與使用者明確要求為準，並於報告中註明差異。

## 1. 端到端鏈路與分層架構
- [ ] 是否已畫出「發起端 → AL → TL → HAL/Driver → 實體通道 → 韌體/RTL → 回應路徑」完整鏈路？
- [ ] 是否確認全程僅使用專案唯一的正式 Transaction API / Reader（無私自併發搶讀 Buffer）？

## 2. 封包格式與 Length 單位核對
- [ ] Header 中的 `Length` 單位是 Byte、Word 還是筆數？是否為 `N-1` 編碼？
- [ ] `Length` 是否計入 Header 本身與尾端 CRC？發送端與接收端解析公式是否 100% 對稱？
- [ ] 跨 16-bit / 32-bit 介面（如 USB 3.0 FIFO / AXI / 記憶體匯流排）時，非對齊尾巴（Tail Bytes / Padding / ZLP）如何處理？
- [ ] 多位元組欄位（Address, Length, Data, CRC）的大小端（Big-Endian vs Little-Endian）在軟硬體兩端是否一致？

## 3. 交易生命週期與 ACK 語義
- [ ] 程式碼是否誤把「Write API 回傳成功 / TL ACK」當成「硬體已執行完畢」而跳過狀態輪詢（Polling / Interrupt）？
- [ ] 發生 Timeout 重送前，殘留在底層 Rx Buffer / FIFO 內的舊封包或延遲回應是否有透過 `SEQ` 序號過濾或安全清倉？
- [ ] 分片傳輸（Fragmentation）在中間某一片失敗時，重送或中止機制是否會破壞硬體端狀態機？

## 4. Register Map 與硬體操作契約
- [ ] 暫存器位址、Page/Bank 切換、R/W/RO/W1C 權限是否與最新規格書及 RTL 定義一致？
- [ ] 修改含保留位元（Reserved Bits）的控制暫存器時，是否遵循 Read-Modify-Write 或遮罩保護？
- [ ] Reset / Flush / Mode Switch 後的生效延遲與副作用是否有 RTL 或規格書實證（無實證標記 `UNKNOWN / NOT PROVEN`）？

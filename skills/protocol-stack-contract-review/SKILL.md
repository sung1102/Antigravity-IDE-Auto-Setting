---
name: protocol-stack-contract-review
description: 通訊協定與跨層契約審核技能。適用於 TL/AL/HAL 分層架構、USB（如 FTDI FT601Q 等）、PCIe、UART、I2C、SPI、Ethernet、DisplayPort/eDP AUX、MIPI DSI、自訂封包格式、FPGA Register Access、韌體通訊、分片重組（Fragmentation/Reassembly）與軟硬體整合審查。
---

# Protocol Stack & Cross-Layer Contract Review（通訊協定契約審核技能）

適用於一切跨層通訊（PC 軟體 ↔ 驅動/USB Bridge ↔ MCU 韌體 ↔ FPGA RTL ↔ 外設 IC）。每次審查都必須先建立 **「端點 (Endpoint) → 層級 (Layer) → 封包/呼叫 (Packet/Call) → 回應 (Response) → 狀態 (State)」** 的端到端鏈路。

## 一、 核心協定審查維度

### 1. 分層責任與管道唯一性 (Layer Ownership & Single Pipeline)
- 逐層查明封包建構者、解析器（Parser）擁有者、傳輸者（Transport）、正式交易 API（Transaction API）與事件/回應路由。
- **嚴格禁令**：不允許擅自加入第二套 Transport、第二個背景 Reader、私有 Parser 或繞過既有正式交易 API 直接讀寫底層通道；除非架構審核已證明絕對必要，且取得使用者明確批准。

### 2. 長度單位、對齊與封包格式 (Length Units, Alignment & Framing)
- 嚴格查明協定中 `Length` 欄位的**單位與計算範圍**：
  - 單位是 `Byte`、`Word (16-bit)`、`DWord (32-bit)`、`Register Count` 還是 `Element Count`（或是 `Length - 1` 編碼，如 eDP AUX / I2C burst）？
  - `Length` 數值是否包含 Header、Command ID、Address 或結尾 CRC/Checksum？
- 核對實際 Payload 長度、介面位寬限制（例如 32-bit FIFO 對齊）、大小端（Endianness）、Padding 規則、Zero-Length Packet (ZLP) 條件與最大封包長度限制（MTU / Max Burst Size）。

### 3. TL ACK 與 AL 應用層語義完成之區隔 (Transport ACK vs Semantic Completion)
- 嚴格區分**傳輸層確認（TL ACK / USB Bulk Transfer 成功 / I2C ACK bit）**與**應用層語義回覆（AL Response / 硬體狀態機執行完成 / 資料已就緒）**。
- **鐵則**：一次只依真實證據確認交易完成條件；**「傳輸已 ACK」絕對不得自動等同於「應用層或硬體操作已完成」**。
- 檢查序號（`SEQ` / Transaction ID）生命週期、CRC 校驗、Timeout 重送機制、ACK/NACK 處理、回應與請求的關聯匹配、過期/殘留封包（Stale Packets in FIFO/Buffer）清除，以及多執行緒併發讀寫同一通道的競爭風險。

### 4. 分片與重組 (Fragmentation & Reassembly)
- 查明分片是**傳輸層片段（Transport Fragment，如 USB 封包切割）**、**協定邏輯區塊（Logical Block）**還是**底層硬體操作單位（Hardware Operation Unit，如 Flash Page / I2C 單次交易上限）**。
- 核對 Fragment Size 與實體硬體操作單位是否不同，以及接收端是否有完整的重組（Reassembly）與邊界檢查證據。不得混淆單一傳輸片段、邏輯區塊與硬體操作單位。

### 5. 暫存器映射與硬體副作用 (Register Map & Side Effects)
- 逐筆核對 Register Map 的地址（Offset / Base Address / Page / Bank）、讀寫權限（`RW` / `RO` / `WO` / `W1C` 寫 1 清零 / `RC` 讀清零）、每筆 Register 位寬、批次讀寫（Burst）跨界行為、Reset 預設值與保留欄位（Reserved Bits 寫入是否需維持原值 Read-Modify-Write）。
- 對照規格文件（Spec / Datasheet）與程式/RTL 實作，明確列出任何矛盾之處。
- **嚴禁猜測硬體副作用**：對於 Reset、Stop/Start、FIFO Cleanup、模式切換或 Page 切換的硬體副作用與等待時間，若無 RTL、規格書或實測波形證據，一律標示為 `UNKNOWN / NOT PROVEN`。

## 二、 檢查清單參考
詳細逐項檢查請對照 `resources/protocol-checklist.md`。

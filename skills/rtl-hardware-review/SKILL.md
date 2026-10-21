---
name: rtl-hardware-review
description: 硬體與 RTL 工程審核技能。適用於 Verilog、SystemVerilog、VHDL、FPGA（Xilinx Vivado/Intel Quartus 等）、ASIC、硬體模組、Testbench 與時序約束（SDC/XDC）的時脈域 CDC、Reset、握手協定、FIFO、狀態機 FSM、位寬與合成時序審查。
---

# RTL & Hardware Review（RTL 與硬體工程審核技能）

適用於 Verilog、SystemVerilog、VHDL、FPGA/ASIC 邏輯設計、Testbench 與時序約束。審查時必須沿著 **Top / Module Hierarchy、訊號方向（Input/Output/Inout）與時序證據** 逐層追蹤。

## 一、 核心硬體審查維度

### 1. Clock 與 Reset 架構
- 查明所有 Clock 與 Reset 的來源、頻率、極性（Active-High / Active-Low）、同步/非同步行為。
- 檢查 Reset 釋放時序（Asynchronous Assert, Synchronous De-assert）是否對齊目標時脈域。
- 盤點各個 Clock Domain 邊界與 Reset Domain Crossing (RDC)。

### 2. 握手協定與流量控制 (Handshake & Flow Control)
- 檢查 `valid/ready`（AXI-Stream 等）、`request/ack`、`busy/done`、`start/complete` 與 Backpressure 傳遞。
- 驗證在滿載、泡泡（Bubble）、突發中斷或下游反壓時，握手訊號是否可能發生**資料遺失（Drop）、重複取樣（Duplicate）或死鎖（Deadlock）**。
- 確認 `valid` 是否不違規依賴 `ready` 才拉起（防範組合邏輯迴路）。

### 3. FIFO、Pipeline 與仲裁 (FIFO, Pipeline & Arbitration)
- 核對 FIFO 深度、滿/空（`full`/`empty`/`almost_full`）產生條件、讀寫指標回捲（Pointer Wrap-around）、2 的冪次與非 2 的冪次深度處理。
- 檢查資料對齊、Pipeline Latency（延遲拍數是否與控制訊號一致）、多主端仲裁（Round-Robin / Priority）公平性與狀態轉換。

### 4. 位寬、有號/無號數與邊界 (Bit-Width, Signedness & Bounds)
- 嚴格檢查訊號位寬、有號數/無號數（`signed` vs `unsigned` 混用導致符號擴展錯誤）、截位（Truncation）、擴位（Zero/Sign Extension）與算術溢位。
- 檢查 Parameter / Localparam 參數化邊界（如 `$clog2` 在深度為 1 時的位寬退化）、計數器回捲條件、陣列索引範圍與 Endian / Bit Ordering（MSB-first vs LSB-first，Little-endian vs Big-endian）。

### 5. 賦值語義、組合邏輯與狀態機 (Assignments, Latches & FSM)
- 檢查時序邏輯（Sequential）是否一律使用 Non-blocking assignment (`<=`)，組合邏輯（Combinational）是否使用 Blocking assignment (`=`)，嚴禁混用。
- 檢查組合邏輯 `always @(*)` / `always_comb` 所有條件分支是否完整賦值，防止非預期鎖存器（Inferred Latch）。
- 檢查 FSM 狀態編碼、`default` 分支保護、非法狀態回復機制，以及輸出訊號是否為無毛刺（Glitch-free）暫存器輸出。

### 6. 跨時脈域 (CDC) 與時序約束 (SDC / XDC)
- 檢查單位元控制訊號是否使用適當級數的雙觸發器同步器（2-FF Synchronizer + `ASYNC_REG` 屬性），快到慢時脈域脈衝是否有展寬/握手（Pulse Stretcher / Toggle Handshake）。
- 檢查多位元跨時脈域資料是否透過非同步 FIFO、Gray Code 或完整握手傳輸，嚴禁多位元匯流排直接跨時脈域取樣（亞穩態與 Coherency 風險）。
- 對照 SDC / XDC 時脈定義、I/O 約束、Setup/Hold path；檢查 `set_false_path`、`set_clock_groups`、`set_multicycle_path` 是否有真實硬體結構依據，**嚴禁為了讓時序報告表面通過而隨意新增例外約束**。

## 二、 驗證層級與誠實回報鐵則
1. 驗證層級包含：Lint、Simulation（功能與邊界模擬）、Assertion/SVA、Formal（若支援）、Synthesis（合成報告檢查 Latch/Warning）與 Static Timing Analysis (STA / WNS / TNS) 及板端實測（ILA/LA/示波器）。
2. 每次回報必須明確標示**實際已執行項目、未執行項目 (`NOT RUN`) 及硬體實測需求**。
3. **絕對禁止**僅因 RTL 語法看起來合理就宣稱硬體行為已證明；沒有模擬、合成、時序或板端資料時，結論必須標為 `UNKNOWN / NOT PROVEN`。
4. 詳細檢查清單請參照 `resources/rtl-checklist.md`。

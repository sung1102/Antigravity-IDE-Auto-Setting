# RTL & Hardware Verification Checklist
> 若本表與專案既有硬體設計規範衝突，以專案規格與使用者明確要求為準，並於報告中註明差異。

## 1. Clock / Reset / CDC 檢查項
- [ ] 所有時脈域（Clock Domains）與頻率關係是否已完整列出？
- [ ] Reset 極性（Active High/Low）在模組實例化（Instantiation）端口連接時是否完全一致？
- [ ] 跨時脈域（CDC）單 bit 訊號是否有 2-FF 同步器？快時脈到慢時脈脈衝是否有 Toggle + Handshake？
- [ ] 跨時脈域多 bit 訊號是否使用 Async FIFO 或 Handshake / Gray code，無直接平行跨接？
- [ ] 是否檢查過 Reset Domain Crossing (RDC)，確認無非同步 Reset 釋放造成的亞穩態？

## 2. 語法、狀態機與賦值檢查項
- [ ] 時序區塊（`always @(posedge clk)` / `always_ff`）是否 100% 使用 `<=`？
- [ ] 組合區塊（`always @(*)` / `always_comb`）是否 100% 使用 `=` 且在開頭有預設賦值（消除 Inferred Latch）？
- [ ] FSM `case` 語句是否具備 `default` 分支且能安全回到 `IDLE` 或錯誤處理態？
- [ ] 模組端口連線（Port Mapping）位寬是否完全匹配，無隱式 1-bit 截斷或未連接警告？

## 3. 握手、FIFO 與資料路徑檢查項
- [ ] `valid/ready` 握手中，當 `valid && !ready` 時，Data 與控制訊號是否保持穩定不變？
- [ ] Pipeline 各級之間的 `valid` 推進與 `stall` 反壓是否同步，無泡泡覆蓋有效資料？
- [ ] 計數器與位址指標在最大值邊界（Wrap-around）及非 2 的冪次範圍下是否正確歸零？
- [ ] 有號數（`signed`）與無號數混合運算時，是否已明確轉型並預留溢位保護位元？

## 4. 約束與驗證狀態確認
- [ ] 新增或修改的 SDC/XDC 約束是否有對應的 CDC 電路支撐（非盲目宣告 `set_false_path`）？
- [ ] Lint / 模擬 (Simulation) / 合成 (Synthesis) / 時序分析 (Timing) 哪些已實跑？哪些尚未執行（標記 `NOT RUN` 或 `NOT PROVEN`）？

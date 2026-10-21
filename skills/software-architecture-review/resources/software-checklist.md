# Software Architecture & Code Review Checklist
> 若本表與專案既有規範衝突，以專案規格與使用者明確要求為準，並於報告中註明差異。

## A. 呼叫鏈與架構邊界
- [ ] 是否已定位真實 Entry Point、完整 Call Chain 與狀態唯一真相來源（Single Source of Truth）？
- [ ] 修改是否遵守既有分層依賴方向（未產生循環依賴或跨層私有調用）？
- [ ] 公共 API 簽章、回傳值語義與既有行為是否完全保持相容？

## B. 非同步、多執行緒與資源管理
- [ ] 所有 I/O 或耗時非同步呼叫是否支援 `CancellationToken` 與明確的 Timeout？
- [ ] 共用狀態讀寫是否有正確同步保護（Lock / Concurrent 集合 / Interlocked），且無 Lock 內呼叫外部未知代碼或 `await` 的死鎖風險？
- [ ] 事件訂閱（`+=`）在物件銷毀或重載時是否對稱取消訂閱（`-=`）？
- [ ] 檔案、Socket、USB Pipe、Unmanaged Memory、資料庫連線是否透過 `using` / `RAII` / `try-finally` 確保在例外路徑下也能正確釋放？

## C. 數值、緩衝區與邊界條件
- [ ] 空指標 / Null 參考、空集合、長度為 0 的輸入是否已妥善處理？
- [ ] 陣列切片、`memcpy`、`Span<T>`、Buffer 偏移與長度計算是否無 Off-by-one 或溢位風險？
- [ ] 跨平台或跨層資料交換是否明確指定 Endianness（Little/Big Endian）與無號數型別（`uint8_t`/`byte`, `uint16_t`/`ushort`, `uint32_t`/`uint`）？

## D. UI / MVVM (WPF / 桌面應用) 專項
- [ ] 背景執行緒回調更新 `ObservableCollection` 或 UI 綁定屬性時，是否確保已切回 UI Dispatcher？
- [ ] 高頻通訊或資料流湧入時，UI 更新是否有節流（Throttling / Batching）以避免畫面凍結？
- [ ] ViewModel 是否保持對 View 控制項的解耦，並正確維護 `ICommand` 啟用狀態？

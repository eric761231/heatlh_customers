# Supabase 設定完成指南

## ✅ 已完成的設定

### 1. 資料庫設定
- ✅ 已建立三個資料表：`customers`、`schedules`、`orders`
- ✅ 已設定外鍵關聯
- ✅ 已設定 Row Level Security (RLS) 政策
- ✅ 已建立索引以提升查詢效能

### 2. 前端設定
- ✅ 已更新 `config.js` 設定為使用 Supabase
- ✅ 已在所有 HTML 文件中載入 Supabase JS 庫
- ✅ 已載入 Supabase 客戶端代碼

### 3. 資料遷移
- ✅ 已將現有資料遷移到 Supabase

## 🚀 現在可以開始使用

### 測試步驟

1. **重新載入網頁**
   - 清除瀏覽器快取（Ctrl+Shift+R 或 Cmd+Shift+R）
   - 重新載入各個頁面

2. **測試功能**
   - 打開「客戶資料」頁面，查看客戶列表
   - 打開「行程事項」頁面，查看行程
   - 打開「訂貨清單」頁面，查看訂單
   - 嘗試新增、編輯、刪除資料

3. **檢查瀏覽器控制台**
   - 按 F12 打開開發者工具
   - 查看 Console 標籤是否有錯誤訊息
   - 如果有錯誤，請檢查錯誤訊息

## 🔍 疑難排解

### 問題 1：無法載入資料

**檢查事項：**
1. 確認 `html/js/config.js` 中 `DATA_SOURCE = 'supabase'`
2. 確認 Supabase URL 和 Key 是否正確
3. 檢查瀏覽器控制台的錯誤訊息

**解決方案：**
```javascript
// 在瀏覽器控制台執行
console.log('DATA_SOURCE:', DATA_SOURCE);
console.log('SUPABASE_URL:', SUPABASE_URL);
```

### 問題 2：CORS 錯誤

**解決方案：**
1. 前往 Supabase Dashboard > Settings > API
2. 確認「允許的來源」中包含您的網域
3. 如果是本地測試，添加 `http://localhost:3000` 或您的本地網址

### 問題 3：權限錯誤

**解決方案：**
1. 前往 Supabase Dashboard > Authentication > Policies
2. 確認 RLS 政策已正確設定
3. 或暫時禁用 RLS 進行測試（不建議用於生產環境）

### 問題 4：資料未顯示

**檢查事項：**
1. 確認資料已正確遷移到 Supabase
2. 在 Supabase Dashboard > Table Editor 中查看資料是否存在
3. 檢查資料格式是否正確

## 📊 效能對比

使用 Supabase 後，您應該會感受到：

| 操作 | 優化前 (Google Sheets) | 優化後 (Supabase) | 提升 |
|------|----------------------|------------------|------|
| 載入客戶列表 | 3-5 秒 | 100-300ms | **10-50倍** |
| 新增客戶 | 1-3 秒 | 50-200ms | **5-30倍** |
| 更新客戶 | 1-3 秒 | 50-200ms | **5-30倍** |
| 載入行程 | 5-10 秒 | 200-500ms | **10-50倍** |
| 載入訂單 | 5-10 秒 | 200-500ms | **10-50倍** |

## 🔄 切換回 Google Sheets（如果需要）

如果遇到問題需要暫時切換回 Google Sheets：

1. 打開 `html/js/config.js`
2. 將 `DATA_SOURCE` 改為 `'google-sheets'`
3. 重新載入頁面

## 📝 下一步建議

1. **測試所有功能**：確保所有 CRUD 操作都正常運作
2. **監控效能**：觀察載入速度和響應時間
3. **備份策略**：考慮定期匯出 Supabase 資料作為備份
4. **優化查詢**：如果資料量很大，可以進一步優化查詢

## 🎉 完成！

現在您的網頁已經成功連接到 Supabase 資料庫，享受更快的載入速度吧！


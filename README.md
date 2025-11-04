# 葡眾愛客戶 - 客戶管理系統

## 功能說明

這是一個使用 HTML、CSS、JavaScript 建立的客戶管理系統，資料儲存在 Supabase 資料庫中。

## 設定步驟

### 1. 建立 Google 試算表

1. 前往 [Google 試算表](https://sheets.google.com/)
2. 建立新的試算表
3. 在第一行建立標題列（系統會自動建立，但建議手動確認）：

   | ID | 姓名 | 電話 | 居住地區 | 健康狀況 | 藥物 | 保健食品 | 頭像 | 建立時間 |
   |----|------|------|----------|----------|------|----------|------|----------|

4. 複製試算表的 ID：
   - 試算表網址格式：`https://docs.google.com/spreadsheets/d/SPREADSHEET_ID/edit`
   - 複製 `SPREADSHEET_ID` 部分

### 2. 建立 Google Apps Script

1. 前往 [Google Apps Script](https://script.google.com/)
2. 點擊「新增專案」
3. 將 `google-apps-script.js` 檔案中的代碼複製貼上
4. 將 `SPREADSHEET_ID` 替換為您的試算表 ID（第 22 行）
5. 點擊「儲存」並為專案命名（例如：客戶健康追蹤系統）

### 3. 部署為 Web App

1. 在 Google Apps Script 編輯器中，點擊「部署」>「新增部署作業」
2. 點擊「選取類型」旁的齒輪圖示，選擇「網頁應用程式」
3. 設定：
   - **說明**：客戶健康追蹤系統 API（可選）
   - **執行身分**：我
   - **具有存取權的使用者**：任何人
4. 點擊「部署」
5. **重要**：複製「Web 應用程式網址」（類似：`https://script.google.com/macros/s/...`）

### 4. 設定前端應用程式

1. 開啟 `config.js` 檔案
2. 將 `YOUR_GOOGLE_SCRIPT_URL_HERE` 替換為您剛才複製的 Web App URL

```javascript
const GOOGLE_SCRIPT_URL = 'https://script.google.com/macros/s/YOUR_SCRIPT_ID/exec';
```

### 5. 授權 Google Apps Script（首次使用）

1. 首次執行時，需要授權 Google Apps Script
2. 點擊部署的 Web App URL，會出現授權提示
3. 點擊「進階」>「前往 [專案名稱]（不安全）」
4. 選擇您的 Google 帳號並授權
5. 完成後即可正常使用

## 使用方式

1. 在瀏覽器中開啟 `index.html`
2. 填寫客戶資料表單
3. 點擊「新增客戶」提交
4. 點擊左上角 ☰ 按鈕開啟側邊欄查看所有客戶
5. 點擊客戶頭像查看詳細資料

## 檔案說明

- `index.html` - 登入檢查與跳轉頁面
- `login.html` - Google 登入頁面
- `calendar.html` - 行事曆主頁面（行程管理）
- `add-customer.html` - 新增客戶頁面
- `customers.html` - 客戶資料列表頁面（手風琴式展開/收合）
- `orders.html` - 訂貨清單頁面
- `styles.css` - 樣式檔案
- `script.js` - JavaScript 邏輯（API 呼叫）
- `calendar.js` - 行事曆功能邏輯
- `orders.js` - 訂貨清單功能邏輯
- `taiwan-address.js` - 台灣縣市鄉鎮資料
- `config.js` - 設定檔（Google Apps Script URL）
- `google-apps-script.js` - Google Apps Script 後端代碼

## 注意事項

1. **頭像儲存**：頭像以 Base64 格式儲存在試算表中，大型圖片可能導致試算表變慢。建議使用較小的圖片（< 2MB）。

2. **權限設定**：確保 Google Apps Script 的 Web App 設定為「任何人」可以存取，否則無法從前端呼叫。

3. **資料安全**：目前設定為任何人都可以存取 Web App，如需限制存取，請修改 Google Apps Script 的權限設定。

4. **試算表限制**：Google 試算表有儲存格內容長度限制（50,000 字元），如果頭像 Base64 過大可能無法儲存。

## 故障排除

### 無法載入客戶清單

- 檢查 `config.js` 中的 URL 是否正確
- 確認 Google Apps Script 已部署並授權
- 檢查瀏覽器主控台是否有錯誤訊息

### 無法新增客戶

- 確認 Google Apps Script 的執行身分設定為「我」
- 確認已授權 Google Apps Script 存取試算表
- 檢查試算表 ID 是否正確

### 頭像無法顯示

- 確認圖片檔案大小 < 2MB
- 檢查瀏覽器主控台是否有錯誤訊息



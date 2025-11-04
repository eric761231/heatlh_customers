# Supabase 遷移指南

## 步驟 1：取得 Supabase 專案資訊

1. 前往您的 Supabase 專案：https://supabase.com/dashboard/project/lvrcnmvnqbueghjyvxji
2. 點擊左側選單的 **Settings** > **API**
3. 複製以下資訊：
   - **Project URL**: `https://lvrcnmvnqbueghjyvxji.supabase.co`
   - **anon/public key**: 這是您的 API 金鑰

## 步驟 2：建立資料表

1. 在 Supabase Dashboard 中，點擊左側選單的 **SQL Editor**
2. 點擊 **New query**
3. 複製並貼上 `supabase/migration.sql` 的內容
4. 點擊 **Run** 執行 SQL
5. 確認資料表已建立：
   - `customers`
   - `schedules`
   - `orders`

## 步驟 3：遷移現有資料

### 方法 A：使用瀏覽器控制台（推薦）

1. 在瀏覽器中打開您的網站
2. 打開開發者工具（F12）
3. 在 Console 中執行以下代碼：

```javascript
// 1. 載入 Supabase JS 庫
const script = document.createElement('script');
script.src = 'https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2';
document.head.appendChild(script);

// 2. 等待載入完成後，執行遷移腳本
script.onload = async () => {
    // 初始化 Supabase 客戶端
    const SUPABASE_URL = 'https://lvrcnmvnqbueghjyvxji.supabase.co';
    const SUPABASE_KEY = 'YOUR_SUPABASE_ANON_KEY'; // 替換為您的實際金鑰
    
    const supabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_KEY);
    
    // 載入遷移腳本
    const migrateScript = document.createElement('script');
    migrateScript.src = 'supabase/migrate-data.js';
    document.body.appendChild(migrateScript);
    
    // 執行遷移
    setTimeout(() => {
        window.migrateToSupabase();
    }, 1000);
};
```

### 方法 B：使用 Node.js 腳本

1. 安裝依賴：
```bash
npm install @supabase/supabase-js
```

2. 修改 `supabase/migrate-data.js` 中的 Supabase URL 和 Key

3. 執行遷移：
```bash
node supabase/migrate-data.js
```

## 步驟 4：更新前端代碼

### 4.1 更新 config.js

在 `html/js/config.js` 中添加 Supabase 配置：

```javascript
// Supabase 配置
const SUPABASE_URL = 'https://lvrcnmvnqbueghjyvxji.supabase.co';
const SUPABASE_ANON_KEY = 'YOUR_SUPABASE_ANON_KEY'; // 替換為您的實際金鑰

// 資料來源選擇：'supabase' 或 'google-sheets'
const DATA_SOURCE = 'supabase'; // 切換資料來源
```

### 4.2 更新 HTML 文件

在每個 HTML 文件的 `<head>` 中添加 Supabase JS 庫：

```html
<!-- 在現有的 script 標籤之前添加 -->
<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
<script src="js/supabase-client.js"></script>
```

### 4.3 更新 script.js

修改 `html/js/script.js` 中的 `apiCall` 函數，使其支援 Supabase：

```javascript
// 在 apiCall 函數開頭添加
if (DATA_SOURCE === 'supabase') {
    return await supabaseCall(action, data, customerId);
}
// 原有的 Google Apps Script 代碼...
```

## 步驟 5：測試遷移

1. 打開瀏覽器開發者工具（F12）
2. 檢查 Console 是否有錯誤
3. 測試各功能：
   - 新增客戶
   - 查看客戶列表
   - 新增行程
   - 新增訂單
4. 在 Supabase Dashboard > Table Editor 中確認資料已正確寫入

## 步驟 6：效能對比

遷移後，您應該會感受到：
- 載入速度提升 10-50 倍
- 操作響應更快
- 支援大量資料（10000+ 筆）

## 疑難排解

### 問題 1：CORS 錯誤
- 確保在 Supabase Dashboard > Settings > API 中已正確設定允許的來源

### 問題 2：權限錯誤
- 檢查 Row Level Security (RLS) 政策是否正確設定
- 確認 API 金鑰是否正確

### 問題 3：資料格式錯誤
- 檢查資料表結構是否與 SQL 腳本一致
- 確認日期格式是否正確（YYYY-MM-DD）

## 下一步

遷移完成後，您可以：
1. 保留 Google Sheets 作為備份
2. 定期同步資料到 Google Sheets（可選）
3. 享受更快的效能！


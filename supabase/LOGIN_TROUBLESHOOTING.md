# 登入問題診斷指南

## 錯誤訊息分析

### 1. 406 錯誤：查詢 users 表失敗

**錯誤訊息：**
```
lvrcnmvnqbueghjyvxji.supabase.co/rest/v1/users?select=name&id=eq.:1
Failed to load resource: the server responded with a status of 406
```

**原因：**
- 使用 `.single()` 查詢時，如果沒有找到資料會返回 406
- 可能是 RLS 政策問題
- 可能是查詢格式問題

**已修復：**
- 改用 `.maybeSingle()` 代替 `.single()`
- 添加了錯誤處理，不會阻止登入

### 2. 400 錯誤：Invalid login credentials

**錯誤訊息：**
```
AuthApiError: Invalid login credentials
```

**可能原因：**
1. Email 或密碼輸入錯誤
2. 用戶尚未註冊（`auth.users` 表中沒有該 Email）
3. 關閉 Email 驗證後，註冊流程可能有問題
4. Supabase 設定問題

## 診斷步驟

### 步驟 1：確認註冊是否成功

1. 打開瀏覽器開發者工具（F12）
2. 切換到 Console 標籤
3. 嘗試註冊新帳號
4. 查看 Console 輸出，應該會看到：
   ```
   註冊結果檢查: { hasUser: true, hasSession: true/false, ... }
   ```

**如果註冊成功：**
- `hasUser: true` 且 `hasSession: true` → 應該直接跳轉到主頁
- `hasUser: true` 且 `hasSession: false` → 需要 Email 驗證

**如果註冊失敗：**
- 檢查錯誤訊息
- 確認 Email 是否已被註冊

### 步驟 2：檢查 Supabase Dashboard

1. 登入 [Supabase Dashboard](https://app.supabase.com/)
2. 選擇您的專案
3. 前往 **Authentication** > **Users**
4. 檢查是否有您註冊的 Email
5. 查看用戶的 **Email Confirmed** 狀態

### 步驟 3：確認 Supabase 設定

1. 前往 **Authentication** > **Providers** > **Email**
2. 檢查 **Enable email provider** 是否開啟
3. 檢查 **Confirm email** 是否關閉（如果已關閉 Email 驗證）

### 步驟 4：測試登入

1. 確認 Email 和密碼是否正確
2. 如果剛註冊，確認註冊是否成功
3. 檢查瀏覽器控制台的詳細錯誤訊息

## 常見問題解決

### 問題 1：註冊成功但無法登入

**可能原因：**
- Email 驗證已關閉，但註冊時仍要求驗證
- Supabase 設定不一致

**解決方案：**
1. 前往 Supabase Dashboard
2. 確認 **Confirm email** 已關閉
3. 重新註冊帳號
4. 應該會自動登入（不需要驗證）

### 問題 2：Invalid login credentials

**可能原因：**
- Email 或密碼輸入錯誤
- 用戶不存在於 `auth.users` 表

**解決方案：**
1. 確認 Email 和密碼是否正確（注意大小寫）
2. 如果剛註冊，檢查註冊是否成功
3. 可以嘗試重新註冊
4. 檢查 Supabase Dashboard > Authentication > Users 確認用戶是否存在

### 問題 3：406 錯誤（已修復）

**已修復：**
- 改用 `.maybeSingle()` 代替 `.single()`
- 添加了錯誤處理，不會影響登入

## 調試技巧

### 查看詳細日誌

在瀏覽器控制台中，您應該會看到：

**註冊時：**
```
註冊結果檢查: { hasUser: true, hasSession: true, ... }
```

**登入時：**
```
嘗試登入，Email: xxx@xxx.com
登入成功，用戶 ID: xxx, Session: 已建立
```

### 檢查 Supabase Auth 狀態

在 Supabase Dashboard > Authentication > Users 中：
- 查看用戶是否存在
- 查看 Email 是否已確認
- 查看用戶的建立時間

## 測試建議

1. **清除瀏覽器快取和 Cookie**
2. **使用無痕模式測試**
3. **檢查瀏覽器控制台的所有錯誤訊息**
4. **確認 Supabase Dashboard 中的設定**

## 如果問題持續

1. 檢查 Supabase Dashboard 中的用戶列表
2. 確認 Email 驗證設定是否正確
3. 嘗試使用不同的 Email 註冊
4. 檢查 Supabase 的服務狀態


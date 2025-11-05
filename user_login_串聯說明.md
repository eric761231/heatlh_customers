# user_login 資料串聯說明

## ✅ 已完成的更新

### 1. 更新 `getCurrentUser()` 函數
- 從 `users` 表取得 `user_login` 欄位
- 如果沒有 `user_login`，使用 `email` 作為 fallback
- 在 `currentUser` 物件中加入 `userLogin` 屬性

### 2. 更新所有資料操作函數

#### 客戶資料 (customers)
- ✅ `getAllCustomersFromSupabase()` - 使用 `user_login` 過濾
- ✅ `getCustomerByIdFromSupabase()` - 使用 `user_login` 過濾
- ✅ `addCustomerToSupabase()` - 儲存 `user_login`
- ✅ `updateCustomerInSupabase()` - 使用 `user_login` 驗證權限
- ✅ `deleteCustomerFromSupabase()` - 使用 `user_login` 驗證權限

#### 行程資料 (schedules)
- ✅ `getAllSchedulesFromSupabase()` - 使用 `user_login` 過濾
- ✅ `addScheduleToSupabase()` - 儲存 `user_login`
- ✅ `deleteScheduleFromSupabase()` - 使用 `user_login` 驗證權限

#### 訂單資料 (orders)
- ✅ `getAllOrdersFromSupabase()` - 使用 `user_login` 過濾
- ✅ `addOrderToSupabase()` - 儲存 `user_login`
- ✅ `updateOrderInSupabase()` - 使用 `user_login` 驗證權限
- ✅ `deleteOrderFromSupabase()` - 使用 `user_login` 驗證權限

### 3. 更新登入流程
- 登入時確保 `user_login` 正確設定
- 如果沒有 `user_login`，使用 `email` 作為預設值

### 4. 更新註冊流程
- 註冊時建立 `users` 記錄並設定 `user_login`（預設使用 email）

## 📋 資料表結構需求

### users 表
- `id` (UUID) - Supabase Auth 的 user ID
- `user_login` (TEXT) - 用於串聯的欄位 ⭐
- `email` (TEXT) - Email 地址
- `name` (TEXT) - 使用者名稱
- 其他欄位...

### customers 表
- `id` (TEXT) - 客戶 ID
- `user_login` (TEXT) - 用於串聯的欄位 ⭐
- 其他欄位...

### schedules 表
- `id` (TEXT) - 行程 ID
- `user_login` (TEXT) - 用於串聯的欄位 ⭐
- 其他欄位...

### orders 表
- `id` (TEXT) - 訂單 ID
- `user_login` (TEXT) - 用於串聯的欄位 ⭐
- 其他欄位...

## 🔗 資料串聯邏輯

### 串聯方式
所有資料表都使用 `user_login` 欄位進行串聯：
- `users.user_login` = `customers.user_login` = `schedules.user_login` = `orders.user_login`

### 查詢範例
```javascript
// 取得使用者的所有客戶
SELECT * FROM customers WHERE user_login = '使用者登入帳號'

// 取得使用者的所有行程
SELECT * FROM schedules WHERE user_login = '使用者登入帳號'

// 取得使用者的所有訂單
SELECT * FROM orders WHERE user_login = '使用者登入帳號'
```

## ⚠️ 注意事項

### 1. 現有資料遷移
如果資料表中已有資料但沒有 `user_login`：
- 這些資料不會顯示給任何使用者
- 需要手動為這些資料設定 `user_login`

### 2. user_login 的唯一性
- `user_login` 在 `users` 表中應該是唯一的
- 其他表可以有多筆相同 `user_login` 的資料（屬於同一使用者）

### 3. Fallback 機制
- 如果 `users` 表中沒有 `user_login`，系統會使用 `email` 作為 fallback
- 這確保了向後兼容性

## 🧪 測試步驟

1. **註冊新帳號**
   - 確認 `users` 表中有 `user_login` 欄位
   - 確認 `user_login` 值正確（預設為 email）

2. **登入系統**
   - 確認 `getCurrentUser()` 能正確取得 `user_login`
   - 檢查瀏覽器控制台，確認 `currentUser.userLogin` 有值

3. **新增客戶**
   - 確認 `customers` 表中的 `user_login` 欄位有值
   - 確認值與 `users.user_login` 一致

4. **查看資料**
   - 確認只能看到自己的資料（`user_login` 匹配）
   - 確認不同使用者的資料互不干擾

## 📝 SQL 檢查查詢

在 Supabase Dashboard > SQL Editor 中執行：

```sql
-- 檢查 users 表的 user_login
SELECT id, email, user_login, name FROM users;

-- 檢查 customers 表的 user_login
SELECT id, name, user_login FROM customers;

-- 檢查 schedules 表的 user_login
SELECT id, title, user_login FROM schedules;

-- 檢查 orders 表的 user_login
SELECT id, product, user_login FROM orders;

-- 檢查是否有資料缺少 user_login
SELECT 'customers' as table_name, COUNT(*) as missing_count 
FROM customers WHERE user_login IS NULL OR user_login = ''
UNION ALL
SELECT 'schedules', COUNT(*) FROM schedules WHERE user_login IS NULL OR user_login = ''
UNION ALL
SELECT 'orders', COUNT(*) FROM orders WHERE user_login IS NULL OR user_login = '';
```

## 🔧 如果需要修復現有資料

如果現有資料缺少 `user_login`，可以執行：

```sql
-- 為 customers 表設定 user_login（請替換為實際的 user_login 值）
UPDATE customers 
SET user_login = 'your-user-login@example.com' 
WHERE user_login IS NULL OR user_login = '';

-- 為 schedules 表設定 user_login
UPDATE schedules 
SET user_login = 'your-user-login@example.com' 
WHERE user_login IS NULL OR user_login = '';

-- 為 orders 表設定 user_login
UPDATE orders 
SET user_login = 'your-user-login@example.com' 
WHERE user_login IS NULL OR user_login = '';
```

## ✅ 完成狀態

- ✅ 所有資料操作函數已更新為使用 `user_login`
- ✅ 登入流程已更新
- ✅ 註冊流程已更新
- ✅ 資料串聯邏輯已完整

現在系統會使用 `user_login` 進行所有資料串聯！


# 使用者資料表設定指南

## 步驟 1：建立使用者資料表

1. 前往 Supabase Dashboard：https://supabase.com/dashboard/project/lvrcnmvnqbueghjyvxji
2. 點擊左側選單的 **SQL Editor**
3. 點擊 **New query**
4. 開啟 `supabase/users-migration.sql`，複製全部內容
5. 貼上到 SQL Editor，點擊 **Run** 執行
6. 確認 `users` 資料表已建立

## 步驟 2：確認資料表結構

在 Supabase Dashboard > Table Editor 中，您應該看到：

### users 資料表欄位
- `id` (TEXT, PRIMARY KEY) - 使用者 ID（使用 email）
- `email` (TEXT, UNIQUE) - 使用者 Email
- `name` (TEXT) - 使用者名稱
- `picture` (TEXT) - 使用者頭像 URL
- `google_id` (TEXT, UNIQUE) - Google 使用者 ID
- `last_login` (TIMESTAMP) - 最後登入時間
- `created_at` (TIMESTAMP) - 建立時間
- `updated_at` (TIMESTAMP) - 更新時間

### 新增的欄位（在現有資料表中）

#### customers 表
- `created_by` (TEXT) - 建立者 Email
- `updated_by` (TEXT) - 最後更新者 Email

#### schedules 表
- `created_by` (TEXT) - 建立者 Email
- `updated_by` (TEXT) - 最後更新者 Email

#### orders 表
- `created_by` (TEXT) - 建立者 Email
- `updated_by` (TEXT) - 最後更新者 Email

## 步驟 3：測試功能

1. **清除瀏覽器快取**（Ctrl+Shift+R）
2. **重新登入系統**
   - 使用 Google 帳號登入
   - 系統會自動建立使用者記錄到 Supabase
3. **檢查使用者資料**
   - 前往 Supabase Dashboard > Table Editor > users
   - 確認您的使用者資料已存在
4. **測試資料操作**
   - 新增客戶、行程、訂單
   - 檢查 `created_by` 欄位是否正確記錄您的 Email

## 功能說明

### 自動建立使用者
- 首次登入時，系統會自動在 `users` 資料表中建立使用者記錄
- 之後登入時，會更新 `last_login` 時間

### 追蹤操作者
- 新增資料時，自動記錄 `created_by`（建立者 Email）
- 更新資料時，自動記錄 `updated_by`（更新者 Email）
- 可以在 Supabase Dashboard 中查看每筆資料是由誰建立/修改的

### 多裝置支援
- 使用者在任何裝置登入都會更新同一個使用者記錄
- 可以追蹤使用者的最後登入時間

## 查詢範例

### 查看所有使用者
```sql
SELECT * FROM users ORDER BY last_login DESC;
```

### 查看誰建立了哪些客戶
```sql
SELECT 
    c.name AS customer_name,
    c.created_at,
    u.name AS created_by_name,
    u.email AS created_by_email
FROM customers c
LEFT JOIN users u ON c.created_by = u.email
ORDER BY c.created_at DESC;
```

### 查看使用者的操作統計
```sql
SELECT 
    u.email,
    u.name,
    COUNT(DISTINCT c.id) AS customers_created,
    COUNT(DISTINCT s.id) AS schedules_created,
    COUNT(DISTINCT o.id) AS orders_created
FROM users u
LEFT JOIN customers c ON c.created_by = u.email
LEFT JOIN schedules s ON s.created_by = u.email
LEFT JOIN orders o ON o.created_by = u.email
GROUP BY u.email, u.name;
```

## 注意事項

1. **隱私保護**：目前所有使用者都可以看到所有資料，如果需要限制權限，需要調整 RLS 政策
2. **資料清理**：如果使用者刪除帳號，可以手動刪除 `users` 表中的記錄
3. **Email 變更**：如果使用者的 Google Email 變更，需要手動更新 `users` 表中的 `id` 和 `email`

## 下一步（可選）

如果需要更進階的功能，可以考慮：
1. **權限管理**：建立 `roles` 表，區分管理員和一般使用者
2. **操作歷史**：建立 `audit_log` 表，記錄所有操作歷史
3. **資料權限**：調整 RLS 政策，讓使用者只能看到自己建立的資料


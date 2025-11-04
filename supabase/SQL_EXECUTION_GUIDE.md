# SQL 執行指南

## 執行順序

請按照以下順序在 Supabase Dashboard > SQL Editor 中執行這些 SQL 腳本：

### 步驟 1：執行基礎資料表遷移（如果尚未執行）

**檔案：`supabase/migration.sql`**

這個腳本會建立：
- `customers` 資料表（客戶資料）
- `schedules` 資料表（行程資料）
- `orders` 資料表（訂單資料）
- 相關索引和觸發器

**執行方式：**
1. 前往 Supabase Dashboard：https://supabase.com/dashboard/project/lvrcnmvnqbueghjyvxji
2. 點擊左側選單的 **SQL Editor**
3. 點擊 **New query**
4. 開啟 `supabase/migration.sql`，複製全部內容
5. 貼上到 SQL Editor，點擊 **Run** 執行

---

### 步驟 2：執行使用者資料表遷移（必須執行）

**檔案：`supabase/users-migration.sql`**

這個腳本會建立：
- `users` 資料表（使用者登入資料）
- 在現有資料表中添加 `created_by` 和 `updated_by` 欄位
- 相關索引

**執行方式：**
1. 在 SQL Editor 中點擊 **New query**
2. 開啟 `supabase/users-migration.sql`，複製全部內容
3. 貼上到 SQL Editor，點擊 **Run** 執行

**重要：** 這個腳本必須執行，否則使用者登入功能無法正常運作。

---

### 步驟 3：RLS 政策（可選，不建議執行）

**檔案：`supabase/rls-policy.sql`**

**⚠️ 注意：這個腳本目前不需要執行！**

原因：
- 我們已經在前端應用層面實現了資料隔離（透過 `created_by` 過濾）
- RLS 政策中使用的 `current_setting('app.current_user_email', true)` 無法在 Supabase 的匿名存取環境中直接使用
- 如果執行此腳本，可能會導致資料存取問題

**如果您未來想要在資料庫層面實現更嚴格的安全控制，可以：**
1. 使用 Supabase Auth（需要設定 JWT token）
2. 或者使用 Database Functions 來處理權限檢查

---

## 檢查執行結果

執行完步驟 1 和步驟 2 後，在 Supabase Dashboard > Table Editor 中，您應該看到以下資料表：

### 必須存在的資料表：
- ✅ `customers` - 客戶資料
- ✅ `schedules` - 行程資料
- ✅ `orders` - 訂單資料
- ✅ `users` - 使用者資料

### 檢查欄位：
在 `customers`、`schedules`、`orders` 資料表中，應該都有：
- `created_by` 欄位（TEXT 類型）
- `updated_by` 欄位（TEXT 類型）

---

## 常見問題

### Q: 如果已經執行過 `migration.sql`，還需要再執行嗎？
A: 不需要。只需要執行 `users-migration.sql` 即可。

### Q: 執行 `users-migration.sql` 會影響現有資料嗎？
A: 不會。這個腳本使用 `ADD COLUMN IF NOT EXISTS`，只會添加不存在的欄位，不會刪除或修改現有資料。

### Q: 如果現有資料沒有 `created_by` 欄位，會怎樣？
A: 這些資料不會顯示給任何使用者（因為前端會過濾 `created_by`）。如果您需要保留這些資料，可以手動為它們設定 `created_by` 欄位。

### Q: 如何為現有資料設定 `created_by`？
A: 在 SQL Editor 中執行：
```sql
-- 為現有客戶資料設定建立者（請替換為實際的 email）
UPDATE customers 
SET created_by = 'your-email@example.com' 
WHERE created_by IS NULL;

-- 為現有行程資料設定建立者
UPDATE schedules 
SET created_by = 'your-email@example.com' 
WHERE created_by IS NULL;

-- 為現有訂單資料設定建立者
UPDATE orders 
SET created_by = 'your-email@example.com' 
WHERE created_by IS NULL;
```

---

## 執行後測試

執行完 SQL 後，請測試：

1. **清除瀏覽器快取**（Ctrl+Shift+R）
2. **重新登入系統**
3. **檢查資料顯示是否正常**
4. **使用不同帳號登入測試資料隔離**

如果遇到任何問題，請檢查瀏覽器控制台的錯誤訊息。


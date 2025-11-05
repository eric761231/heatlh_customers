# 檢查 users 表 RLS 政策

## 問題說明

如果註冊後資料沒有寫入 `users` 表，通常是因為 Supabase 的 Row Level Security (RLS) 政策限制了寫入權限。

## 解決步驟

### 1. 檢查 users 表的 RLS 是否啟用

1. 登入 Supabase Dashboard
2. 進入 **Authentication** > **Policies** 或 **Table Editor** > **users** 表
3. 檢查 RLS 是否啟用

### 2. 如果 RLS 已啟用，需要建立允許寫入的政策

#### 選項 A：允許已認證用戶插入自己的資料（推薦）

在 Supabase SQL Editor 中執行：

```sql
-- 允許用戶插入自己的資料
CREATE POLICY "Users can insert their own data"
ON users
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = id);

-- 允許用戶更新自己的資料
CREATE POLICY "Users can update their own data"
ON users
FOR UPDATE
TO authenticated
USING (auth.uid() = id);

-- 允許用戶讀取自己的資料
CREATE POLICY "Users can read their own data"
ON users
FOR SELECT
TO authenticated
USING (auth.uid() = id);
```

#### 選項 B：暫時關閉 RLS（僅用於測試，不推薦生產環境）

```sql
-- 關閉 users 表的 RLS（不推薦用於生產環境）
ALTER TABLE users DISABLE ROW LEVEL SECURITY;
```

### 3. 檢查 users 表的結構

確保 `users` 表有以下欄位（**注意：不需要 email 欄位**，email 資訊存在 Supabase Auth 中）：

```sql
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    user_login TEXT,  -- 用於串聯資料，通常使用 email 值
    name TEXT,
    picture TEXT,
    google_id TEXT,  -- 可選，用於 Google 登入
    last_login TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**重要說明：**
- `email` 欄位不需要存在於 users 表中
- Email 資訊存在 Supabase Auth 的 `auth.users` 表中
- `user_login` 欄位用於資料串聯，通常儲存 email 值

### 4. 測試註冊流程

1. 打開瀏覽器開發者工具（F12）
2. 切換到 Console 標籤
3. 嘗試註冊新帳號
4. 檢查 Console 中的錯誤訊息

### 5. 常見錯誤訊息

- **"new row violates row-level security policy"** → 需要建立 INSERT 政策
- **"permission denied for table users"** → RLS 政策不允許寫入
- **"relation 'users' does not exist"** → users 表不存在，需要先建立

### 6. 如果使用 Service Role Key（不推薦，僅用於測試）

如果暫時無法解決 RLS 問題，可以在註冊時使用 Service Role Key（**僅用於測試，不要用於生產環境**）：

```javascript
// 僅用於測試，不要用於生產環境
const serviceRoleKey = 'your-service-role-key';
const adminClient = supabase.createClient(SUPABASE_URL, serviceRoleKey);
```

## 檢查清單

- [ ] users 表已建立
- [ ] users 表有正確的欄位結構
- [ ] RLS 政策已正確設定（允許 INSERT、UPDATE、SELECT）
- [ ] 測試註冊流程，檢查 Console 錯誤訊息
- [ ] 確認資料能正確寫入 users 表

## 建議的 RLS 政策（完整版）

```sql
-- 啟用 RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- 允許用戶插入自己的資料
DROP POLICY IF EXISTS "Users can insert their own data" ON users;
CREATE POLICY "Users can insert their own data"
ON users
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = id);

-- 允許用戶更新自己的資料
DROP POLICY IF EXISTS "Users can update their own data" ON users;
CREATE POLICY "Users can update their own data"
ON users
FOR UPDATE
TO authenticated
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- 允許用戶讀取自己的資料
DROP POLICY IF EXISTS "Users can read their own data" ON users;
CREATE POLICY "Users can read their own data"
ON users
FOR SELECT
TO authenticated
USING (auth.uid() = id);
```

## 注意事項

1. **RLS 政策很重要**：確保只有用戶能操作自己的資料
2. **測試環境**：可以先關閉 RLS 測試功能，確認正常後再啟用
3. **生產環境**：必須啟用 RLS 並設定正確的政策


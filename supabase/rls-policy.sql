-- Row Level Security (RLS) 政策更新
-- 讓使用者只能看到自己建立的資料
-- 請在 Supabase Dashboard > SQL Editor 中執行此腳本

-- 1. 刪除現有的開放政策（如果存在）
DROP POLICY IF EXISTS "Allow all operations on customers" ON customers;
DROP POLICY IF EXISTS "Allow all operations on schedules" ON schedules;
DROP POLICY IF EXISTS "Allow all operations on orders" ON orders;
DROP POLICY IF EXISTS "Allow all operations on users" ON users;

-- 2. 建立新的 RLS 政策：使用者只能看到自己建立的資料

-- 客戶資料表：只能看到自己建立的客戶
CREATE POLICY "Users can view own customers" ON customers
    FOR SELECT USING (
        created_by = (SELECT email FROM users WHERE id = current_setting('app.current_user_email', true))
    );

CREATE POLICY "Users can insert own customers" ON customers
    FOR INSERT WITH CHECK (
        created_by = (SELECT email FROM users WHERE id = current_setting('app.current_user_email', true))
    );

CREATE POLICY "Users can update own customers" ON customers
    FOR UPDATE USING (
        created_by = (SELECT email FROM users WHERE id = current_setting('app.current_user_email', true))
    );

CREATE POLICY "Users can delete own customers" ON customers
    FOR DELETE USING (
        created_by = (SELECT email FROM users WHERE id = current_setting('app.current_user_email', true))
    );

-- 行程資料表：只能看到自己建立的行程
CREATE POLICY "Users can view own schedules" ON schedules
    FOR SELECT USING (
        created_by = (SELECT email FROM users WHERE id = current_setting('app.current_user_email', true))
    );

CREATE POLICY "Users can insert own schedules" ON schedules
    FOR INSERT WITH CHECK (
        created_by = (SELECT email FROM users WHERE id = current_setting('app.current_user_email', true))
    );

CREATE POLICY "Users can update own schedules" ON schedules
    FOR UPDATE USING (
        created_by = (SELECT email FROM users WHERE id = current_setting('app.current_user_email', true))
    );

CREATE POLICY "Users can delete own schedules" ON schedules
    FOR DELETE USING (
        created_by = (SELECT email FROM users WHERE id = current_setting('app.current_user_email', true))
    );

-- 訂單資料表：只能看到自己建立的訂單
CREATE POLICY "Users can view own orders" ON orders
    FOR SELECT USING (
        created_by = (SELECT email FROM users WHERE id = current_setting('app.current_user_email', true))
    );

CREATE POLICY "Users can insert own orders" ON orders
    FOR INSERT WITH CHECK (
        created_by = (SELECT email FROM users WHERE id = current_setting('app.current_user_email', true))
    );

CREATE POLICY "Users can update own orders" ON orders
    FOR UPDATE USING (
        created_by = (SELECT email FROM users WHERE id = current_setting('app.current_user_email', true))
    );

CREATE POLICY "Users can delete own orders" ON orders
    FOR DELETE USING (
        created_by = (SELECT email FROM users WHERE id = current_setting('app.current_user_email', true))
    );

-- 使用者資料表：只能看到自己的資料
CREATE POLICY "Users can view own profile" ON users
    FOR SELECT USING (id = current_setting('app.current_user_email', true));

CREATE POLICY "Users can update own profile" ON users
    FOR UPDATE USING (id = current_setting('app.current_user_email', true));

CREATE POLICY "Users can insert own profile" ON users
    FOR INSERT WITH CHECK (id = current_setting('app.current_user_email', true));


-- 使用者資料表遷移腳本
-- 請在 Supabase Dashboard > SQL Editor 中執行此腳本

-- 1. 建立使用者資料表
CREATE TABLE IF NOT EXISTS users (
    id TEXT PRIMARY KEY, -- 使用 Google ID 或 email 作為主鍵
    email TEXT UNIQUE NOT NULL,
    name TEXT,
    picture TEXT,
    google_id TEXT UNIQUE,
    last_login TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. 建立索引以提升查詢效能
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_google_id ON users(google_id);

-- 3. 啟用 Row Level Security (RLS)
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- 4. 建立政策：允許所有人讀寫（可根據需求調整）
CREATE POLICY "Allow all operations on users" ON users
    FOR ALL USING (true) WITH CHECK (true);

-- 5. 建立更新時間的觸發器
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 6. 可選：在現有資料表中添加操作者欄位（追蹤誰建立/修改了資料）
-- 如果不需要追蹤操作者，可以跳過此步驟

-- 客戶表
ALTER TABLE customers ADD COLUMN IF NOT EXISTS created_by TEXT;
ALTER TABLE customers ADD COLUMN IF NOT EXISTS updated_by TEXT;
CREATE INDEX IF NOT EXISTS idx_customers_created_by ON customers(created_by);

-- 行程表
ALTER TABLE schedules ADD COLUMN IF NOT EXISTS created_by TEXT;
ALTER TABLE schedules ADD COLUMN IF NOT EXISTS updated_by TEXT;
CREATE INDEX IF NOT EXISTS idx_schedules_created_by ON schedules(created_by);

-- 訂單表
ALTER TABLE orders ADD COLUMN IF NOT EXISTS created_by TEXT;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS updated_by TEXT;
CREATE INDEX IF NOT EXISTS idx_orders_created_by ON orders(created_by);


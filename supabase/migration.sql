-- Supabase 資料庫遷移腳本
-- 請在 Supabase Dashboard > SQL Editor 中執行此腳本

-- 1. 建立客戶資料表
CREATE TABLE IF NOT EXISTS customers (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    phone TEXT,
    city TEXT,
    district TEXT,
    village TEXT,
    neighborhood TEXT,
    street_type TEXT,
    street_name TEXT,
    lane TEXT,
    alley TEXT,
    number TEXT,
    floor TEXT,
    full_address TEXT,
    health_status TEXT,
    medications TEXT,
    supplements TEXT,
    avatar TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. 建立行程資料表
CREATE TABLE IF NOT EXISTS schedules (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    date DATE NOT NULL,
    start_time TIME,
    end_time TIME,
    type TEXT DEFAULT 'other',
    customer_id TEXT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT fk_customer FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE SET NULL
);

-- 3. 建立訂單資料表
CREATE TABLE IF NOT EXISTS orders (
    id TEXT PRIMARY KEY,
    date DATE NOT NULL,
    customer_id TEXT,
    product TEXT NOT NULL,
    quantity INTEGER DEFAULT 1,
    amount DECIMAL(10, 2) DEFAULT 0,
    paid BOOLEAN DEFAULT false,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT fk_customer FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE SET NULL
);

-- 4. 建立索引以提升查詢效能
CREATE INDEX IF NOT EXISTS idx_customers_phone ON customers(phone);
CREATE INDEX IF NOT EXISTS idx_schedules_date ON schedules(date);
CREATE INDEX IF NOT EXISTS idx_schedules_customer_id ON schedules(customer_id);
CREATE INDEX IF NOT EXISTS idx_orders_date ON orders(date);
CREATE INDEX IF NOT EXISTS idx_orders_customer_id ON orders(customer_id);

-- 5. 啟用 Row Level Security (RLS) - 允許所有操作（可根據需求調整）
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

-- 建立政策：允許所有人讀寫（生產環境應根據需求調整）
CREATE POLICY "Allow all operations on customers" ON customers
    FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Allow all operations on schedules" ON schedules
    FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Allow all operations on orders" ON orders
    FOR ALL USING (true) WITH CHECK (true);

-- 6. 建立更新時間的觸發器
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_customers_updated_at BEFORE UPDATE ON customers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_schedules_updated_at BEFORE UPDATE ON schedules
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON orders
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();


-- 修正資料所有權腳本
-- 此腳本會將所有舊資料的 created_by 設定為指定的使用者 email
-- 請在 Supabase Dashboard > SQL Editor 中執行此腳本

-- 使用說明：
-- 1. 將 YOUR_EMAIL@example.com 替換為您的實際 email
-- 2. 執行此腳本後，所有資料都會歸屬於該使用者
-- 3. 如果有多個使用者，需要為每個使用者分別執行（使用不同的 email）

-- ============================================
-- 步驟 1：設定您的 email（請替換）
-- ============================================
-- 請將下面的 'YOUR_EMAIL@example.com' 替換為您的實際 email
DO $$
DECLARE
    user_email TEXT := 'YOUR_EMAIL@example.com'; -- 請替換為您的 email
    updated_count INTEGER := 0;
BEGIN
    -- 更新客戶資料表
    UPDATE customers
    SET created_by = user_email
    WHERE created_by IS NULL OR created_by = '';
    
    GET DIAGNOSTICS updated_count = ROW_COUNT;
    RAISE NOTICE '已更新 % 筆客戶資料', updated_count;
    
    -- 更新行程資料表
    UPDATE schedules
    SET created_by = user_email
    WHERE created_by IS NULL OR created_by = '';
    
    GET DIAGNOSTICS updated_count = ROW_COUNT;
    RAISE NOTICE '已更新 % 筆行程資料', updated_count;
    
    -- 更新訂單資料表
    UPDATE orders
    SET created_by = user_email
    WHERE created_by IS NULL OR created_by = '';
    
    GET DIAGNOSTICS updated_count = ROW_COUNT;
    RAISE NOTICE '已更新 % 筆訂單資料', updated_count;
    
    RAISE NOTICE '所有資料已更新完成！';
END $$;

-- ============================================
-- 步驟 2：檢查更新結果
-- ============================================
-- 執行以下查詢來檢查更新結果
SELECT 
    'customers' as table_name,
    COUNT(*) as total_records,
    COUNT(*) FILTER (WHERE created_by IS NOT NULL AND created_by != '') as records_with_user,
    COUNT(*) FILTER (WHERE created_by IS NULL OR created_by = '') as records_without_user
FROM customers
UNION ALL
SELECT 
    'schedules' as table_name,
    COUNT(*) as total_records,
    COUNT(*) FILTER (WHERE created_by IS NOT NULL AND created_by != '') as records_with_user,
    COUNT(*) FILTER (WHERE created_by IS NULL OR created_by = '') as records_without_user
FROM schedules
UNION ALL
SELECT 
    'orders' as table_name,
    COUNT(*) as total_records,
    COUNT(*) FILTER (WHERE created_by IS NOT NULL AND created_by != '') as records_with_user,
    COUNT(*) FILTER (WHERE created_by IS NULL OR created_by = '') as records_without_user
FROM orders;


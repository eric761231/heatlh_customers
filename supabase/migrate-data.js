/**
 * 資料遷移腳本：從 Google Sheets 遷移到 Supabase
 * 
 * 使用方式：
 * 1. 在 Node.js 環境中執行：node supabase/migrate-data.js
 * 2. 或使用瀏覽器控制台執行（需要先載入相關腳本）
 */

// 請替換為您的 Supabase 專案資訊
const SUPABASE_URL = 'https://lvrcnmvnqbueghjyvxji.supabase.co'; // 從 Supabase Dashboard 取得
const SUPABASE_KEY = 'YOUR_SUPABASE_ANON_KEY'; // 從 Supabase Dashboard > Settings > API 取得

// Google Apps Script URL（用於讀取現有資料）
const GOOGLE_SCRIPT_URL = 'https://script.google.com/macros/s/AKfycbzeAZjeeu-i_zxZ7yqtMhF-GlqRolONshl3DVckvv9jNxdWlvUSSnscDaAeVfLUQ7Ss/exec';

// 初始化 Supabase 客戶端（Node.js 環境）
// 如果使用瀏覽器，請使用 @supabase/supabase-js CDN
let supabase;
if (typeof window !== 'undefined') {
    // 瀏覽器環境
    supabase = supabaseClient; // 需要先載入 supabase-js
} else {
    // Node.js 環境
    const { createClient } = require('@supabase/supabase-js');
    supabase = createClient(SUPABASE_URL, SUPABASE_KEY);
}

/**
 * 從 Google Sheets 讀取資料
 */
async function fetchFromGoogleSheets(action) {
    const url = `${GOOGLE_SCRIPT_URL}?action=${action}`;
    const response = await fetch(url);
    const result = await response.json();
    return result.success ? result.data : [];
}

/**
 * 遷移客戶資料
 */
async function migrateCustomers() {
    console.log('開始遷移客戶資料...');
    const customers = await fetchFromGoogleSheets('getAll');
    
    if (customers.length === 0) {
        console.log('沒有客戶資料需要遷移');
        return;
    }
    
    // 準備資料
    const customerData = customers.map(customer => ({
        id: String(customer.id),
        name: customer.name || '',
        phone: customer.phone || '',
        city: customer.city || '',
        district: customer.district || '',
        village: customer.village || '',
        neighborhood: customer.neighborhood || '',
        street_type: customer.streetType || '',
        street_name: customer.streetName || '',
        lane: customer.lane || '',
        alley: customer.alley || '',
        number: customer.number || '',
        floor: customer.floor || '',
        full_address: customer.fullAddress || '',
        health_status: customer.healthStatus || '',
        medications: customer.medications || '',
        supplements: customer.supplements || '',
        avatar: customer.avatar || '',
        created_at: customer.createdAt || new Date().toISOString()
    }));
    
    // 批量插入（每批 100 筆）
    const batchSize = 100;
    for (let i = 0; i < customerData.length; i += batchSize) {
        const batch = customerData.slice(i, i + batchSize);
        const { data, error } = await supabase
            .from('customers')
            .upsert(batch, { onConflict: 'id' });
        
        if (error) {
            console.error(`遷移客戶資料批次 ${i / batchSize + 1} 失敗:`, error);
        } else {
            console.log(`已遷移客戶資料批次 ${i / batchSize + 1}/${Math.ceil(customerData.length / batchSize)}`);
        }
    }
    
    console.log(`客戶資料遷移完成，共 ${customers.length} 筆`);
}

/**
 * 遷移行程資料
 */
async function migrateSchedules() {
    console.log('開始遷移行程資料...');
    const schedules = await fetchFromGoogleSheets('getSchedules');
    
    if (schedules.length === 0) {
        console.log('沒有行程資料需要遷移');
        return;
    }
    
    // 準備資料
    const scheduleData = schedules.map(schedule => ({
        id: String(schedule.id),
        title: schedule.title || '',
        date: schedule.date || new Date().toISOString().split('T')[0],
        start_time: schedule.startTime || null,
        end_time: schedule.endTime || null,
        type: schedule.type || 'other',
        customer_id: schedule.customerId || null,
        notes: schedule.notes || ''
    }));
    
    // 批量插入
    const batchSize = 100;
    for (let i = 0; i < scheduleData.length; i += batchSize) {
        const batch = scheduleData.slice(i, i + batchSize);
        const { data, error } = await supabase
            .from('schedules')
            .upsert(batch, { onConflict: 'id' });
        
        if (error) {
            console.error(`遷移行程資料批次 ${i / batchSize + 1} 失敗:`, error);
        } else {
            console.log(`已遷移行程資料批次 ${i / batchSize + 1}/${Math.ceil(scheduleData.length / batchSize)}`);
        }
    }
    
    console.log(`行程資料遷移完成，共 ${schedules.length} 筆`);
}

/**
 * 遷移訂單資料
 */
async function migrateOrders() {
    console.log('開始遷移訂單資料...');
    const orders = await fetchFromGoogleSheets('getOrders');
    
    if (orders.length === 0) {
        console.log('沒有訂單資料需要遷移');
        return;
    }
    
    // 準備資料
    const orderData = orders.map(order => ({
        id: String(order.id),
        date: order.date || new Date().toISOString().split('T')[0],
        customer_id: order.customerId || null,
        product: order.product || '',
        quantity: order.quantity || 1,
        amount: order.amount || 0,
        paid: order.paid === true || order.paid === 'true',
        notes: order.notes || ''
    }));
    
    // 批量插入
    const batchSize = 100;
    for (let i = 0; i < orderData.length; i += batchSize) {
        const batch = orderData.slice(i, i + batchSize);
        const { data, error } = await supabase
            .from('orders')
            .upsert(batch, { onConflict: 'id' });
        
        if (error) {
            console.error(`遷移訂單資料批次 ${i / batchSize + 1} 失敗:`, error);
        } else {
            console.log(`已遷移訂單資料批次 ${i / batchSize + 1}/${Math.ceil(orderData.length / batchSize)}`);
        }
    }
    
    console.log(`訂單資料遷移完成，共 ${orders.length} 筆`);
}

/**
 * 執行完整遷移
 */
async function migrateAll() {
    try {
        console.log('=== 開始資料遷移 ===');
        await migrateCustomers();
        await migrateSchedules();
        await migrateOrders();
        console.log('=== 資料遷移完成 ===');
    } catch (error) {
        console.error('遷移過程發生錯誤:', error);
    }
}

// 如果直接執行此腳本
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { migrateAll, migrateCustomers, migrateSchedules, migrateOrders };
}

// 如果在瀏覽器中執行
if (typeof window !== 'undefined') {
    window.migrateToSupabase = migrateAll;
}


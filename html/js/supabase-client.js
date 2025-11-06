/**
 * Supabase 客戶端
 * 用於替代 Google Apps Script 的資料操作
 */

// 初始化 Supabase 客戶端
let supabaseClient = null;
let currentUser = null; // 當前登入的使用者

// 將變數暴露到 window 物件，以便在登入頁面清除和外部訪問
if (typeof window !== 'undefined') {
    window.currentUser = null;
    // 暴露 supabaseClient 以便外部訪問（如果需要）
    Object.defineProperty(window, 'supabaseClient', {
        get: function() { return supabaseClient; },
        set: function(value) { supabaseClient = value; }
    });
}

/**
 * 初始化 Supabase 客戶端
 */
function initSupabase() {
    if (typeof supabase === 'undefined') {
        console.error('Supabase JS 庫未載入，請在 HTML 中添加：');
        console.error('<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>');
        return null;
    }
    
    // 從 config.js 讀取配置
    if (typeof SUPABASE_URL === 'undefined' || typeof SUPABASE_ANON_KEY === 'undefined') {
        console.error('Supabase 配置未設定，請在 config.js 中設定 SUPABASE_URL 和 SUPABASE_ANON_KEY');
        return null;
    }
    
    if (!supabaseClient) {
        supabaseClient = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
    }
    
    // Supabase Auth 會自動處理會話和 RLS
    
    return supabaseClient;
}

/**
 * 取得當前使用者（從 Supabase Auth）
 */
async function getCurrentUser() {
    try {
        const client = initSupabase();
        if (!client) {
            return null;
        }
        
        // 從 Supabase Auth 獲取當前會話
        const { data: { session }, error } = await client.auth.getSession();
        
        if (error || !session || !session.user) {
            currentUser = null;
            return null;
        }
        
        const user = session.user;
        const userEmail = user.email;
        
        // 從 users 表獲取用戶資料（取得 user_login）
        let userData = null;
        let userLogin = null;
        try {
            const { data, error: userError } = await client
                .from('users')
                .select('name, picture, user_login')
                .eq('id', user.id)
                .maybeSingle(); // 使用 maybeSingle() 避免用戶不存在時返回 406 錯誤
            
            if (!userError && data) {
                userData = data;
                userLogin = data.user_login;
            }
        } catch (e) {
            console.log('無法從 users 表獲取用戶資料:', e);
        }
        
        // 如果沒有 user_login，使用 email 作為 fallback
        if (!userLogin) {
            userLogin = userEmail;
        }
        
        // 如果使用者已變更，清除舊的快取
        if (currentUser && currentUser.userLogin !== userLogin) {
            currentUser = null;
        }
        
        // 如果沒有快取或使用者已變更，建立新的使用者物件
        if (!currentUser || currentUser.userLogin !== userLogin) {
            currentUser = {
                id: user.id, // 使用 Supabase Auth 的 user ID
                email: userEmail,
                userLogin: userLogin, // 使用 user_login 作為串聯欄位
                name: userData?.name || user.user_metadata?.name || userEmail?.split('@')[0] || '使用者',
                picture: userData?.picture || user.user_metadata?.picture || ''
            };
        }
        
        return currentUser;
    } catch (e) {
        console.error('取得使用者資訊失敗:', e);
        currentUser = null;
    }
    
    return null;
}

/**
 * Supabase API 呼叫函數（替代 Google Apps Script）
 */
async function supabaseCall(action, data = null, id = null) {
    const client = initSupabase();
    if (!client) {
        throw new Error('Supabase 客戶端未初始化');
    }
    
    try {
        switch(action) {
            case 'getAll':
                return await getAllCustomersFromSupabase();
            case 'getById':
                return await getCustomerByIdFromSupabase(id);
            case 'add':
                return await addCustomerToSupabase(data);
            case 'update':
                return await updateCustomerInSupabase(id, data);
            case 'delete':
                return await deleteCustomerFromSupabase(id);
            case 'getSchedules':
                return await getAllSchedulesFromSupabase();
            case 'addSchedule':
                return await addScheduleToSupabase(data);
            case 'deleteSchedule':
                return await deleteScheduleFromSupabase(id);
            case 'getOrders':
                return await getAllOrdersFromSupabase();
            case 'addOrder':
                return await addOrderToSupabase(data);
            case 'updateOrder':
                return await updateOrderInSupabase(id, data);
            case 'deleteOrder':
                return await deleteOrderFromSupabase(id);
            default:
                throw new Error('未知的操作');
        }
    } catch (error) {
        console.error('Supabase API 錯誤:', error);
        throw error;
    }
}

// ==================== 客戶資料操作 ====================

async function getAllCustomersFromSupabase() {
    const user = await getCurrentUser();
    if (!user || !user.userLogin) {
        throw new Error('未登入，無法取得客戶資料');
    }
    
    // 只查詢當前使用者建立的客戶（使用 user_login 串聯）
    const { data, error } = await supabaseClient
        .from('customers')
        .select('*')
        .eq('user_login', user.userLogin) // 使用 user_login 串聯
        .order('created_at', { ascending: false });
    
    if (error) throw error;
    
    // 轉換為前端使用的格式
    return data.map(c => ({
        id: c.id,
        name: c.name,
        phone: c.phone,
        city: c.city,
        district: c.district,
        village: c.village,
        neighborhood: c.neighborhood,
        streetType: c.street_type,
        streetName: c.street_name,
        lane: c.lane,
        alley: c.alley,
        number: c.number,
        floor: c.floor,
        fullAddress: c.full_address,
        healthStatus: c.health_status,
        medications: c.medications,
        supplements: c.supplements,
        avatar: c.avatar,
        createdAt: c.created_at
    }));
}

async function getCustomerByIdFromSupabase(id) {
    const user = await getCurrentUser();
    if (!user) {
        throw new Error('未登入，無法取得客戶資料');
    }
    
    // 只查詢當前使用者建立的客戶（使用 user_login 串聯）
    const { data, error } = await supabaseClient
        .from('customers')
        .select('*')
        .eq('id', id)
        .eq('user_login', user.userLogin) // 使用 user_login 串聯
        .single();
    
    if (error) {
        if (error.code === 'PGRST116') {
            throw new Error('找不到指定的客戶資料或您沒有權限存取');
        }
        throw error;
    }
    
    return {
        id: data.id,
        name: data.name,
        phone: data.phone,
        city: data.city,
        district: data.district,
        village: data.village,
        neighborhood: data.neighborhood,
        streetType: data.street_type,
        streetName: data.street_name,
        lane: data.lane,
        alley: data.alley,
        number: data.number,
        floor: data.floor,
        fullAddress: data.full_address,
        healthStatus: data.health_status,
        medications: data.medications,
        supplements: data.supplements,
        avatar: data.avatar,
        createdAt: data.created_at
    };
}

async function addCustomerToSupabase(customerData) {
    const id = Date.now().toString();
    const user = await getCurrentUser();
    
    const { data, error } = await supabaseClient
        .from('customers')
        .insert({
            id: id,
            name: customerData.name || '',
            phone: customerData.phone || '',
            city: customerData.city || '',
            district: customerData.district || '',
            village: customerData.village || '',
            neighborhood: customerData.neighborhood || '',
            street_type: customerData.streetType || '',
            street_name: customerData.streetName || '',
            lane: customerData.lane || '',
            alley: customerData.alley || '',
            number: customerData.number || '',
            floor: customerData.floor || '',
            full_address: customerData.fullAddress || '',
            health_status: customerData.healthStatus || '',
            medications: customerData.medications || '',
            supplements: customerData.supplements || '',
            avatar: customerData.avatar || '',
            user_login: user ? user.userLogin : null // 使用 user_login
        })
        .select()
        .single();
    
    if (error) throw error;
    
    return {
        id: data.id,
        ...customerData
    };
}

async function updateCustomerInSupabase(id, customerData) {
    const user = await getCurrentUser();
    if (!user) {
        throw new Error('未登入，無法更新客戶資料');
    }
    
    // 先檢查是否為自己的資料（使用 user_login 串聯）
    const { data: existing, error: checkError } = await supabaseClient
        .from('customers')
        .select('user_login')
        .eq('id', id)
        .eq('user_login', user.userLogin)
        .single();
    
    if (checkError || !existing) {
        throw new Error('找不到指定的客戶資料或您沒有權限修改');
    }
    
    const { data, error } = await supabaseClient
        .from('customers')
        .update({
            name: customerData.name || '',
            phone: customerData.phone || '',
            city: customerData.city || '',
            district: customerData.district || '',
            village: customerData.village || '',
            neighborhood: customerData.neighborhood || '',
            street_type: customerData.streetType || '',
            street_name: customerData.streetName || '',
            lane: customerData.lane || '',
            alley: customerData.alley || '',
            number: customerData.number || '',
            floor: customerData.floor || '',
            full_address: customerData.fullAddress || '',
            health_status: customerData.healthStatus || '',
            medications: customerData.medications || '',
            supplements: customerData.supplements || '',
            avatar: customerData.avatar || ''
        })
        .eq('id', id)
        .eq('user_login', user.userLogin) // 使用 user_login 串聯
        .select()
        .single();
    
    if (error) throw error;
    
    return {
        id: data.id,
        ...customerData
    };
}

async function deleteCustomerFromSupabase(id) {
    const user = await getCurrentUser();
    if (!user) {
        throw new Error('未登入，無法刪除客戶資料');
    }
    
    // 確保只能刪除自己的資料（使用 user_login 串聯）
    const { error } = await supabaseClient
        .from('customers')
        .delete()
        .eq('id', id)
        .eq('user_login', user.userLogin); // 使用 user_login 串聯
    
    if (error) {
        if (error.code === 'PGRST116') {
            throw new Error('找不到指定的客戶資料或您沒有權限刪除');
        }
        throw error;
    }
    
    return { success: true };
}

// ==================== 行程資料操作 ====================

async function getAllSchedulesFromSupabase() {
    const user = await getCurrentUser();
    if (!user) {
        throw new Error('未登入，無法取得行程資料');
    }
    
    // 只取得當前使用者建立的行程（使用 user_login 串聯）
    const { data: schedules, error: schedulesError } = await supabaseClient
        .from('schedules')
        .select('*')
        .eq('user_login', user.userLogin) // 使用 user_login 串聯
        .order('date', { ascending: true });
    
    if (schedulesError) throw schedulesError;
    
    // 如果有客戶 ID，取得客戶名稱（只取得自己的客戶）
    const customerIds = [...new Set(schedules.filter(s => s.customer_id).map(s => s.customer_id))];
    let customerMap = {};
    
    if (customerIds.length > 0) {
        const { data: customers, error: customersError } = await supabaseClient
            .from('customers')
            .select('id, name')
            .in('id', customerIds)
            .eq('user_login', user.userLogin); // 使用 user_login 串聯
        
        if (customersError) throw customersError;
        
        customers.forEach(c => {
            customerMap[c.id] = c.name;
        });
    }
    
    return schedules.map(s => ({
        id: s.id,
        title: s.title,
        date: s.date,
        startTime: s.start_time,
        endTime: s.end_time,
        type: s.type,
        customerId: s.customer_id,
        customerName: customerMap[s.customer_id] || '',
        notes: s.notes
    }));
}

async function addScheduleToSupabase(scheduleData) {
    const id = Date.now().toString();
    const user = await getCurrentUser();
    
    const { data, error } = await supabaseClient
        .from('schedules')
        .insert({
            id: id,
            title: scheduleData.title || '',
            date: scheduleData.date || '',
            start_time: scheduleData.startTime || null,
            end_time: scheduleData.endTime || null,
            type: scheduleData.type || 'other',
            customer_id: scheduleData.customerId || null,
            notes: scheduleData.notes || '',
            user_login: user ? user.userLogin : null // 使用 user_login
        })
        .select()
        .single();
    
    if (error) throw error;
    
    return {
        id: data.id,
        ...scheduleData
    };
}

async function deleteScheduleFromSupabase(id) {
    const user = await getCurrentUser();
    if (!user) {
        throw new Error('未登入，無法刪除行程');
    }
    
    // 確保只能刪除自己的行程（使用 user_login 串聯）
    const { error } = await supabaseClient
        .from('schedules')
        .delete()
        .eq('id', id)
        .eq('user_login', user.userLogin); // 使用 user_login 串聯
    
    if (error) {
        if (error.code === 'PGRST116') {
            throw new Error('找不到指定的行程或您沒有權限刪除');
        }
        throw error;
    }
    
    return { success: true };
}

// ==================== 訂單資料操作 ====================

async function getAllOrdersFromSupabase() {
    const user = await getCurrentUser();
    if (!user) {
        throw new Error('未登入，無法取得訂單資料');
    }
    
    // 只取得當前使用者建立的訂單（使用 user_login 串聯）
    const { data: orders, error: ordersError } = await supabaseClient
        .from('orders')
        .select('*')
        .eq('user_login', user.userLogin) // 使用 user_login 串聯
        .order('date', { ascending: false });
    
    if (ordersError) throw ordersError;
    
    // 如果有客戶 ID，取得客戶名稱（只取得自己的客戶）
    const customerIds = [...new Set(orders.filter(o => o.customer_id).map(o => o.customer_id))];
    let customerMap = {};
    
    if (customerIds.length > 0) {
        const { data: customers, error: customersError } = await supabaseClient
            .from('customers')
            .select('id, name')
            .in('id', customerIds)
            .eq('user_login', user.userLogin); // 使用 user_login 串聯
        
        if (customersError) throw customersError;
        
        customers.forEach(c => {
            customerMap[c.id] = c.name;
        });
    }
    
    return orders.map(o => ({
        id: o.id,
        date: o.date,
        customerId: o.customer_id,
        customerName: customerMap[o.customer_id] || '',
        product: o.product,
        quantity: o.quantity,
        amount: o.amount,
        paid: o.paid,
        notes: o.notes
    }));
}

async function addOrderToSupabase(orderData) {
    const id = Date.now().toString();
    const user = await getCurrentUser();
    
    const { data, error } = await supabaseClient
        .from('orders')
        .insert({
            id: id,
            date: orderData.date || '',
            customer_id: orderData.customerId || null,
            product: orderData.product || '',
            quantity: orderData.quantity || 1,
            amount: orderData.amount || 0,
            paid: orderData.paid === true || orderData.paid === 'true',
            notes: orderData.notes || '',
            user_login: user ? user.userLogin : null // 使用 user_login
        })
        .select()
        .single();
    
    if (error) throw error;
    
    return {
        id: data.id,
        ...orderData
    };
}

async function updateOrderInSupabase(id, orderData) {
    const user = await getCurrentUser();
    if (!user) {
        throw new Error('未登入，無法更新訂單');
    }
    
    // 確保只能更新自己的訂單（使用 user_login 串聯）
    const { data, error } = await supabaseClient
        .from('orders')
        .update({
            date: orderData.date || '',
            customer_id: orderData.customerId || null,
            product: orderData.product || '',
            quantity: orderData.quantity || 1,
            amount: orderData.amount || 0,
            paid: orderData.paid === true || orderData.paid === 'true',
            notes: orderData.notes || ''
        })
        .eq('id', id)
        .eq('user_login', user.userLogin) // 使用 user_login 串聯
        .select()
        .single();
    
    if (error) {
        if (error.code === 'PGRST116') {
            throw new Error('找不到指定的訂單或您沒有權限修改');
        }
        throw error;
    }
    
    return {
        id: data.id,
        ...orderData
    };
}

async function deleteOrderFromSupabase(id) {
    const user = await getCurrentUser();
    if (!user) {
        throw new Error('未登入，無法刪除訂單');
    }
    
    // 確保只能刪除自己的訂單（使用 user_login 串聯）
    const { error } = await supabaseClient
        .from('orders')
        .delete()
        .eq('id', id)
        .eq('user_login', user.userLogin); // 使用 user_login 串聯
    
    if (error) {
        if (error.code === 'PGRST116') {
            throw new Error('找不到指定的訂單或您沒有權限刪除');
        }
        throw error;
    }
    
    return { success: true };
}


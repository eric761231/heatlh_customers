/**
 * Java 後端 API 客戶端
 * 用於呼叫 Java Spring Boot 後端 API
 */

// API 基礎 URL（請根據實際部署位置修改）
const JAVA_API_BASE_URL = 'http://localhost:8080/api';

/**
 * 取得當前使用者 ID（從 Supabase Auth）
 */
async function getCurrentUserId() {
    try {
        if (typeof supabase === 'undefined' || typeof SUPABASE_URL === 'undefined' || typeof SUPABASE_ANON_KEY === 'undefined') {
            throw new Error('Supabase 未初始化');
        }
        
        const client = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
        const { data: { session }, error } = await client.auth.getSession();
        
        if (error || !session || !session.user) {
            throw new Error('未登入');
        }
        
        return session.user.id; // 使用 Supabase Auth 的 user ID
    } catch (e) {
        console.error('取得使用者 ID 失敗:', e);
        throw new Error('未登入，無法取得使用者資訊');
    }
}

/**
 * 通用 API 呼叫函數
 */
async function javaApiCall(endpoint, method = 'GET', data = null, userId = null) {
    try {
        // 如果沒有提供 userId，自動取得
        if (!userId) {
            userId = await getCurrentUserId();
        }
        
        const url = `${JAVA_API_BASE_URL}${endpoint}?userId=${encodeURIComponent(userId)}`;
        
        const options = {
            method: method,
            headers: {
                'Content-Type': 'application/json'
            }
        };
        
        if (data && (method === 'POST' || method === 'PUT')) {
            options.body = JSON.stringify(data);
        }
        
        const response = await fetch(url, options);
        
        if (!response.ok) {
            const errorData = await response.json().catch(() => ({ error: '未知錯誤' }));
            throw new Error(errorData.error || `HTTP error! status: ${response.status}`);
        }
        
        return await response.json();
    } catch (error) {
        console.error('Java API 錯誤:', error);
        throw error;
    }
}

/**
 * Supabase API 呼叫函數（替代原有的 supabaseCall）
 * 現在改為呼叫 Java 後端
 */
async function supabaseCall(action, data = null, id = null) {
    try {
        const userId = await getCurrentUserId();
        
        switch(action) {
            case 'getAll':
                return await javaApiCall('/customers', 'GET', null, userId);
            case 'getById':
                return await javaApiCall(`/customers/${id}`, 'GET', null, userId);
            case 'add':
                return await javaApiCall('/customers', 'POST', data, userId);
            case 'update':
                return await javaApiCall(`/customers/${id}`, 'PUT', data, userId);
            case 'delete':
                return await javaApiCall(`/customers/${id}`, 'DELETE', null, userId);
            case 'getSchedules':
                return await javaApiCall('/schedules', 'GET', null, userId);
            case 'addSchedule':
                return await javaApiCall('/schedules', 'POST', data, userId);
            case 'deleteSchedule':
                return await javaApiCall(`/schedules/${id}`, 'DELETE', null, userId);
            case 'getOrders':
                return await javaApiCall('/orders', 'GET', null, userId);
            case 'addOrder':
                return await javaApiCall('/orders', 'POST', data, userId);
            case 'updateOrder':
                return await javaApiCall(`/orders/${id}`, 'PUT', data, userId);
            case 'deleteOrder':
                return await javaApiCall(`/orders/${id}`, 'DELETE', null, userId);
            default:
                throw new Error('未知的操作');
        }
    } catch (error) {
        console.error('API 呼叫錯誤:', error);
        throw error;
    }
}

/**
 * 客戶資料轉換函數（將 Java 後端格式轉換為前端格式）
 */
function convertCustomerFromJava(customer) {
    return {
        id: customer.id,
        name: customer.name,
        phone: customer.phone,
        city: customer.city,
        district: customer.district,
        village: customer.village,
        neighborhood: customer.neighborhood,
        streetType: customer.streetType,
        streetName: customer.streetName,
        lane: customer.lane,
        alley: customer.alley,
        number: customer.number,
        floor: customer.floor,
        fullAddress: customer.fullAddress,
        healthStatus: customer.healthStatus,
        medications: customer.medications,
        supplements: customer.supplements,
        avatar: customer.avatar,
        createdAt: customer.createdAt
    };
}

/**
 * 客戶資料轉換函數（將前端格式轉換為 Java 後端格式）
 */
function convertCustomerToJava(customer) {
    return {
        name: customer.name || '',
        phone: customer.phone || '',
        city: customer.city || '',
        district: customer.district || '',
        village: customer.village || '',
        neighborhood: customer.neighborhood || '',
        streetType: customer.streetType || '',
        streetName: customer.streetName || '',
        lane: customer.lane || '',
        alley: customer.alley || '',
        number: customer.number || '',
        floor: customer.floor || '',
        fullAddress: customer.fullAddress || '',
        healthStatus: customer.healthStatus || '',
        medications: customer.medications || '',
        supplements: customer.supplements || '',
        avatar: customer.avatar || ''
    };
}


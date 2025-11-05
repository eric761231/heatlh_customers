// 登入驗證
async function checkAuth() {
    try {
        // 檢查 Supabase 會話
        if (typeof supabase === 'undefined' || typeof SUPABASE_URL === 'undefined' || typeof SUPABASE_ANON_KEY === 'undefined') {
            window.location.href = 'login.html';
            return false;
        }
        
        const client = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
        const { data: { session }, error } = await client.auth.getSession();
        
        if (error || !session || !session.user) {
            window.location.href = 'login.html';
            return false;
        }
        
        return true;
    } catch (e) {
        console.error('驗證登入狀態失敗:', e);
        window.location.href = 'login.html';
        return false;
    }
}

// 登出
async function logout() {
    if (confirm('確定要登出嗎？')) {
        try {
            // 清除 Supabase 會話
            if (typeof supabase !== 'undefined' && typeof SUPABASE_URL !== 'undefined' && typeof SUPABASE_ANON_KEY !== 'undefined') {
                const client = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
                await client.auth.signOut();
            }
            
            // 清除所有相關的 localStorage
            const keysToRemove = [];
            for (let i = 0; i < localStorage.length; i++) {
                const key = localStorage.key(i);
                if (key && (key.includes('cache') || key.includes('supabase'))) {
                    keysToRemove.push(key);
                }
            }
            keysToRemove.forEach(key => localStorage.removeItem(key));
            
            // 清除客戶資料快取（如果存在）
            if (typeof dataCache !== 'undefined' && dataCache) {
                dataCache.customers = null;
                dataCache.customersTimestamp = 0;
            }
            
            // 清除當前使用者快取
            if (typeof currentUser !== 'undefined') {
                currentUser = null;
            }
            
            // 清除 window 物件上的快取
            if (typeof window !== 'undefined') {
                if (typeof window.dataCache !== 'undefined') {
                    window.dataCache = null;
                }
                if (typeof window.currentUser !== 'undefined') {
                    window.currentUser = null;
                }
            }
            
            // 跳轉到登入頁面
            window.location.href = 'login.html';
        } catch (e) {
            console.error('登出失敗:', e);
            // 即使登出失敗也跳轉到登入頁面
            window.location.href = 'login.html';
        }
    }
}

// 側邊欄控制
function toggleSidebar() {
    const sidebar = document.getElementById('sidebar');
    const overlay = document.getElementById('sidebarOverlay');
    
    sidebar.classList.toggle('active');
    overlay.classList.toggle('active');
}

// 顯示載入狀態
function showLoading(element) {
    if (element) {
        element.innerHTML = '<div class="loading">載入中...</div>';
    }
}

// 顯示錯誤訊息
function showError(element, message) {
    if (element) {
        element.innerHTML = `<div class="error-message">${message}</div>`;
    }
}

// 資料快取（減少重複 API 調用）
const dataCache = {
    customers: null,
    customersTimestamp: 0,
    cacheDuration: 60000, // 快取 60 秒
    
    getCustomers: async function() {
        const now = Date.now();
        if (this.customers && (now - this.customersTimestamp) < this.cacheDuration) {
            return this.customers;
        }
        // 直接調用 API，不使用快取避免循環調用
        const customers = await apiCall('getAll');
        this.customers = customers;
        this.customersTimestamp = now;
        return this.customers;
    },
    
    clearCache: function() {
        this.customers = null;
        this.customersTimestamp = 0;
    }
};

// 暴露到 window 物件，以便在登入頁面清除
if (typeof window !== 'undefined') {
    window.dataCache = dataCache;
}

// API 呼叫函數（支援 Java API、Supabase 和 Google Sheets 切換）
async function apiCall(action, data = null, customerId = null) {
    // 如果使用 Java API，調用 Java 後端
    if (typeof DATA_SOURCE !== 'undefined' && DATA_SOURCE === 'java-api') {
        if (typeof supabaseCall === 'undefined') {
            throw new Error('Java API 客戶端未載入，請確認已載入 java-api-client.js');
        }
        return await supabaseCall(action, data, customerId);
    }
    
    // 如果使用 Supabase，調用 Supabase API
    if (typeof DATA_SOURCE !== 'undefined' && DATA_SOURCE === 'supabase') {
        if (typeof supabaseCall === 'undefined') {
            throw new Error('Supabase 客戶端未載入，請確認已載入 supabase-client.js');
        }
        return await supabaseCall(action, data, customerId);
    }
    
    // 否則使用 Google Apps Script
    try {
        const url = new URL(GOOGLE_SCRIPT_URL);
        url.searchParams.append('action', action);
        
        if (customerId) {
            url.searchParams.append('id', customerId);
        }

        const options = {
            method: data ? 'POST' : 'GET',
            headers: {},
            // 添加超時設定（雖然 fetch 不直接支持，但可以通過 AbortController 實現）
        };

        if (data) {
            // 使用表單編碼方式發送數據，避免複雜的 CORS 預檢
            const formData = new URLSearchParams();
            formData.append('data', JSON.stringify(data));
            options.body = formData;
            options.headers['Content-Type'] = 'application/x-www-form-urlencoded';
        }

        // 添加超時控制（30秒）
        const controller = new AbortController();
        const timeoutId = setTimeout(() => controller.abort(), 30000);
        
        try {
            const response = await fetch(url, { ...options, signal: controller.signal });
            clearTimeout(timeoutId);
        
        if (!response.ok) {
                // 處理特定的 HTTP 狀態碼
                if (response.status === 429) {
                    throw new Error('請求過於頻繁，請稍後再試 (429 Too Many Requests)');
                } else if (response.status === 0) {
                    throw new Error('網路連線失敗，請檢查網路連線');
                } else {
            throw new Error(`HTTP error! status: ${response.status}`);
                }
        }

        const result = await response.json();
        
        if (result.success) {
            return result.data;
        } else {
            throw new Error(result.error || '操作失敗');
            }
        } catch (error) {
            clearTimeout(timeoutId);
            if (error.name === 'AbortError') {
                throw new Error('請求超時，請稍後再試');
            }
            throw error;
        }
    } catch (error) {
        console.error('API 錯誤:', error);
        // 如果是網路錯誤，提供更友好的錯誤訊息
        if (error.message.includes('Failed to fetch') || error.message.includes('NetworkError')) {
            throw new Error('網路連線失敗，請檢查網路連線或稍後再試');
        }
        if (error.message.includes('AbortError') || error.message.includes('超時')) {
            throw new Error('請求超時，請稍後再試');
        }
        throw error;
    }
}

// 取得所有客戶（使用快取）
async function getCustomers(useCache = true) {
    try {
        if (useCache) {
            return await dataCache.getCustomers();
        }
        // 不使用快取時直接調用 API
        const customers = await apiCall('getAll');
        // 更新快取
        dataCache.customers = customers;
        dataCache.customersTimestamp = Date.now();
        return customers || [];
    } catch (error) {
        console.error('獲取客戶資料失敗:', error);
        return [];
    }
}

// 取得單個客戶
async function getCustomerById(customerId) {
    try {
        const customer = await apiCall('getById', null, customerId);
        return customer;
    } catch (error) {
        console.error('獲取客戶資料失敗:', error);
        return null;
    }
}

// 新增客戶
async function addCustomer(customerData) {
    try {
        const result = await apiCall('add', customerData);
        dataCache.clearCache(); // 清除快取
        return result;
    } catch (error) {
        console.error('新增客戶失敗:', error);
        throw error;
    }
}

// 更新客戶
async function updateCustomer(customerId, customerData) {
    try {
        const result = await apiCall('update', customerData, customerId);
        dataCache.clearCache(); // 清除快取
        return result;
    } catch (error) {
        console.error('更新客戶失敗:', error);
        throw error;
    }
}

// 刪除客戶
async function deleteCustomerById(customerId) {
    try {
        const result = await apiCall('delete', null, customerId);
        dataCache.clearCache(); // 清除快取
        return result;
    } catch (error) {
        console.error('刪除客戶失敗:', error);
        throw error;
    }
}

// 載入客戶清單
async function loadCustomerList() {
    const customerList = document.getElementById('customerList');
    if (!customerList) return;

    showLoading(customerList);
    
    try {
        const customers = await getCustomers();
        
        if (customers.length === 0) {
            customerList.innerHTML = '<p class="empty-message">尚無客戶資料</p>';
            return;
        }
        
        customerList.innerHTML = customers.map(customer => `
            <div class="customer-item" onclick="window.location.href='customers.html'">
                <div class="customer-item-avatar">
                    ${customer.avatar ? `<img src="${customer.avatar}" alt="${customer.name}">` : '<span>' + (customer.name ? customer.name.charAt(0) : '?') + '</span>'}
                </div>
                <div class="customer-item-info">
                    <div class="customer-item-name">${customer.name || '未命名'}</div>
                    <div class="customer-item-phone">📞 ${customer.phone || '未提供'}</div>
                </div>
            </div>
        `).join('');
    } catch (error) {
        showError(customerList, '載入客戶清單失敗，請檢查網路連線或設定');
    }
}

// 跳轉到客戶詳細資料頁面（已廢棄，客戶詳細資料已整合到手風琴列表中）
// function goToCustomerDetail(customerId) {
//     window.location.href = `customer-detail.html?id=${customerId}`;
//     toggleSidebar(); // 關閉側邊欄
// }

// 處理頭像上傳
function handleAvatarUpload(event) {
    const file = event.target.files[0];
    if (!file) return;
    
    if (!file.type.startsWith('image/')) {
        alert('請選擇圖片檔案');
        return;
    }
    
    // 檢查檔案大小（限制 2MB）
    if (file.size > 2 * 1024 * 1024) {
        alert('圖片檔案大小不能超過 2MB');
        event.target.value = '';
        return;
    }
    
    const reader = new FileReader();
    reader.onload = function(e) {
        const avatarPreview = document.getElementById('avatarPreview');
        avatarPreview.innerHTML = `<img src="${e.target.result}" alt="預覽">`;
    };
    reader.readAsDataURL(file);
}

// 初始化縣市選單
function initCitySelect() {
    const citySelect = document.getElementById('city');
    if (!citySelect) return;
    
    const cities = getAllCities();
    citySelect.innerHTML = '<option value="">請選擇縣市</option>';
    
    cities.forEach(city => {
        const option = document.createElement('option');
        option.value = city;
        option.textContent = city;
        citySelect.appendChild(option);
    });
}

// 更新鄉鎮市區選單
function updateDistricts() {
    const citySelect = document.getElementById('city');
    const districtSelect = document.getElementById('district');
    
    if (!citySelect || !districtSelect) return;
    
    const selectedCity = citySelect.value;
    districtSelect.innerHTML = '<option value="">請選擇鄉鎮市區</option>';
    
    if (selectedCity) {
        const districts = getDistrictsByCity(selectedCity);
        districts.forEach(district => {
            const option = document.createElement('option');
            option.value = district;
            option.textContent = district;
            districtSelect.appendChild(option);
        });
    }
    
    // 更新完整地址預覽
    updateAddressPreview();
}

// 組合完整地址
function buildFullAddress() {
    const addressDetail = document.getElementById('addressDetail');
    if (!addressDetail) return '';
    
    const manualAddress = addressDetail.value.trim();
    
    // 如果手動輸入完整地址，優先使用
    if (manualAddress) {
        return manualAddress;
    }
    
    const city = document.getElementById('city').value || '';
    const district = document.getElementById('district').value || '';
    const village = document.getElementById('village').value.trim() || '';
    const neighborhood = document.getElementById('neighborhood').value.trim() || '';
    const streetType = document.getElementById('streetType').value || '';
    const streetName = document.getElementById('streetName').value.trim() || '';
    const lane = document.getElementById('lane').value.trim() || '';
    const alley = document.getElementById('alley').value.trim() || '';
    const number = document.getElementById('number').value.trim() || '';
    const floor = document.getElementById('floor').value.trim() || '';
    
    const addressParts = [];
    
    if (city) addressParts.push(city);
    if (district) addressParts.push(district);
    if (village) addressParts.push(village);
    if (neighborhood) {
        // 如果鄰已經包含"鄰"字，直接使用；否則加上"鄰"
        addressParts.push(neighborhood.includes('鄰') ? neighborhood : neighborhood + '鄰');
    }
    
    if (streetName) {
        if (streetType) {
            addressParts.push(streetName + streetType);
        } else {
            addressParts.push(streetName);
        }
    }
    
    if (lane) addressParts.push(lane + '巷');
    if (alley) addressParts.push(alley + '弄');
    if (number) addressParts.push(number + '號');
    if (floor) addressParts.push(floor);
    
    return addressParts.join('');
}

// 更新地址預覽
function updateAddressPreview() {
    const addressDetail = document.getElementById('addressDetail');
    if (!addressDetail) return;
    
    // 如果用戶正在手動輸入，不自動更新
    if (document.activeElement === addressDetail) {
        return;
    }
    
    const fullAddress = buildFullAddress();
    if (fullAddress) {
        // 只有在沒有手動輸入或手動輸入與自動組合相同時才更新
        if (!addressDetail.value.trim() || addressDetail.dataset.autoGenerated === 'true') {
            addressDetail.value = fullAddress;
            addressDetail.dataset.autoGenerated = 'true';
        }
    }
}

// 監聽地址欄位變化
function setupAddressListeners() {
    const addressFields = ['city', 'district', 'village', 'neighborhood', 'streetType', 'streetName', 'lane', 'alley', 'number', 'floor'];
    addressFields.forEach(fieldId => {
        const field = document.getElementById(fieldId);
        if (field) {
            field.addEventListener('change', updateAddressPreview);
            field.addEventListener('input', updateAddressPreview);
        }
    });
    
    // 監聽完整地址欄位
    const addressDetail = document.getElementById('addressDetail');
    if (addressDetail) {
        // 當用戶開始輸入時，標記為手動輸入
        addressDetail.addEventListener('focus', function() {
            this.dataset.autoGenerated = 'false';
        });
        
        // 當用戶輸入時，標記為手動輸入
        addressDetail.addEventListener('input', function() {
            this.dataset.autoGenerated = 'false';
        });
    }
}

// 處理表單提交
async function handleSubmit(event) {
    event.preventDefault();
    
    // 取得表單資料
    const name = document.getElementById('name').value.trim();
    const phone = document.getElementById('phone').value.trim();
    const city = document.getElementById('city').value;
    const district = document.getElementById('district').value;
    const village = document.getElementById('village').value.trim();
    const neighborhood = document.getElementById('neighborhood').value.trim();
    const streetType = document.getElementById('streetType').value;
    const streetName = document.getElementById('streetName').value.trim();
    const lane = document.getElementById('lane').value.trim();
    const alley = document.getElementById('alley').value.trim();
    const number = document.getElementById('number').value.trim();
    const floor = document.getElementById('floor').value.trim();
    const addressDetail = document.getElementById('addressDetail').value.trim();
    const healthStatus = document.getElementById('healthStatus').value.trim();
    const medications = document.getElementById('medications').value.trim();
    const supplements = document.getElementById('supplements').value.trim();
    
    if (!name || !phone || !city || !district) {
        alert('請填寫必填欄位（姓名、電話、縣市、鄉鎮市區）');
        return;
    }
    
    // 組合完整地址
    const fullAddress = addressDetail || buildFullAddress();
    
    // 取得頭像
    const avatarFile = document.getElementById('avatar').files[0];
    let avatar = '';
    
    if (avatarFile) {
        const reader = new FileReader();
        reader.onload = async function(e) {
            avatar = e.target.result;
            await saveCustomer(name, phone, city, district, village, neighborhood, streetType, streetName, lane, alley, number, floor, fullAddress, healthStatus, medications, supplements, avatar);
        };
        reader.readAsDataURL(avatarFile);
    } else {
        await saveCustomer(name, phone, city, district, village, neighborhood, streetType, streetName, lane, alley, number, floor, fullAddress, healthStatus, medications, supplements, avatar);
    }
}

// 儲存客戶
async function saveCustomer(name, phone, city, district, village, neighborhood, streetType, streetName, lane, alley, number, floor, fullAddress, healthStatus, medications, supplements, avatar) {
    try {
        // 建立新客戶物件
        const newCustomer = {
            name: name,
            phone: phone,
            city: city,
            district: district,
            village: village || '',
            neighborhood: neighborhood || '',
            streetType: streetType || '',
            streetName: streetName || '',
            lane: lane || '',
            alley: alley || '',
            number: number || '',
            floor: floor || '',
            fullAddress: fullAddress || '',
            healthStatus: healthStatus || '',
            medications: medications || '',
            supplements: supplements || '',
            avatar: avatar || '',
            createdAt: new Date().toISOString()
        };
        
        // 顯示載入中
        const submitBtn = document.querySelector('button[type="submit"]');
        const originalText = submitBtn.textContent;
        submitBtn.disabled = true;
        submitBtn.textContent = '儲存中...';
        
        // 呼叫 API 新增客戶
        await addCustomer(newCustomer);
        
        // 更新側邊欄客戶清單
        await loadCustomerList();
        
        // 重置表單
        document.getElementById('customerForm').reset();
        document.getElementById('avatarPreview').innerHTML = '<span>點擊選擇圖片</span>';
        
        // 恢復按鈕
        submitBtn.disabled = false;
        submitBtn.textContent = originalText;
        
        // 顯示成功訊息
        alert('客戶資料已成功新增！');
    } catch (error) {
        alert('新增客戶失敗：' + error.message);
        const submitBtn = document.querySelector('button[type="submit"]');
        submitBtn.disabled = false;
        submitBtn.textContent = '新增客戶';
    }
}

// 行程相關 API
async function getSchedules() {
    try {
        const schedules = await apiCall('getSchedules');
        return schedules || [];
    } catch (error) {
        console.error('獲取行程失敗:', error);
        return [];
    }
}

async function addSchedule(scheduleData) {
    try {
        const result = await apiCall('addSchedule', scheduleData);
        return result;
    } catch (error) {
        console.error('新增行程失敗:', error);
        throw error;
    }
}

async function deleteScheduleById(scheduleId) {
    try {
        const result = await apiCall('deleteSchedule', null, scheduleId);
        return result;
    } catch (error) {
        console.error('刪除行程失敗:', error);
        throw error;
    }
}

// 訂單相關 API
async function getOrders() {
    try {
        const orders = await apiCall('getOrders');
        return orders || [];
    } catch (error) {
        console.error('獲取訂單失敗:', error);
        return [];
    }
}

async function addOrder(orderData) {
    try {
        const result = await apiCall('addOrder', orderData);
        return result;
    } catch (error) {
        console.error('新增訂單失敗:', error);
        throw error;
    }
}

async function updateOrder(orderId, orderData) {
    try {
        const result = await apiCall('updateOrder', orderData, orderId);
        return result;
    } catch (error) {
        console.error('更新訂單失敗:', error);
        throw error;
    }
}

async function deleteOrderById(orderId) {
    try {
        const result = await apiCall('deleteOrder', null, orderId);
        return result;
    } catch (error) {
        console.error('刪除訂單失敗:', error);
        throw error;
    }
}

// 頁面載入時初始化
document.addEventListener('DOMContentLoaded', async function() {
    // 檢查是否設定 Google Script URL
    if (!GOOGLE_SCRIPT_URL || GOOGLE_SCRIPT_URL === 'YOUR_GOOGLE_SCRIPT_URL_HERE') {
        console.warn('請在 config.js 中設定 Google Apps Script Web App URL');
        const customerList = document.getElementById('customerList');
        if (customerList) {
            customerList.innerHTML = '<p class="error-message">請先設定 Google Apps Script URL（config.js）</p>';
        }
        return;
    }
    
    // 只在主頁面載入客戶清單和初始化表單
    if (document.getElementById('customerForm')) {
        initCitySelect();
        setupAddressListeners();
        await loadCustomerList();
    }
});

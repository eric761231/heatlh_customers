/**
 * Google Apps Script 代碼
 * 
 * 使用說明：
 * 1. 前往 https://script.google.com/
 * 2. 點擊「新增專案」
 * 3. 將此代碼貼上並儲存
 * 4. 點擊「部署」>「新增部署作業」
 * 5. 選擇「網頁應用程式」
 * 6. 設定：
 *    - 執行身分：我
 *    - 具有存取權的使用者：任何人
 * 7. 點擊「部署」，複製 Web App URL
 * 8. 將 URL 貼到 config.js 中的 GOOGLE_SCRIPT_URL
 * 
 * Google 試算表設定：
 * 1. 建立新的 Google 試算表
 * 2. 在第一行建立標題列（系統會自動建立）：
 *    ID | 姓名 | 電話 | 縣市 | 鄉鎮市區 | 村/里 | 鄰 | 路街類型 | 路街名稱 | 巷 | 弄 | 號 | 樓 | 完整地址 | 健康狀況 | 藥物 | 保健食品 | 頭像 | 建立時間
 * 3. 將試算表的 ID（網址中的 /d/SPREADSHEET_ID/edit 部分）複製
 * 4. 將 SPREADSHEET_ID 替換到下方代碼中
 */

// 請替換為您的 Google 試算表 ID
const SPREADSHEET_ID = '1RTZQgHZcVifOkYBvqwqNdligpdK3TTUgogv4HM5_CsY';

// 試算表名稱（客戶資料工作表）
const SHEET_NAME = '客戶資料';

/**
 * 處理 HTTP 請求
 */
function doGet(e) {
    return handleRequest(e);
}

function doPost(e) {
    return handleRequest(e);
}

function handleRequest(e) {
    try {
        const action = e.parameter.action;
        let result;
        
        // 解析 POST 數據（支援 JSON 和表單編碼格式）
        let postData = null;
        if (e.postData) {
            if (e.postData.type === 'application/json') {
                postData = JSON.parse(e.postData.contents);
            } else if (e.postData.type === 'application/x-www-form-urlencoded') {
                // 處理表單編碼數據
                const params = e.postData.contents.split('&');
                for (let param of params) {
                    const [key, value] = param.split('=');
                    if (key === 'data') {
                        postData = JSON.parse(decodeURIComponent(value));
                        break;
                    }
                }
            } else {
                // 嘗試解析為 JSON
                try {
                    postData = JSON.parse(e.postData.contents);
                } catch (err) {
                    // 如果不是 JSON，嘗試表單解析
                    const params = e.postData.contents.split('&');
                    for (let param of params) {
                        const [key, value] = param.split('=');
                        if (key === 'data') {
                            postData = JSON.parse(decodeURIComponent(value));
                            break;
                        }
                    }
                }
            }
        }
        
        switch(action) {
            case 'getAll':
                result = getAllCustomers();
                break;
            case 'getById':
                result = getCustomerById(e.parameter.id);
                break;
            case 'add':
                if (!postData) {
                    throw new Error('缺少客戶資料');
                }
                result = addCustomer(postData);
                break;
            case 'update':
                if (!postData || !e.parameter.id) {
                    throw new Error('缺少客戶資料或 ID');
                }
                result = updateCustomer(e.parameter.id, postData);
                break;
            case 'delete':
                result = deleteCustomer(e.parameter.id);
                break;
            case 'getSchedules':
                result = getAllSchedules();
                break;
            case 'addSchedule':
                if (!postData) {
                    throw new Error('缺少行程資料');
                }
                result = addSchedule(postData);
                break;
            case 'deleteSchedule':
                result = deleteSchedule(e.parameter.id);
                break;
            case 'getOrders':
                result = getAllOrders();
                break;
            case 'addOrder':
                if (!postData) {
                    throw new Error('缺少訂單資料');
                }
                result = addOrder(postData);
                break;
            case 'updateOrder':
                if (!postData) {
                    throw new Error('缺少訂單資料');
                }
                result = updateOrder(e.parameter.id, postData);
                break;
            case 'deleteOrder':
                result = deleteOrder(e.parameter.id);
                break;
            default:
                return createResponse(false, null, '未知的操作');
        }
        
        return createResponse(true, result);
    } catch (error) {
        return createResponse(false, null, error.toString());
    }
}

/**
 * 取得試算表
 */
function getSheet() {
    const spreadsheet = SpreadsheetApp.openById(SPREADSHEET_ID);
    let sheet = spreadsheet.getSheetByName(SHEET_NAME);
    
    // 如果工作表不存在，建立新的
    if (!sheet) {
        sheet = spreadsheet.insertSheet(SHEET_NAME);
        // 建立標題列（19欄：加入村/里和鄰）
        sheet.getRange(1, 1, 1, 19).setValues([[
            'ID', '姓名', '電話', '縣市', '鄉鎮市區', '村/里', '鄰', '路街類型', '路街名稱', '巷', '弄', '號', '樓', '完整地址', '健康狀況', '藥物', '保健食品', '頭像', '建立時間'
        ]]);
        sheet.getRange(1, 1, 1, 19).setFontWeight('bold');
    }
    
    return sheet;
}

/**
 * 取得所有客戶
 */
function getAllCustomers() {
    const sheet = getSheet();
    const data = sheet.getDataRange().getValues();
    
    // 跳過標題列
    const customers = [];
    for (let i = 1; i < data.length; i++) {
        if (data[i][0]) { // 如果有 ID
            // 支援新舊格式
            const customer = {
                id: data[i][0],
                name: data[i][1] || '',
                phone: data[i][2] || '',
                createdAt: ''
            };
            
            // 檢查是否為最新格式（19欄：有村/里和鄰）
            // 或舊格式（17欄：沒有村/里和鄰）
            // 或更舊格式（9欄：舊的格式）
            if (data.length > 0 && data[i].length >= 19 && data[i][5] !== undefined) {
                // 最新格式（19欄，包含村/里和鄰）
                customer.city = data[i][3] || '';
                customer.district = data[i][4] || '';
                customer.village = data[i][5] || '';
                customer.neighborhood = data[i][6] || '';
                customer.streetType = data[i][7] || '';
                customer.streetName = data[i][8] || '';
                customer.lane = data[i][9] || '';
                customer.alley = data[i][10] || '';
                customer.number = data[i][11] || '';
                customer.floor = data[i][12] || '';
                customer.fullAddress = data[i][13] || '';
                customer.healthStatus = data[i][14] || '';
                customer.medications = data[i][15] || '';
                customer.supplements = data[i][16] || '';
                customer.avatar = data[i][17] || '';
                customer.createdAt = data[i][18] || '';
                // 為了向後兼容，保留 region 欄位
                customer.region = customer.city + customer.district;
            } else if (data.length > 0 && data[i].length >= 12 && data[i][4] !== undefined) {
                // 舊格式（17欄，沒有村/里和鄰）
                customer.city = data[i][3] || '';
                customer.district = data[i][4] || '';
                customer.village = '';
                customer.neighborhood = '';
                customer.streetType = data[i][5] || '';
                customer.streetName = data[i][6] || '';
                customer.lane = data[i][7] || '';
                customer.alley = data[i][8] || '';
                customer.number = data[i][9] || '';
                customer.floor = data[i][10] || '';
                customer.fullAddress = data[i][11] || '';
                customer.healthStatus = data[i][12] || '';
                customer.medications = data[i][13] || '';
                customer.supplements = data[i][14] || '';
                customer.avatar = data[i][15] || '';
                customer.createdAt = data[i][16] || '';
                // 為了向後兼容，保留 region 欄位
                customer.region = customer.city + customer.district;
            } else {
                // 舊格式（向後兼容）
                customer.region = data[i][3] || '';
                customer.city = '';
                customer.district = '';
                customer.streetType = '';
                customer.streetName = '';
                customer.lane = '';
                customer.alley = '';
                customer.number = '';
                customer.floor = '';
                customer.fullAddress = data[i][3] || '';
                customer.healthStatus = data[i][4] || '';
                customer.medications = data[i][5] || '';
                customer.supplements = data[i][6] || '';
                customer.avatar = data[i][7] || '';
            }
            
            customers.push(customer);
        }
    }
    
    return customers;
}

/**
 * 根據 ID 取得客戶
 */
function getCustomerById(id) {
    const sheet = getSheet();
    const data = sheet.getDataRange().getValues();
    
    for (let i = 1; i < data.length; i++) {
        if (data[i][0] === id) {
            // 支援新舊格式
            const customer = {
                id: data[i][0],
                name: data[i][1] || '',
                phone: data[i][2] || '',
                createdAt: ''
            };
            
            // 檢查是否為最新格式（19欄：有村/里和鄰）
            // 或舊格式（17欄：沒有村/里和鄰）
            // 或更舊格式（9欄：舊的格式）
            if (data.length > 0 && data[i].length >= 19 && data[i][5] !== undefined) {
                // 最新格式（19欄，包含村/里和鄰）
                customer.city = data[i][3] || '';
                customer.district = data[i][4] || '';
                customer.village = data[i][5] || '';
                customer.neighborhood = data[i][6] || '';
                customer.streetType = data[i][7] || '';
                customer.streetName = data[i][8] || '';
                customer.lane = data[i][9] || '';
                customer.alley = data[i][10] || '';
                customer.number = data[i][11] || '';
                customer.floor = data[i][12] || '';
                customer.fullAddress = data[i][13] || '';
                customer.healthStatus = data[i][14] || '';
                customer.medications = data[i][15] || '';
                customer.supplements = data[i][16] || '';
                customer.avatar = data[i][17] || '';
                customer.createdAt = data[i][18] || '';
                customer.region = customer.city + customer.district;
            } else if (data.length > 0 && data[i].length >= 12 && data[i][4] !== undefined) {
                // 舊格式（17欄，沒有村/里和鄰）
                customer.city = data[i][3] || '';
                customer.district = data[i][4] || '';
                customer.village = '';
                customer.neighborhood = '';
                customer.streetType = data[i][5] || '';
                customer.streetName = data[i][6] || '';
                customer.lane = data[i][7] || '';
                customer.alley = data[i][8] || '';
                customer.number = data[i][9] || '';
                customer.floor = data[i][10] || '';
                customer.fullAddress = data[i][11] || '';
                customer.healthStatus = data[i][12] || '';
                customer.medications = data[i][13] || '';
                customer.supplements = data[i][14] || '';
                customer.avatar = data[i][15] || '';
                customer.createdAt = data[i][16] || '';
                customer.region = customer.city + customer.district;
            } else {
                // 更舊格式（向後兼容，9欄）
                customer.region = data[i][3] || '';
                customer.city = '';
                customer.district = '';
                customer.village = '';
                customer.neighborhood = '';
                customer.streetType = '';
                customer.streetName = '';
                customer.lane = '';
                customer.alley = '';
                customer.number = '';
                customer.floor = '';
                customer.fullAddress = data[i][3] || '';
                customer.healthStatus = data[i][4] || '';
                customer.medications = data[i][5] || '';
                customer.supplements = data[i][6] || '';
                customer.avatar = data[i][7] || '';
            }
            
            return customer;
        }
    }
    
    return null;
}

/**
 * 新增客戶
 */
function addCustomer(customerData) {
    const sheet = getSheet();
    
    // 產生唯一 ID
    const id = Date.now().toString();
    
    // 準備資料（最新格式，包含村/里和鄰）
    const row = [
        id,
        customerData.name || '',
        customerData.phone || '',
        customerData.city || '',
        customerData.district || '',
        customerData.village || '',
        customerData.neighborhood || '',
        customerData.streetType || '',
        customerData.streetName || '',
        customerData.lane || '',
        customerData.alley || '',
        customerData.number || '',
        customerData.floor || '',
        customerData.fullAddress || '',
        customerData.healthStatus || '',
        customerData.medications || '',
        customerData.supplements || '',
        customerData.avatar || '',
        customerData.createdAt || new Date().toISOString()
    ];
    
    // 新增到試算表
    sheet.appendRow(row);
    
    return {
        id: id,
        ...customerData
    };
}

/**
 * 更新客戶
 */
function updateCustomer(id, customerData) {
    const sheet = getSheet();
    const data = sheet.getDataRange().getValues();
    
    for (let i = 1; i < data.length; i++) {
        if (data[i][0] === id) {
            // 準備更新資料（最新格式，包含村/里和鄰）
            const row = [
                id, // 保持原 ID
                customerData.name || '',
                customerData.phone || '',
                customerData.city || '',
                customerData.district || '',
                customerData.village || '',
                customerData.neighborhood || '',
                customerData.streetType || '',
                customerData.streetName || '',
                customerData.lane || '',
                customerData.alley || '',
                customerData.number || '',
                customerData.floor || '',
                customerData.fullAddress || '',
                customerData.healthStatus || '',
                customerData.medications || '',
                customerData.supplements || '',
                customerData.avatar || '',
                data[i][18] || new Date().toISOString() // 保持原建立時間
            ];
            
            // 更新該行資料
            sheet.getRange(i + 1, 1, 1, 19).setValues([row]);
            
            return {
                id: id,
                ...customerData
            };
        }
    }
    
    throw new Error('找不到指定的客戶');
}

/**
 * 刪除客戶
 */
function deleteCustomer(id) {
    const sheet = getSheet();
    const data = sheet.getDataRange().getValues();
    
    for (let i = 1; i < data.length; i++) {
        if (data[i][0] === id) {
            sheet.deleteRow(i + 1); // +1 因為陣列從 0 開始，但試算表從 1 開始
            return { success: true };
        }
    }
    
    throw new Error('找不到指定的客戶');
}

/**
 * 取得行程工作表
 */
function getScheduleSheet() {
    const spreadsheet = SpreadsheetApp.openById(SPREADSHEET_ID);
    let sheet = spreadsheet.getSheetByName('行事曆');
    
    if (!sheet) {
        sheet = spreadsheet.insertSheet('行事曆');
        sheet.getRange(1, 1, 1, 8).setValues([[
            'ID', '標題', '日期', '開始時間', '結束時間', '類型', '客戶ID', '備註'
        ]]);
        sheet.getRange(1, 1, 1, 8).setFontWeight('bold');
    }
    
    return sheet;
}

/**
 * 取得所有行程
 */
function getAllSchedules() {
    const sheet = getScheduleSheet();
    const data = sheet.getDataRange().getValues();
    const customers = getAllCustomers();
    const customerMap = {};
    customers.forEach(c => { customerMap[c.id] = c.name; });
    
    const schedules = [];
    for (let i = 1; i < data.length; i++) {
        if (data[i][0]) {
            const customerId = data[i][6] || '';
            schedules.push({
                id: data[i][0],
                title: data[i][1] || '',
                date: data[i][2] || '',
                startTime: data[i][3] || '',
                endTime: data[i][4] || '',
                type: data[i][5] || 'other',
                customerId: customerId,
                customerName: customerMap[customerId] || '',
                notes: data[i][7] || ''
            });
        }
    }
    
    return schedules;
}

/**
 * 新增行程
 */
function addSchedule(scheduleData) {
    const sheet = getScheduleSheet();
    const id = Date.now().toString();
    
    const row = [
        id,
        scheduleData.title || '',
        scheduleData.date || '',
        scheduleData.startTime || '',
        scheduleData.endTime || '',
        scheduleData.type || 'other',
        scheduleData.customerId || '',
        scheduleData.notes || ''
    ];
    
    sheet.appendRow(row);
    
    return {
        id: id,
        ...scheduleData
    };
}

/**
 * 刪除行程
 */
function deleteSchedule(id) {
    const sheet = getScheduleSheet();
    const data = sheet.getDataRange().getValues();
    
    for (let i = 1; i < data.length; i++) {
        if (data[i][0] === id) {
            sheet.deleteRow(i + 1);
            return { success: true };
        }
    }
    
    throw new Error('找不到指定的行程');
}

/**
 * 取得訂單工作表
 */
function getOrderSheet() {
    const spreadsheet = SpreadsheetApp.openById(SPREADSHEET_ID);
    let sheet = spreadsheet.getSheetByName('訂貨清單');
    
    if (!sheet) {
        sheet = spreadsheet.insertSheet('訂貨清單');
        sheet.getRange(1, 1, 1, 8).setValues([[
            'ID', '日期', '客戶ID', '保健食品', '數量', '金額', '已收款', '備註'
        ]]);
        sheet.getRange(1, 1, 1, 8).setFontWeight('bold');
    }
    
    return sheet;
}

/**
 * 取得所有訂單
 */
function getAllOrders() {
    const sheet = getOrderSheet();
    const data = sheet.getDataRange().getValues();
    const customers = getAllCustomers();
    const customerMap = {};
    customers.forEach(c => { customerMap[c.id] = c.name; });
    
    const orders = [];
    for (let i = 1; i < data.length; i++) {
        if (data[i][0]) {
            const customerId = data[i][2] || '';
            orders.push({
                id: data[i][0],
                date: data[i][1] || '',
                customerId: customerId,
                customerName: customerMap[customerId] || '',
                product: data[i][3] || '',
                quantity: data[i][4] || 1,
                amount: data[i][5] || 0,
                paid: data[i][6] === true || data[i][6] === 'true',
                notes: data[i][7] || ''
            });
        }
    }
    
    return orders;
}

/**
 * 新增訂單
 */
function addOrder(orderData) {
    const sheet = getOrderSheet();
    const id = Date.now().toString();
    
    const row = [
        id,
        orderData.date || '',
        orderData.customerId || '',
        orderData.product || '',
        orderData.quantity || 1,
        orderData.amount || 0,
        orderData.paid === true || orderData.paid === 'true',
        orderData.notes || ''
    ];
    
    sheet.appendRow(row);
    
    return {
        id: id,
        ...orderData
    };
}

/**
 * 更新訂單
 */
function updateOrder(id, orderData) {
    const sheet = getOrderSheet();
    const data = sheet.getDataRange().getValues();
    
    for (let i = 1; i < data.length; i++) {
        if (data[i][0] === id) {
            sheet.getRange(i + 1, 2, 1, 7).setValues([[
                orderData.date || '',
                orderData.customerId || '',
                orderData.product || '',
                orderData.quantity || 1,
                orderData.amount || 0,
                orderData.paid === true || orderData.paid === 'true',
                orderData.notes || ''
            ]]);
            return { success: true };
        }
    }
    
    throw new Error('找不到指定的訂單');
}

/**
 * 刪除訂單
 */
function deleteOrder(id) {
    const sheet = getOrderSheet();
    const data = sheet.getDataRange().getValues();
    
    for (let i = 1; i < data.length; i++) {
        if (data[i][0] === id) {
            sheet.deleteRow(i + 1);
            return { success: true };
        }
    }
    
    throw new Error('找不到指定的訂單');
}

/**
 * 建立回應（包含 CORS 標頭）
 */
function createResponse(success, data, error) {
    const response = {
        success: success,
        data: data
    };
    
    if (error) {
        response.error = error;
    }
    
    // 使用 HtmlService 來設置 CORS 標頭
    // 注意：這需要在部署時設定正確的權限
    return ContentService
        .createTextOutput(JSON.stringify(response))
        .setMimeType(ContentService.MimeType.JSON);
}



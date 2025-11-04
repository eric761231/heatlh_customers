// 訂貨清單相關功能
let orders = [];
let editingOrderId = null;
let savingOrder = false; // 防止重複提交

// 初始化訂貨清單
async function initOrders() {
    checkAuth();
    setTodayDateForOrder();
    // 並行載入資料，提升速度
    await Promise.all([
        loadOrders(),
        loadCustomersForOrder()
    ]);
}

// 設定今天日期
function setTodayDateForOrder() {
    const today = new Date().toISOString().split('T')[0];
    document.getElementById('orderDate').value = today;
}

// 載入訂單列表
async function loadOrders() {
    const tbody = document.getElementById('ordersTableBody');
    tbody.innerHTML = '<tr><td colspan="7" class="loading">載入中...</td></tr>';
    
    try {
        orders = await getOrders();
        displayOrders(orders);
    } catch (error) {
        tbody.innerHTML = `<tr><td colspan="7" class="error-message">載入失敗：${error.message}</td></tr>`;
    }
}

// 顯示訂單列表
function displayOrders(ordersList) {
    const tbody = document.getElementById('ordersTableBody');
    
    if (ordersList.length === 0) {
        tbody.innerHTML = '<tr><td colspan="7" class="empty-message">尚無訂單</td></tr>';
        return;
    }
    
    tbody.innerHTML = ordersList.map(order => {
        // 確保 ID 是字符串
        const orderId = String(order.id);
        const date = new Date(order.date).toLocaleDateString('zh-TW');
        const paidStatus = order.paid === true || order.paid === 'true' 
            ? '<span class="badge badge-success">已收款</span>' 
            : '<span class="badge badge-warning">未收款</span>';
        
        return `
            <tr>
                <td>${date}</td>
                <td>${order.customerName || '未指定'}</td>
                <td>${order.product}</td>
                <td>${order.quantity || 1}</td>
                <td>$${order.amount || 0}</td>
                <td>${paidStatus}</td>
                <td>
                    <button class="btn btn-sm btn-primary" onclick="editOrder('${orderId}')">編輯</button>
                    <button class="btn btn-sm btn-danger" onclick="deleteOrder('${orderId}')">刪除</button>
                </td>
            </tr>
        `;
    }).join('');
}

// 載入客戶列表供訂單選擇
async function loadCustomersForOrder() {
    try {
        const customers = await getCustomers();
        const select = document.getElementById('orderCustomer');
        
        select.innerHTML = '<option value="">請選擇客戶</option>';
        customers.forEach(customer => {
            const option = document.createElement('option');
            option.value = customer.id;
            option.textContent = customer.name || '未命名';
            select.appendChild(option);
        });
    } catch (error) {
        console.error('載入客戶列表失敗:', error);
    }
}

// 顯示新增訂單 Modal
function showAddOrderModal() {
    editingOrderId = null;
    document.getElementById('orderModalTitle').textContent = '新增訂單';
    document.getElementById('orderForm').reset();
    setTodayDateForOrder();
    document.getElementById('orderModal').style.display = 'block';
}

// 關閉訂單 Modal
function closeOrderModal() {
    document.getElementById('orderModal').style.display = 'none';
    document.getElementById('orderForm').reset();
    editingOrderId = null;
}

// 編輯訂單
async function editOrder(orderId) {
    // 確保 ID 是字符串類型用於比較
    const searchId = String(orderId);
    const order = orders.find(o => String(o.id) === searchId);
    
    if (!order) {
        console.error('找不到訂單:', orderId);
        alert('找不到指定的訂單');
        return;
    }
    
    editingOrderId = searchId;
    document.getElementById('orderModalTitle').textContent = '編輯訂單';
    
    // 處理日期格式：將日期轉換為 YYYY-MM-DD 格式
    let dateValue = order.date;
    if (dateValue) {
        // 如果是 Date 對象或日期字符串，轉換為 YYYY-MM-DD
        const date = new Date(dateValue);
        if (!isNaN(date.getTime())) {
            dateValue = date.toISOString().split('T')[0];
        } else if (typeof dateValue === 'string' && dateValue.includes('/')) {
            // 處理類似 "2024/1/15" 的格式
            const parts = dateValue.split('/');
            if (parts.length === 3) {
                const year = parts[0];
                const month = parts[1].padStart(2, '0');
                const day = parts[2].padStart(2, '0');
                dateValue = `${year}-${month}-${day}`;
            }
        }
    }
    
    document.getElementById('orderDate').value = dateValue || '';
    document.getElementById('orderCustomer').value = String(order.customerId || '');
    document.getElementById('orderProduct').value = order.product || '';
    document.getElementById('orderQuantity').value = order.quantity || 1;
    document.getElementById('orderAmount').value = order.amount || 0;
    document.getElementById('orderPaid').value = order.paid === true || order.paid === 'true' ? 'true' : 'false';
    document.getElementById('orderNotes').value = order.notes || '';
    
    document.getElementById('orderModal').style.display = 'block';
}

// 處理訂單提交
async function handleOrderSubmit(event) {
    event.preventDefault();
    
    // 防止重複提交
    if (savingOrder) {
        console.log('正在儲存中，請勿重複點擊');
        return;
    }
    
    const date = document.getElementById('orderDate').value;
    const customerId = document.getElementById('orderCustomer').value;
    const product = document.getElementById('orderProduct').value.trim();
    const quantity = parseInt(document.getElementById('orderQuantity').value) || 1;
    const amount = parseFloat(document.getElementById('orderAmount').value) || 0;
    const paid = document.getElementById('orderPaid').value === 'true';
    const notes = document.getElementById('orderNotes').value.trim();
    
    if (!date || !customerId || !product) {
        alert('請填寫必填欄位（日期、訂購者、保健食品）');
        return;
    }
    
    savingOrder = true;
    const submitBtn = event.target.querySelector('button[type="submit"]');
    const originalText = submitBtn ? submitBtn.textContent : '';
    
    try {
        if (submitBtn) {
            submitBtn.disabled = true;
            submitBtn.textContent = '儲存中...';
        }
        
        const orderData = {
            date: date,
            customerId: customerId,
            product: product,
            quantity: quantity,
            amount: amount,
            paid: paid,
            notes: notes || ''
        };
        
        if (editingOrderId) {
            await updateOrder(editingOrderId, orderData);
            alert('訂單已更新！');
        } else {
            await addOrder(orderData);
            alert('訂單已新增！');
        }
        
        closeOrderModal();
        await loadOrders();
    } catch (error) {
        alert('操作失敗：' + error.message);
        console.error('Order submit error:', error);
    } finally {
        savingOrder = false;
        if (submitBtn) {
            submitBtn.disabled = false;
            submitBtn.textContent = originalText;
        }
    }
}

// 刪除訂單
async function deleteOrder(orderId) {
    if (!confirm('確定要刪除這個訂單嗎？')) {
        return;
    }
    
    try {
        // 確保 ID 是字符串
        await deleteOrderById(String(orderId));
        await loadOrders();
        alert('訂單已刪除');
    } catch (error) {
        alert('刪除訂單失敗：' + error.message);
    }
}

// 點擊 Modal 外部關閉
window.onclick = function(event) {
    const orderModal = document.getElementById('orderModal');
    if (event.target === orderModal) {
        closeOrderModal();
    }
}

// 頁面載入時初始化
window.addEventListener('DOMContentLoaded', initOrders);


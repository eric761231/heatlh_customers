// 訂貨清單相關功能
let orders = [];
let editingOrderId = null;

// 初始化訂貨清單
async function initOrders() {
    checkAuth();
    await loadOrders();
    await loadCustomersForOrder();
    setTodayDateForOrder();
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
                    <button class="btn btn-sm btn-primary" onclick="editOrder('${order.id}')">編輯</button>
                    <button class="btn btn-sm btn-danger" onclick="deleteOrder('${order.id}')">刪除</button>
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
    const order = orders.find(o => o.id === orderId);
    if (!order) return;
    
    editingOrderId = orderId;
    document.getElementById('orderModalTitle').textContent = '編輯訂單';
    
    document.getElementById('orderDate').value = order.date;
    document.getElementById('orderCustomer').value = order.customerId || '';
    document.getElementById('orderProduct').value = order.product;
    document.getElementById('orderQuantity').value = order.quantity || 1;
    document.getElementById('orderAmount').value = order.amount || 0;
    document.getElementById('orderPaid').value = order.paid === true || order.paid === 'true' ? 'true' : 'false';
    document.getElementById('orderNotes').value = order.notes || '';
    
    document.getElementById('orderModal').style.display = 'block';
}

// 處理訂單提交
async function handleOrderSubmit(event) {
    event.preventDefault();
    
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
    
    try {
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
    }
}

// 刪除訂單
async function deleteOrder(orderId) {
    if (!confirm('確定要刪除這個訂單嗎？')) {
        return;
    }
    
    try {
        await deleteOrderById(orderId);
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


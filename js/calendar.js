// 行事曆相關功能
let currentDate = new Date();
let schedules = [];

// 初始化行事曆
function initCalendar() {
    checkAuth();
    updateCalendar();
    loadSchedules();
    loadCustomersForSchedule();
    setTodayDate();
}

// 設定今天日期
function setTodayDate() {
    const today = new Date().toISOString().split('T')[0];
    document.getElementById('scheduleDate').value = today;
}

// 更新行事曆顯示
function updateCalendar() {
    const year = currentDate.getFullYear();
    const month = currentDate.getMonth();
    
    // 更新月份顯示
    const monthNames = ['一月', '二月', '三月', '四月', '五月', '六月', 
                       '七月', '八月', '九月', '十月', '十一月', '十二月'];
    document.getElementById('currentMonthYear').textContent = 
        `${year}年 ${monthNames[month]}`;
    
    // 生成行事曆
    generateCalendarGrid(year, month);
}

// 生成行事曆網格
function generateCalendarGrid(year, month) {
    const grid = document.getElementById('calendarGrid');
    const firstDay = new Date(year, month, 1).getDay();
    const daysInMonth = new Date(year, month + 1, 0).getDate();
    const today = new Date();
    
    // 星期標題
    const weekDays = ['日', '一', '二', '三', '四', '五', '六'];
    let html = '<div class="calendar-weekdays">';
    weekDays.forEach(day => {
        html += `<div class="calendar-weekday">${day}</div>`;
    });
    html += '</div>';
    
    // 日期格子
    html += '<div class="calendar-days">';
    
    // 填充空白（月初）
    for (let i = 0; i < firstDay; i++) {
        html += '<div class="calendar-day empty"></div>';
    }
    
    // 填充日期
    for (let day = 1; day <= daysInMonth; day++) {
        const date = new Date(year, month, day);
        const dateStr = date.toISOString().split('T')[0];
        const isToday = date.toDateString() === today.toDateString();
        const daySchedules = schedules.filter(s => s.date === dateStr);
        
        html += `<div class="calendar-day ${isToday ? 'today' : ''}" onclick="showDaySchedules('${dateStr}')">`;
        html += `<div class="calendar-day-number">${day}</div>`;
        if (daySchedules.length > 0) {
            html += `<div class="calendar-day-schedules">${daySchedules.length} 個行程</div>`;
        }
        html += '</div>';
    }
    
    html += '</div>';
    grid.innerHTML = html;
}

// 切換月份
function changeMonth(direction) {
    currentDate.setMonth(currentDate.getMonth() + direction);
    updateCalendar();
    loadSchedules();
}

// 回到今天
function goToToday() {
    currentDate = new Date();
    updateCalendar();
    loadSchedules();
}

// 載入行程
async function loadSchedules() {
    try {
        schedules = await getSchedules();
        updateCalendar();
    } catch (error) {
        console.error('載入行程失敗:', error);
    }
}

// 顯示某天的行程
function showDaySchedules(dateStr) {
    const daySchedules = schedules.filter(s => s.date === dateStr);
    const date = new Date(dateStr);
    const dateFormatted = date.toLocaleDateString('zh-TW', { 
        year: 'numeric', 
        month: 'long', 
        day: 'numeric',
        weekday: 'long'
    });
    
    let content = `<h3>${dateFormatted}</h3>`;
    
    if (daySchedules.length === 0) {
        content += '<p class="no-data">當天無行程</p>';
        content += `<button class="btn btn-primary" onclick="addScheduleForDate('${dateStr}')">新增行程</button>`;
    } else {
        content += '<div class="schedule-list">';
        daySchedules.forEach(schedule => {
            const typeLabels = {
                'customer': '見客戶',
                'partner': '見夥伴',
                'other': '其他'
            };
            const typeLabel = typeLabels[schedule.type] || schedule.type;
            
            content += `
                <div class="schedule-item" onclick="showScheduleDetail('${schedule.id}')">
                    <div class="schedule-item-header">
                        <h4>${schedule.title}</h4>
                        <span class="schedule-type-badge">${typeLabel}</span>
                    </div>
                    ${schedule.startTime ? `<p>時間：${schedule.startTime}${schedule.endTime ? ' - ' + schedule.endTime : ''}</p>` : ''}
                    ${schedule.customerName ? `<p>客戶：${schedule.customerName}</p>` : ''}
                    ${schedule.notes ? `<p>${schedule.notes}</p>` : ''}
                </div>
            `;
        });
        content += '</div>';
        content += `<button class="btn btn-primary" onclick="addScheduleForDate('${dateStr}')">新增行程</button>`;
    }
    
    document.getElementById('scheduleDetailContent').innerHTML = content;
    document.getElementById('scheduleDetailModal').style.display = 'block';
}

// 為指定日期新增行程
function addScheduleForDate(dateStr) {
    document.getElementById('scheduleDate').value = dateStr;
    closeScheduleDetailModal();
    showAddScheduleModal();
}

// 顯示行程詳情
function showScheduleDetail(scheduleId) {
    const schedule = schedules.find(s => s.id === scheduleId);
    if (!schedule) return;
    
    const typeLabels = {
        'customer': '見客戶',
        'partner': '見夥伴',
        'other': '其他'
    };
    
    let content = `
        <div class="schedule-detail">
            <h3>${schedule.title}</h3>
            <div class="detail-row">
                <strong>日期：</strong>${new Date(schedule.date).toLocaleDateString('zh-TW')}
            </div>
            ${schedule.startTime ? `
            <div class="detail-row">
                <strong>時間：</strong>${schedule.startTime}${schedule.endTime ? ' - ' + schedule.endTime : ''}
            </div>
            ` : ''}
            <div class="detail-row">
                <strong>類型：</strong>${typeLabels[schedule.type] || schedule.type}
            </div>
            ${schedule.customerName ? `
            <div class="detail-row">
                <strong>客戶：</strong>${schedule.customerName}
            </div>
            ` : ''}
            ${schedule.notes ? `
            <div class="detail-row">
                <strong>備註：</strong>${schedule.notes}
            </div>
            ` : ''}
            <div class="detail-actions">
                <button class="btn btn-danger" onclick="deleteSchedule('${schedule.id}')">刪除</button>
                <button class="btn btn-secondary" onclick="closeScheduleDetailModal()">關閉</button>
            </div>
        </div>
    `;
    
    document.getElementById('scheduleDetailContent').innerHTML = content;
}

// 顯示新增行程 Modal
function showAddScheduleModal() {
    document.getElementById('scheduleModal').style.display = 'block';
    setTodayDate();
}

// 關閉新增行程 Modal
function closeScheduleModal() {
    document.getElementById('scheduleModal').style.display = 'none';
    document.getElementById('scheduleForm').reset();
}

// 關閉行程詳情 Modal
function closeScheduleDetailModal() {
    document.getElementById('scheduleDetailModal').style.display = 'none';
}

// 載入客戶列表供行程選擇
async function loadCustomersForSchedule() {
    try {
        const customers = await getCustomers();
        const select = document.getElementById('scheduleCustomer');
        
        select.innerHTML = '<option value="">請選擇客戶（選填）</option>';
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

// 處理行程提交
async function handleScheduleSubmit(event) {
    event.preventDefault();
    
    const title = document.getElementById('scheduleTitle').value.trim();
    const date = document.getElementById('scheduleDate').value;
    const startTime = document.getElementById('scheduleStartTime').value;
    const endTime = document.getElementById('scheduleEndTime').value;
    const type = document.getElementById('scheduleType').value;
    const customerId = document.getElementById('scheduleCustomer').value;
    const notes = document.getElementById('scheduleNotes').value.trim();
    
    if (!title || !date) {
        alert('請填寫標題和日期');
        return;
    }
    
    try {
        const scheduleData = {
            title: title,
            date: date,
            startTime: startTime || '',
            endTime: endTime || '',
            type: type,
            customerId: customerId || '',
            notes: notes || ''
        };
        
        await addSchedule(scheduleData);
        closeScheduleModal();
        await loadSchedules();
        alert('行程已新增！');
    } catch (error) {
        alert('新增行程失敗：' + error.message);
    }
}

// 刪除行程
async function deleteSchedule(scheduleId) {
    if (!confirm('確定要刪除這個行程嗎？')) {
        return;
    }
    
    try {
        await deleteScheduleById(scheduleId);
        closeScheduleDetailModal();
        await loadSchedules();
        alert('行程已刪除');
    } catch (error) {
        alert('刪除行程失敗：' + error.message);
    }
}

// 點擊 Modal 外部關閉
window.onclick = function(event) {
    const scheduleModal = document.getElementById('scheduleModal');
    const scheduleDetailModal = document.getElementById('scheduleDetailModal');
    
    if (event.target === scheduleModal) {
        closeScheduleModal();
    }
    if (event.target === scheduleDetailModal) {
        closeScheduleDetailModal();
    }
}

// 頁面載入時初始化
window.addEventListener('DOMContentLoaded', initCalendar);


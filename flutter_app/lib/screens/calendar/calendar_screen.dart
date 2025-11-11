import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/schedule_model.dart';
import '../../services/supabase_service.dart';
import 'add_schedule_screen.dart'; // 導入新增行程頁面

/// 行事曆頁面 - 顯示和管理行程事項
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  
  // 行事曆相關狀態
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  
  // 資料狀態
  List<ScheduleModel> _schedules = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  /// 載入所有行程資料
  Future<void> _loadSchedules() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final schedules = await _supabaseService.getAllSchedules();
      setState(() {
        _schedules = schedules;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorMessage('載入行程失敗: $e');
    }
  }

  /// 顯示錯誤訊息
  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  /// 取得指定日期的所有行程
  List<ScheduleModel> _getSchedulesForDay(DateTime day) {
    return _schedules.where((schedule) {
      return schedule.date.year == day.year &&
          schedule.date.month == day.month &&
          schedule.date.day == day.day;
    }).toList();
  }

  /// 處理日期選擇
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
  }

  /// 處理行事曆格式變更
  void _onFormatChanged(CalendarFormat format) {
    setState(() {
      _calendarFormat = format;
    });
  }

  /// 處理頁面切換
  void _onPageChanged(DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
    });
  }

  /// 處理刪除行程
  Future<void> _handleDeleteSchedule(ScheduleModel schedule) async {
    final confirmed = await _showDeleteConfirmDialog();
    
    if (confirmed != true) {
      return;
    }

    try {
      await _supabaseService.deleteSchedule(schedule.id);
      _loadSchedules();
    } catch (e) {
      _showErrorMessage('刪除失敗: $e');
    }
  }

  /// 顯示刪除確認對話框
  Future<bool?> _showDeleteConfirmDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認刪除'),
        content: const Text('確定要刪除此行程嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('刪除'),
          ),
        ],
      ),
    );
  }

  /// 建立行程卡片
  Widget _buildScheduleCard(ScheduleModel schedule) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(schedule.title),
        subtitle: _buildScheduleSubtitle(schedule),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => _handleDeleteSchedule(schedule),
        ),
      ),
    );
  }

  /// 建立行程副標題內容
  Widget _buildScheduleSubtitle(ScheduleModel schedule) {
    final children = <Widget>[];

    // 時間資訊
    if (schedule.startTime != null || schedule.endTime != null) {
      children.add(Text('${schedule.startTime ?? ''} - ${schedule.endTime ?? ''}'));
    }

    // 客戶名稱
    if (schedule.customerName != null) {
      children.add(Text('客戶: ${schedule.customerName}'));
    }

    // 備註
    if (schedule.notes != null && schedule.notes!.isNotEmpty) {
      children.add(Text(schedule.notes!));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  /// 建立行程列表
  Widget _buildScheduleList() {
    final daySchedules = _getSchedulesForDay(_selectedDay);

    if (daySchedules.isEmpty) {
      return const Center(
        child: Text('這一天沒有行程'),
      );
    }

    return ListView.builder(
      itemCount: daySchedules.length,
      itemBuilder: (context, index) {
        return _buildScheduleCard(daySchedules[index]);
      },
    );
  }

  /// 建立行事曆 Widget
  Widget _buildCalendar() {
    return TableCalendar<ScheduleModel>(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      calendarFormat: _calendarFormat,
      eventLoader: _getSchedulesForDay,
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarStyle: const CalendarStyle(
        outsideDaysVisible: false,
      ),
      headerStyle: const HeaderStyle(
        formatButtonVisible: true,
        titleCentered: true,
      ),
      onDaySelected: _onDaySelected,
      onFormatChanged: _onFormatChanged,
      onPageChanged: _onPageChanged,
    );
  }

  /// 建立主要內容區域
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        _buildCalendar(),
        Expanded(
          child: _buildScheduleList(),
        ),
      ],
    );
  }

  /// 處理新增行程按鈕點擊
  /// 導航到新增行程頁面，使用當前選中的日期作為初始日期
  Future<void> _handleAddSchedule() async {
    // 導航到新增行程頁面，傳入當前選中的日期
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddScheduleScreen(initialDate: _selectedDay),
      ),
    );
    
    // 如果新增成功（返回 true），重新載入行程列表
    if (result == true) {
      _loadSchedules();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _handleAddSchedule,
        child: const Icon(Icons.add),
      ),
    );
  }
}

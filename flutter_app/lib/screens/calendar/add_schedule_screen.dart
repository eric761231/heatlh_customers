import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/app_colors.dart';
import '../../models/customer_model.dart';
import '../../models/schedule_model.dart';
import '../../services/supabase_service.dart';

/**
 * 新增行程頁面
 * 
 * Java 對比：
 * - StatefulWidget 類似 Java 的有狀態組件
 * - TimeOfDay 類似 Java 的 LocalTime
 */
class AddScheduleScreen extends StatefulWidget {
  final DateTime? initialDate; // 可選的初始日期（從行事曆選擇的日期）

  const AddScheduleScreen({super.key, this.initialDate});

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  // 表單驗證鍵
  final _formKey = GlobalKey<FormState>();
  
  // Supabase 服務
  final SupabaseService _supabaseService = SupabaseService();
  
  // 輸入控制器
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  
  // 狀態變數
  // late 關鍵字表示此變數稍後會在 initState() 中初始化
  // 類似 Java 的延遲初始化（在構造函數或初始化塊中賦值）
  late DateTime _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String _selectedType = 'other';
  String? _selectedCustomerId;
  bool _isLoading = false;
  List<CustomerModel> _customers = [];

  // 行程類型選項
  final List<Map<String, String>> _scheduleTypes = [
    {'value': 'customer', 'label': '見客戶'},
    {'value': 'partner', 'label': '見夥伴'},
    {'value': 'other', 'label': '其他'},
  ];

  @override
  void initState() {
    super.initState();
    // 使用初始日期或當前日期
    // 類似 Java 的構造函數初始化：this.selectedDate = initialDate != null ? initialDate : new Date();
    _selectedDate = widget.initialDate ?? DateTime.now();
    _loadCustomers();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// 載入客戶列表
  Future<void> _loadCustomers() async {
    try {
      final customers = await _supabaseService.getAllCustomers();
      setState(() {
        _customers = customers;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('載入客戶列表失敗: $e')),
        );
      }
    }
  }

  /// 選擇日期
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// 選擇開始時間
  Future<void> _selectStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  /// 選擇結束時間
  Future<void> _selectEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  /// 處理表單提交
  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _supabaseService.getCurrentUser();
      if (user == null) {
        throw Exception('未登入，無法新增行程');
      }

      // 格式化時間（HH:mm 格式）
      String? startTimeStr;
      String? endTimeStr;
      
      if (_startTime != null) {
        startTimeStr = '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}';
      }
      if (_endTime != null) {
        endTimeStr = '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}';
      }

      // 建立行程模型
      final schedule = ScheduleModel(
        id: '', // 將由後端生成
        title: _titleController.text.trim(),
        date: _selectedDate,
        startTime: startTimeStr,
        endTime: endTimeStr,
        type: _selectedType,
        customerId: _selectedCustomerId,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        userLogin: user.userLogin,
      );

      // 新增行程
      await _supabaseService.addSchedule(schedule);

      // 顯示成功訊息
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('行程已成功新增！'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('新增失敗: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 建立標題輸入欄位
  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: const InputDecoration(
        labelText: '標題 *',
        hintText: '例如：見客戶 - 張三',
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '請輸入標題';
        }
        return null;
      },
    );
  }

  /// 建立日期選擇欄位
  Widget _buildDateField() {
    return InkWell(
      onTap: _selectDate,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: '日期 *',
          suffixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(
          DateFormat('yyyy-MM-dd').format(_selectedDate),
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  /// 建立時間選擇欄位
  Widget _buildTimeFields() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: _selectStartTime,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: '開始時間',
                suffixIcon: Icon(Icons.access_time),
              ),
              child: Text(
                _startTime != null
                    ? '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}'
                    : '選擇時間',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: InkWell(
            onTap: _selectEndTime,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: '結束時間',
                suffixIcon: Icon(Icons.access_time),
              ),
              child: Text(
                _endTime != null
                    ? '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}'
                    : '選擇時間',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 建立類型選擇下拉選單
  Widget _buildTypeField() {
    return DropdownButtonFormField<String>(
      value: _selectedType,
      decoration: const InputDecoration(
        labelText: '類型',
      ),
      items: _scheduleTypes.map((type) {
        return DropdownMenuItem<String>(
          value: type['value'],
          child: Text(type['label']!),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedType = value ?? 'other';
        });
      },
    );
  }

  /// 建立客戶選擇下拉選單
  Widget _buildCustomerField() {
    return DropdownButtonFormField<String>(
      value: _selectedCustomerId,
      decoration: const InputDecoration(
        labelText: '相關客戶',
      ),
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('請選擇客戶（選填）'),
        ),
        ..._customers.map((customer) {
          return DropdownMenuItem<String>(
            value: customer.id,
            child: Text(customer.name),
          );
        }),
      ],
      onChanged: (value) {
        setState(() {
          _selectedCustomerId = value;
        });
      },
    );
  }

  /// 建立備註欄位
  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      maxLines: 4,
      decoration: const InputDecoration(
        labelText: '備註',
        hintText: '行程備註...',
      ),
    );
  }

  /// 建立提交按鈕
  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowButton,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _handleSubmit,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            alignment: Alignment.center,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.textWhite),
                    ),
                  )
                : const Text(
                    '儲存',
                    style: TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新增行程'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '新增行程',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              
              _buildTitleField(),
              const SizedBox(height: 16),
              _buildDateField(),
              const SizedBox(height: 16),
              _buildTimeFields(),
              const SizedBox(height: 16),
              _buildTypeField(),
              const SizedBox(height: 16),
              _buildCustomerField(),
              const SizedBox(height: 16),
              _buildNotesField(),
              const SizedBox(height: 32),
              
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }
}


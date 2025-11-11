import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/app_colors.dart';
import '../../models/customer_model.dart';
import '../../models/order_model.dart';
import '../../services/supabase_service.dart';

/**
 * 新增訂單頁面
 * 
 * Java 對比：
 * - StatefulWidget 類似 Java 的有狀態組件
 * - DropdownButton 類似 Java 的 JComboBox
 */
class AddOrderScreen extends StatefulWidget {
  const AddOrderScreen({super.key});

  @override
  State<AddOrderScreen> createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends State<AddOrderScreen> {
  // 表單驗證鍵
  final _formKey = GlobalKey<FormState>();
  
  // Supabase 服務
  final SupabaseService _supabaseService = SupabaseService();
  
  // 輸入控制器
  final _productController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _amountController = TextEditingController(text: '0.0');
  final _notesController = TextEditingController();
  
  // 狀態變數
  DateTime _selectedDate = DateTime.now();
  String? _selectedCustomerId;
  bool _isPaid = false;
  bool _isLoading = false;
  List<CustomerModel> _customers = [];

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  @override
  void dispose() {
    _productController.dispose();
    _quantityController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// 載入客戶列表（用於下拉選單）
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
        throw Exception('未登入，無法新增訂單');
      }

      // 建立訂單模型
      final order = OrderModel(
        id: '', // 將由後端生成
        date: _selectedDate,
        customerId: _selectedCustomerId,
        product: _productController.text.trim(),
        quantity: int.tryParse(_quantityController.text) ?? 1,
        amount: double.tryParse(_amountController.text) ?? 0.0,
        paid: _isPaid,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        userLogin: user.userLogin,
      );

      // 新增訂單
      await _supabaseService.addOrder(order);

      // 顯示成功訊息
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('訂單已成功新增！'),
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

  /// 建立日期選擇欄位
  Widget _buildDateField() {
    return InkWell(
      onTap: _selectDate,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: '訂單日期 *',
          suffixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(
          DateFormat('yyyy-MM-dd').format(_selectedDate),
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  /// 建立客戶選擇下拉選單
  Widget _buildCustomerField() {
    return DropdownButtonFormField<String>(
      value: _selectedCustomerId,
      decoration: const InputDecoration(
        labelText: '訂購者 *',
      ),
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('請選擇客戶'),
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
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '請選擇客戶';
        }
        return null;
      },
    );
  }

  /// 建立產品輸入欄位
  Widget _buildProductField() {
    return TextFormField(
      controller: _productController,
      decoration: const InputDecoration(
        labelText: '保健食品 *',
        hintText: '例如：維他命C、魚油等',
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '請輸入保健食品名稱';
        }
        return null;
      },
    );
  }

  /// 建立數量和金額欄位
  Widget _buildQuantityAndAmountFields() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _quantityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '數量',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '請輸入數量';
              }
              final quantity = int.tryParse(value);
              if (quantity == null || quantity < 1) {
                return '數量必須大於 0';
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: '金額',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '請輸入金額';
              }
              final amount = double.tryParse(value);
              if (amount == null || amount < 0) {
                return '金額必須大於或等於 0';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  /// 建立付款狀態選擇
  Widget _buildPaidField() {
    return DropdownButtonFormField<bool>(
      value: _isPaid,
      decoration: const InputDecoration(
        labelText: '收款狀態',
      ),
      items: const [
        DropdownMenuItem<bool>(
          value: false,
          child: Text('未收款'),
        ),
        DropdownMenuItem<bool>(
          value: true,
          child: Text('已收款'),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _isPaid = value ?? false;
        });
      },
    );
  }

  /// 建立備註欄位
  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      maxLines: 3,
      decoration: const InputDecoration(
        labelText: '備註',
        hintText: '訂單備註...',
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
        title: const Text('新增訂單'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '新增訂單',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              
              _buildDateField(),
              const SizedBox(height: 16),
              _buildCustomerField(),
              const SizedBox(height: 16),
              _buildProductField(),
              const SizedBox(height: 16),
              _buildQuantityAndAmountFields(),
              const SizedBox(height: 16),
              _buildPaidField(),
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


import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../models/customer_model.dart';
import '../../services/supabase_service.dart';

/**
 * 新增客戶頁面
 * 
 * Java 對比：
 * - StatefulWidget 類似 Java 的有狀態組件
 * - TextEditingController 類似 Java 的 JTextField 或 Input 元素
 * - GlobalKey<FormState> 類似 Java 的表單驗證器
 */
class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  // 表單驗證鍵
  final _formKey = GlobalKey<FormState>();
  
  // Supabase 服務
  final SupabaseService _supabaseService = SupabaseService();
  
  // 輸入控制器
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _villageController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _streetTypeController = TextEditingController();
  final _streetNameController = TextEditingController();
  final _laneController = TextEditingController();
  final _alleyController = TextEditingController();
  final _numberController = TextEditingController();
  final _floorController = TextEditingController();
  final _fullAddressController = TextEditingController();
  final _healthStatusController = TextEditingController();
  final _medicationsController = TextEditingController();
  final _supplementsController = TextEditingController();
  
  // 狀態變數
  bool _isLoading = false;

  @override
  void dispose() {
    // 釋放資源（類似 Java 的 close() 或 dispose()）
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _villageController.dispose();
    _neighborhoodController.dispose();
    _streetTypeController.dispose();
    _streetNameController.dispose();
    _laneController.dispose();
    _alleyController.dispose();
    _numberController.dispose();
    _floorController.dispose();
    _fullAddressController.dispose();
    _healthStatusController.dispose();
    _medicationsController.dispose();
    _supplementsController.dispose();
    super.dispose();
  }

  /// 處理表單提交
  /// 類似 Java 的 onSubmit() 或 handleSubmit() 方法
  Future<void> _handleSubmit() async {
    // 驗證表單
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 取得當前使用者（用於 user_login）
      final user = await _supabaseService.getCurrentUser();
      if (user == null) {
        throw Exception('未登入，無法新增客戶');
      }

      // 建立客戶模型（類似 Java 的 new CustomerModel(...)）
      final customer = CustomerModel(
        id: '', // 將由後端生成
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        city: _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
        district: _districtController.text.trim().isEmpty ? null : _districtController.text.trim(),
        village: _villageController.text.trim().isEmpty ? null : _villageController.text.trim(),
        neighborhood: _neighborhoodController.text.trim().isEmpty ? null : _neighborhoodController.text.trim(),
        streetType: _streetTypeController.text.trim().isEmpty ? null : _streetTypeController.text.trim(),
        streetName: _streetNameController.text.trim().isEmpty ? null : _streetNameController.text.trim(),
        lane: _laneController.text.trim().isEmpty ? null : _laneController.text.trim(),
        alley: _alleyController.text.trim().isEmpty ? null : _alleyController.text.trim(),
        number: _numberController.text.trim().isEmpty ? null : _numberController.text.trim(),
        floor: _floorController.text.trim().isEmpty ? null : _floorController.text.trim(),
        fullAddress: _fullAddressController.text.trim().isEmpty ? null : _fullAddressController.text.trim(),
        healthStatus: _healthStatusController.text.trim().isEmpty ? null : _healthStatusController.text.trim(),
        medications: _medicationsController.text.trim().isEmpty ? null : _medicationsController.text.trim(),
        supplements: _supplementsController.text.trim().isEmpty ? null : _supplementsController.text.trim(),
        userLogin: user.userLogin,
      );

      // 新增客戶（類似 Java 的 customerService.addCustomer(customer)）
      await _supabaseService.addCustomer(customer);

      // 顯示成功訊息
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('客戶資料已成功新增！'),
            backgroundColor: AppColors.success,
          ),
        );
        // 返回上一頁
        Navigator.pop(context, true); // 返回 true 表示成功，讓上一頁可以重新載入
      }
    } catch (e) {
      // 顯示錯誤訊息
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

  /// 建立姓名輸入欄位
  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: '姓名 *',
        hintText: '請輸入客戶姓名',
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '請輸入姓名';
        }
        return null;
      },
    );
  }

  /// 建立電話輸入欄位
  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      decoration: const InputDecoration(
        labelText: '通訊電話 *',
        hintText: '請輸入電話號碼',
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '請輸入電話號碼';
        }
        return null;
      },
    );
  }

  /// 建立地址相關欄位
  Widget _buildAddressFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 縣市
        TextFormField(
          controller: _cityController,
          decoration: const InputDecoration(
            labelText: '縣市 *',
            hintText: '例如：台北市',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '請輸入縣市';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // 鄉鎮市區
        TextFormField(
          controller: _districtController,
          decoration: const InputDecoration(
            labelText: '鄉鎮市區 *',
            hintText: '例如：中正區',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '請輸入鄉鎮市區';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // 村/里
        TextFormField(
          controller: _villageController,
          decoration: const InputDecoration(
            labelText: '村/里',
            hintText: '例如：高林村、中正里',
          ),
        ),
        const SizedBox(height: 16),
        
        // 鄰
        TextFormField(
          controller: _neighborhoodController,
          decoration: const InputDecoration(
            labelText: '鄰',
            hintText: '例如：8鄰',
          ),
        ),
        const SizedBox(height: 16),
        
        // 路街類型和名稱（同一行）
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: _streetTypeController,
                decoration: const InputDecoration(
                  labelText: '路街類型',
                  hintText: '路/街',
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: _streetNameController,
                decoration: const InputDecoration(
                  labelText: '路街名稱',
                  hintText: '例如：中山路',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // 巷和弄（同一行）
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _laneController,
                decoration: const InputDecoration(
                  labelText: '巷',
                  hintText: '例如：1',
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _alleyController,
                decoration: const InputDecoration(
                  labelText: '弄',
                  hintText: '例如：2',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // 號和樓（同一行）
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _numberController,
                decoration: const InputDecoration(
                  labelText: '號',
                  hintText: '例如：100',
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _floorController,
                decoration: const InputDecoration(
                  labelText: '樓',
                  hintText: '例如：5樓',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // 完整地址
        TextFormField(
          controller: _fullAddressController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: '詳細地址（完整地址）',
            hintText: '系統會自動組合完整地址，或可手動輸入',
          ),
        ),
      ],
    );
  }

  /// 建立健康相關欄位
  Widget _buildHealthFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _healthStatusController,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: '健康狀況',
            hintText: '請輸入客戶的健康狀況...',
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _medicationsController,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: '服用藥物',
            hintText: '請輸入服用的藥物...',
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _supplementsController,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: '服用保健食品',
            hintText: '請輸入服用的保健食品...',
          ),
        ),
      ],
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
                    '新增客戶',
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
        title: const Text('新增客戶'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '新增客戶資料',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              
              // 基本資料
              _buildNameField(),
              const SizedBox(height: 16),
              _buildPhoneField(),
              const SizedBox(height: 32),
              
              // 地址資料
              const Text(
                '地址資訊',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              _buildAddressFields(),
              const SizedBox(height: 32),
              
              // 健康資訊
              const Text(
                '健康資訊',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              _buildHealthFields(),
              const SizedBox(height: 32),
              
              // 提交按鈕
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }
}


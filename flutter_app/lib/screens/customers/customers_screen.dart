import 'package:flutter/material.dart';
import '../../models/customer_model.dart';
import '../../services/supabase_service.dart';
import 'add_customer_screen.dart'; // 導入新增客戶頁面

/// 客戶資料頁面 - 顯示和管理客戶資訊
class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  List<CustomerModel> _customers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  /// 載入所有客戶資料
  Future<void> _loadCustomers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final customers = await _supabaseService.getAllCustomers();
      setState(() {
        _customers = customers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorMessage('載入客戶資料失敗: $e');
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

  /// 處理刪除客戶
  Future<void> _handleDeleteCustomer(CustomerModel customer) async {
    final confirmed = await _showDeleteConfirmDialog();
    
    if (confirmed != true) {
      return;
    }

    try {
      await _supabaseService.deleteCustomer(customer.id);
      _loadCustomers();
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
        content: const Text('確定要刪除此客戶嗎？'),
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

  /// 建立客戶卡片
  Widget _buildCustomerCard(CustomerModel customer) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: _buildCustomerAvatar(customer),
        title: Text(customer.name),
        subtitle: _buildCustomerSubtitle(customer),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => _handleDeleteCustomer(customer),
        ),
      ),
    );
  }

  /// 建立客戶頭像
  Widget _buildCustomerAvatar(CustomerModel customer) {
    return CircleAvatar(
      child: Text(customer.name[0].toUpperCase()),
    );
  }

  /// 建立客戶副標題內容
  Widget _buildCustomerSubtitle(CustomerModel customer) {
    final children = <Widget>[];

    if (customer.phone != null) {
      children.add(Text('電話: ${customer.phone}'));
    }

    if (customer.fullAddress != null) {
      children.add(Text('地址: ${customer.fullAddress}'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  /// 建立客戶列表
  Widget _buildCustomersList() {
    return ListView.builder(
      itemCount: _customers.length,
      itemBuilder: (context, index) {
        return _buildCustomerCard(_customers[index]);
      },
    );
  }

  /// 建立空狀態提示
  Widget _buildEmptyState() {
    return const Center(
      child: Text('還沒有客戶資料'),
    );
  }

  /// 建立主要內容區域
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_customers.isEmpty) {
      return _buildEmptyState();
    }

    return _buildCustomersList();
  }

  /// 處理新增客戶按鈕點擊
  /// 導航到新增客戶頁面
  Future<void> _handleAddCustomer() async {
    // 導航到新增客戶頁面（類似 Java 的頁面跳轉）
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddCustomerScreen(),
      ),
    );
    
    // 如果新增成功（返回 true），重新載入客戶列表
    if (result == true) {
      _loadCustomers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _handleAddCustomer,
        child: const Icon(Icons.add),
      ),
    );
  }
}

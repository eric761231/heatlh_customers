import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/order_model.dart';
import '../../services/supabase_service.dart';
import 'add_order_screen.dart'; // 導入新增訂單頁面

/// 訂單管理頁面 - 顯示和管理訂單資訊
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  List<OrderModel> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  /// 載入所有訂單資料
  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final orders = await _supabaseService.getAllOrders();
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorMessage('載入訂單失敗: $e');
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

  /// 處理刪除訂單
  Future<void> _handleDeleteOrder(OrderModel order) async {
    final confirmed = await _showDeleteConfirmDialog();
    
    if (confirmed != true) {
      return;
    }

    try {
      await _supabaseService.deleteOrder(order.id);
      _loadOrders();
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
        content: const Text('確定要刪除此訂單嗎？'),
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

  /// 格式化日期
  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// 建立訂單卡片
  Widget _buildOrderCard(OrderModel order) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(order.product),
        subtitle: _buildOrderSubtitle(order),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => _handleDeleteOrder(order),
        ),
      ),
    );
  }

  /// 建立訂單副標題內容
  Widget _buildOrderSubtitle(OrderModel order) {
    final children = <Widget>[
      Text('日期: ${_formatDate(order.date)}'),
    ];

    if (order.customerName != null) {
      children.add(Text('客戶: ${order.customerName}'));
    }

    children.add(Text('數量: ${order.quantity}'));
    children.add(Text('金額: \$${order.amount.toStringAsFixed(2)}'));

    // 付款狀態（帶顏色）
    children.add(
      Text(
        '付款狀態: ${order.paid ? "已付款" : "未付款"}',
        style: TextStyle(
          color: order.paid ? Colors.green : Colors.red,
        ),
      ),
    );

    if (order.notes != null && order.notes!.isNotEmpty) {
      children.add(Text('備註: ${order.notes}'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  /// 建立訂單列表
  Widget _buildOrdersList() {
    return ListView.builder(
      itemCount: _orders.length,
      itemBuilder: (context, index) {
        return _buildOrderCard(_orders[index]);
      },
    );
  }

  /// 建立空狀態提示
  Widget _buildEmptyState() {
    return const Center(
      child: Text('還沒有訂單資料'),
    );
  }

  /// 建立主要內容區域
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_orders.isEmpty) {
      return _buildEmptyState();
    }

    return _buildOrdersList();
  }

  /// 處理新增訂單按鈕點擊
  /// 導航到新增訂單頁面
  Future<void> _handleAddOrder() async {
    // 導航到新增訂單頁面
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddOrderScreen(),
      ),
    );
    
    // 如果新增成功（返回 true），重新載入訂單列表
    if (result == true) {
      _loadOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _handleAddOrder,
        child: const Icon(Icons.add),
      ),
    );
  }
}

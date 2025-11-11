import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../calendar/calendar_screen.dart';
import '../customers/customers_screen.dart';
import '../orders/orders_screen.dart';

/// 主頁面 - 包含底部導航和主要功能頁面
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 當前選中的底部導航索引
  int _currentIndex = 0;

  // 所有主要功能頁面列表
  final List<Widget> _screens = [
    const CalendarScreen(),    // 行程事項頁面
    const CustomersScreen(),   // 客戶資料頁面
    const OrdersScreen(),      // 訂貨清單頁面
  ];

  /// 處理底部導航切換
  void _onNavigationItemSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  /// 處理登出操作
  Future<void> _handleLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.signOut();
  }

  /// 建立底部導航欄
  Widget _buildBottomNavigationBar() {
    return NavigationBar(
      selectedIndex: _currentIndex,
      onDestinationSelected: _onNavigationItemSelected,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.calendar_today),
          label: '行程事項',
        ),
        NavigationDestination(
          icon: Icon(Icons.people),
          label: '客戶資料',
        ),
        NavigationDestination(
          icon: Icon(Icons.shopping_cart),
          label: '訂貨清單',
        ),
      ],
    );
  }

  /// 建立 AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('葡眾愛客戶管理系統'),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: _handleLogout,
          tooltip: '登出',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
}

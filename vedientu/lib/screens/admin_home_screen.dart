import 'package:flutter/material.dart';
import 'user_list_screen.dart';
import 'bus_list_screen.dart';
import 'admin_transactions_screen.dart';
import 'report_screen.dart';
import '../services/api_service.dart';
import 'package:go_router/go_router.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;
  Map<String, dynamic>? userProfile;
  bool isLoadingProfile = true;

  final List<Widget> _screens = [
    const ReportScreen(),            // Doanh thu
    const UserListScreen(),
    BusListScreen(),
    const AdminTransactionsScreen(),
  ];

  final List<String> _titles = [
    "Quản lý Doanh thu",
    "Quản lý Người dùng",
    "Quản lý Xe buýt",
    "Quản lý Giao dịch",
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await ApiService().getUserProfile();
      if (!mounted) return;
      setState(() {
        userProfile = profile;
        isLoadingProfile = false;
      });
    } catch (e) {
      debugPrint('❌ Lỗi khi lấy thông tin user: $e');
      setState(() {
        isLoadingProfile = false;
      });
    }
  }

  Future<void> _logout() async {
    await ApiService().logout(context);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: PreferredSize(
      preferredSize: const Size.fromHeight(85),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        child: AppBar(
          toolbarHeight: 85,
          backgroundColor: const Color.fromRGBO(42, 158, 207, 1),
          title: Row(
            children: [
              // Avatar sử dụng icon có sẵnn
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  size: 30,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(width: 12),
              // Thông tin người dùng
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Xin chào ${userProfile?['fullName'] ?? 'Người dùng'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '📧 Email: ${userProfile?['email'] ?? 'Không có email'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Đăng xuất',
              onPressed: _logout,
            ),
          ],
        ),
      ),
    ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: const Color.fromARGB(179, 0, 0, 0),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Doanh thu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Người dùng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_bus),
            label: 'Xe buýt',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Giao dịch',
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/api_service.dart';
import 'my_tickets_screen.dart';
import 'my_rides_screen.dart';
import 'transaction_history_screen.dart';
import 'user_profile_screen.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String? token;
  Map<String, dynamic>? userProfile;
  List<dynamic> tickets = [];
  bool isLoading = true;

  final List<Widget> _screens = [
    MyTicketsScreen(), // Màn hình danh sách vé đã mua
    MyTicketsScreen(), // Màn hình danh sách vé
    MyRidesScreen(), // Lịch sử chuyến đi
    MyTransactionsScreen(), // Lịch sử giao dịch
    UserProfilePage(), // Thông tin tài khoản
  ];

  final List<String> _titles = [
    "Trang chủ",
    "Danh sách vé",
    "Lịch sử chuyến đi",
    "Lịch sử giao dịch",
    "Thông tin tài khoản",
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    token = await ApiService().getToken();
    debugPrint('🔑 Token: $token');

    if (token == null) {
      if (!mounted) return;
      context.go('/'); // Chuyển về trang login nếu chưa có token
      return;
    }

    try {
      userProfile = await ApiService().getUserProfile();
      tickets = await ApiService().getTickets();
    } catch (e) {
      debugPrint('❌ Lỗi khi tải dữ liệu: $e');
      userProfile = null;
    }

    setState(() {
      isLoading = false;
    });
  }

  // Đăng xuất
  Future<void> _logout(BuildContext context) async {
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
                onPressed: () => _logout(context),
              ),
            ],
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: const Color.fromARGB(179, 0, 0, 0),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Danh sách vé',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Lịch sử chuyến đi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Lịch sử giao dịch',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Thông tin tài khoản',
          ),
        ],
      ),
    );
  }
}

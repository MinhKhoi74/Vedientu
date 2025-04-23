import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'scan_qr_screen.dart';
import 'driver_profile_screen.dart';
import 'driver_trip_list_screen.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  int _selectedIndex = 0;
  Map<String, dynamic>? userProfile;
  bool isLoading = true;
  bool isTripOpen = false;

  final List<Widget> _screens = [
    const DriverTripListScreen(),
    const ScanQRScreen(),
    const DriverProfilePage(),
  ];

  final List<String> _titles = [
    "Danh sách hành khách",
    "Quét mã QR",
    "Trang cá nhân",
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final profile = await ApiService().getUserProfile();
      final tripStatus = await ApiService().getTripStatus();
      if (!mounted) return;
      setState(() {
        userProfile = profile;
        isTripOpen = tripStatus;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Lỗi khi tải dữ liệu: $e');
      setState(() => isLoading = false);
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
                      'Xin chào ${userProfile?['fullName'] ?? 'Tài xế'}',
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  color: Colors.grey.shade200,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Trạng thái hoạt động: ${isTripOpen ? 'Đang mở ✅' : 'Đã đóng 🛑'}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      Switch(
                        value: isTripOpen,
                        onChanged: (value) => _toggleTripStatus(value),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: _screens,
                  ),
                ),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: const Color.fromARGB(179, 0, 0, 0),
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Chuyến đi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Quét mã',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Cá nhân',
          ),
        ],
      ),
    );
  }

  Future<void> _toggleTripStatus(bool newStatus) async {
    if (!newStatus) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Xác nhận đóng chuyến?'),
          content: const Text(
              'Bạn có chắc chắn muốn đóng chuyến không? Hành khách sẽ không thể lên xe nữa.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Xác nhận'),
            ),
          ],
        ),
      );
      if (confirm != true) return;
    }

    setState(() => isLoading = true);

    final response =
        newStatus ? await ApiService().openTrip() : await ApiService().closeTrip();

    bool success = response != null &&
        (response['success'] == true || response['status'] == true);

    setState(() {
      isLoading = false;
      if (success) {
        isTripOpen = newStatus;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newStatus
                ? '✅ Đã mở chuyến đi thành công!'
                : '🛑 Đã đóng chuyến đi!'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Lỗi khi cập nhật trạng thái chuyến đi')),
        );
      }
    });
  }
}

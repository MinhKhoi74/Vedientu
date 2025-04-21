import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/api_service.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  DriverHomeScreenState createState() => DriverHomeScreenState();
}

class DriverHomeScreenState extends State<DriverHomeScreen> {
  String? token;
  Map<String, dynamic>? userProfile;
  bool isLoading = true;
  bool isTripOpen = false; // ✅ Trạng thái chuyến đi

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);

    token = await ApiService().getToken();
    if (token == null) {
      if (!mounted) return;
      context.go('/driver-home');
      return;
    }

    try {
      userProfile = await ApiService().getUserProfile();

      // ✅ Gọi thêm API lấy trạng thái chuyến đi
      bool tripStatus = await ApiService().getTripStatus();
      isTripOpen = tripStatus;
    } catch (e) {
      debugPrint('❌ Lỗi khi tải dữ liệu: $e');
      userProfile = null;
    }

    setState(() => isLoading = false);
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

    Map<String, dynamic>? response =
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
          const SnackBar(
              content: Text('❌ Lỗi khi cập nhật trạng thái chuyến đi')),
        );
      }
    });
  }

  Future<void> _logout(BuildContext context) async {
    await ApiService().logout(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Xin chào ${userProfile?['fullName'] ?? 'Tài xế'}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : token == null
              ? const Center(child: Text('Vui lòng đăng nhập'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (userProfile != null) ...[
                        Text(
                          '📧 Email: ${userProfile!['email'] ?? 'Không có email'}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                      ],

                      const SizedBox(height: 16),

                      Row(
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

                      const SizedBox(height: 24),

                      ElevatedButton(
                        onPressed: () => context.go('/scan-qr'),
                        child: const Text('📷 Quét mã QR để lên xe'),
                      ),
                      ElevatedButton(
                        onPressed: () => context.go('/driver-trip'),
                        child: const Text('👥 Danh sách hành khách'),
                      ),
                      ElevatedButton(
                        onPressed: () => context.go('/driver-profile'),
                        child: const Text('👥 Trang cá nhân'),
                      ),
                    ],
                  ),
                ),
    );
  }
}

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
                      ElevatedButton(
                        onPressed: () => context.go('/scan-qr'),
                        child: const Text('📷 Quét mã QR để lên xe'),
                      ),
                      ElevatedButton(
                        onPressed: () => context.go('/passenger-list'),
                        child: const Text('👥 Danh sách hành khách'),
                      ),
                    ],
                  ),
                ),
    );
  }
}

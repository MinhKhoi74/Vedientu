import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  String? token;
  Map<String, dynamic>? userProfile;
  List<dynamic> tickets = [];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Xin chào ${userProfile?['fullName'] ?? 'Người dùng'}'),
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
                      const Text(
                        '🎟️ Danh sách vé đã mua:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: tickets.isEmpty
                            ? const Center(child: Text('Bạn chưa mua vé nào.'))
                            : ListView.builder(
                                itemCount: tickets.length,
                                itemBuilder: (context, index) {
                                  final ticket = tickets[index];
                                  return ListTile(
                                    title: Text('Loại vé: ${ticket['ticketType'] ?? 'Không rõ'}'),
                                    subtitle: Text(
                                      'Lượt dùng còn lại: ${ticket['remainingRides'] ?? 'Chưa cập nhật'}',
                                    ),
                                    trailing: ElevatedButton(
                                      onPressed: () => context.push('/tickets/${ticket['id']}', extra: ticket),
                                      child: const Text('Chi tiết'),
                                    ),
                                  );
                                },
                              ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.go('/buy-ticket'),
                        child: const Text('Mua vé mới'),
                      ),
                      ElevatedButton(
                        onPressed: () => context.go('/tickets'),
                        child: const Text('Danh sách vé'),
                      ),
                      ElevatedButton(
                        onPressed: () => context.go('/transactions'),
                        child: const Text('Lịch sử giao dịch'),
                      ),
                    ],
                  ),
                ),
    );
  }
}

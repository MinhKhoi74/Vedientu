import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'package:go_router/go_router.dart';
class DriverProfilePage extends StatefulWidget {
  const DriverProfilePage({Key? key}) : super(key: key);

  @override
  _DriverProfilePageState createState() => _DriverProfilePageState();
}

class _DriverProfilePageState extends State<DriverProfilePage> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? userProfile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    var profile = await _apiService.getUserProfile();
    setState(() {
      userProfile = profile;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thông tin tài khoản'),
      leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/driver-home'), // Quay về trang chính
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userProfile == null
              ? const Center(child: Text('Không thể tải thông tin người dùng.'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Họ và tên: ${userProfile!['fullName']}', style: TextStyle(fontSize: 18)),
                      Text('Email: ${userProfile!['email']}', style: TextStyle(fontSize: 18)),
                      Text('Số điện thoại: ${userProfile!['phone']}', style: TextStyle(fontSize: 18)),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          await _apiService.logout(context);
                        },
                        child: const Text('Đăng xuất'),
                      ),
                    ],
                  ),
                ),
    );
  }
}

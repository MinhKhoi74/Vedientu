import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'package:go_router/go_router.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({Key? key}) : super(key: key);

  @override
  UserListScreenState createState() => UserListScreenState();
}

class UserListScreenState extends State<UserListScreen> {
  final ApiService _apiService = ApiService();
  Future<List<dynamic>>? _userList;
  String? _userRole;

  String selectedRole = 'Tất cả';
  final List<String> roles = ['Tất cả', 'ADMIN', 'DRIVER', 'CUSTOMER'];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadUserRole();
    if (_userRole == 'ADMIN') {
      _refreshUsers();
    }
  }

  Future<void> _loadUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userRole = prefs.getString('role');
    });
    debugPrint("🔹 Vai trò hiện tại: $_userRole");
  }

  Future<void> _refreshUsers() async {
    setState(() {
      _userList = _apiService.getAllUsers();
    });
  }

  Future<void> _deleteUser(int userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc muốn xóa người dùng này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await _apiService.deleteUserById(userId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Xóa người dùng thành công')),
      );
      _refreshUsers(); // Làm mới danh sách
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Không thể xóa người dùng')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách người dùng'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin-home'),
        ),
      ),
      body: _userRole != 'ADMIN'
          ? const Center(child: Text('🚫 Bạn không có quyền truy cập.'))
          : FutureBuilder<List<dynamic>>(
              future: _userList ?? Future.value([]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('❌ Lỗi: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Không có người dùng nào.'));
                }

                final users = snapshot.data!;
                final filteredUsers = selectedRole == 'Tất cả'
                    ? users
                    : users.where((u) => u['role'] == selectedRole).toList();

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownButton<String>(
                        value: selectedRole,
                        items: roles.map((role) {
                          return DropdownMenuItem<String>(
                            value: role,
                            child: Text(role),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedRole = value!;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = filteredUsers[index];
                          final userName = user['fullName'] ?? 'Không có tên';
                          final userEmail = user['email'] ?? 'Không có email';
                          final userRole = user['role'] ?? 'Không xác định';

                          return Card(
                            child: ListTile(
                              leading: Icon(
                                userRole == 'ADMIN'
                                    ? Icons.admin_panel_settings
                                    : userRole == 'DRIVER'
                                        ? Icons.local_shipping
                                        : Icons.person,
                                color: userRole == 'ADMIN'
                                    ? Colors.blue
                                    : userRole == 'DRIVER'
                                        ? Colors.orange
                                        : Colors.grey,
                              ),
                              title: Text(userName),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Email: $userEmail'),
                                  Text('Vai trò: $userRole'),
                                ],
                              ),
                              trailing: userRole != 'ADMIN'
                                  ? IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        _deleteUser(user['id']);
                                      },
                                    )
                                  : null, // Không hiển thị nút xóa nếu người dùng là ADMIN
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}

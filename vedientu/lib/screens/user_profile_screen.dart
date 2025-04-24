import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'package:go_router/go_router.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? userProfile;
  bool isLoading = true;
  bool isEditing = false; // Biến để theo dõi chế độ chỉnh sửa
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // Lấy thông tin người dùng từ API
  Future<void> _loadUserProfile() async {
    var profile = await _apiService.getUserProfile();
    setState(() {
      userProfile = profile;
      isLoading = false;
      _fullNameController.text = userProfile!['fullName'] ?? '';
      _phoneController.text = userProfile!['phone'] ?? '';
      _emailController.text = userProfile!['email'] ?? '';
    });
  }

  // Cập nhật thông tin người dùng
  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      Map<String, String> updates = {
        'fullName': _fullNameController.text,
        'phone': _phoneController.text,
        'email': _emailController.text,
      };

      bool success = await _apiService.updateUserProfile(updates);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thông tin người dùng đã được cập nhật!')),
        );
        setState(() {
          isEditing = false; // Khi cập nhật thành công, tắt chế độ chỉnh sửa
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật thất bại.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin tài khoản'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'), // Quay về trang chính
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
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _fullNameController,
                              decoration: const InputDecoration(
                                labelText: 'Họ và tên',
                              ),
                              enabled: isEditing, // Chỉ cho phép chỉnh sửa khi isEditing = true
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Họ và tên không được để trống';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _phoneController,
                              decoration: const InputDecoration(
                                labelText: 'Số điện thoại',
                              ),
                              enabled: isEditing, // Chỉ cho phép chỉnh sửa khi isEditing = true
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Số điện thoại không được để trống';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                              ),
                              enabled: isEditing, // Chỉ cho phép chỉnh sửa khi isEditing = true
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Email không được để trống';
                                } else if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                                  return 'Vui lòng nhập email hợp lệ';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            isEditing // Hiển thị nút Cập nhật chỉ khi đang ở chế độ chỉnh sửa
                                ? ElevatedButton(
                                    onPressed: _updateProfile,
                                    child: const Text('Cập nhật'),
                                  )
                                : ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        isEditing = true; // Bật chế độ chỉnh sửa
                                      });
                                    },
                                    child: const Text('Chỉnh sửa thông tin'),
                                  ),
                          ],
                        ),
                      ),
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

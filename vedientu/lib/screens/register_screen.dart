import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart'; // import AuthService
import 'login_screen.dart'; // import LoginScreen
import 'package:go_router/go_router.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isChecked = false;

  void _register() async {
  String name = _nameController.text.trim();
  String email = _emailController.text.trim();
  String password = _passwordController.text;
  String confirmPassword = _confirmPasswordController.text;
  String phone = _phoneController.text.trim();

  if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty || phone.isEmpty) {
    _showDialog("Lỗi", "Vui lòng nhập đầy đủ thông tin!");
    return;
  }

  if (!RegExp(r"^[\w-\.]+@gmail\.com$").hasMatch(email)) {
    _showDialog("Lỗi", "Vui lòng nhập địa chỉ Gmail hợp lệ.");
    return;
  }

  if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{6,}$').hasMatch(password)) {
    _showDialog("Lỗi", "Mật khẩu phải đủ mạnh (6 kí tự trở lên, có ít nhất 1 chữ cái thường, 1 chữ cái in hoa, 1 chữ số, 1 ký tự đặc biệt).");
    return;
  }

  if (password != confirmPassword) {
    _showDialog("Lỗi", "Mật khẩu không khớp!");
    return;
  }

  if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
    _showDialog("Lỗi", "Số điện thoại chỉ được chứa số.");
    return;
  }

  if (!_isChecked) {
    _showDialog("Lỗi", "Bạn phải xác nhận không phải robot!");
    return;
  }

  // Kiểm tra email và số điện thoại đã đăng ký chưa
  try {
    bool isEmailRegistered = await ApiService().checkEmailExists(email);
    bool isPhoneRegistered = await ApiService().checkPhoneExists(phone);

    if (isEmailRegistered) {
      _showDialog("Lỗi", "Email này đã được đăng ký!");
      return;
    }

    if (isPhoneRegistered) {
      _showDialog("Lỗi", "Số điện thoại này đã được đăng ký!");
      return;
    }

    // Nếu không trùng lặp, thực hiện đăng ký
    bool isSuccess = await ApiService().registerWithRole(name, email, password, phone, 'CUSTOMER'); // hoặc 'DRIVER'

    if (isSuccess) {
  _showDialog("Thành công", "Đăng ký thành công!", onOk: () {
    GoRouter.of(context).go('/');
  });
}
else {
      _showDialog("Lỗi", "Đăng ký thất bại. Vui lòng thử lại.");
    }
  } catch (e) {
    _showDialog("Lỗi", "Không thể kết nối đến server.");
  }
}


  void _showDialog(String title, String message, {VoidCallback? onOk}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (onOk != null) onOk();
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller, bool obscure,
      {bool isPassword = false, bool isConfirmPassword = false}) {
    bool show = isPassword ? _isPasswordVisible : (isConfirmPassword ? _isConfirmPasswordVisible : false);
    return TextField(
      controller: controller,
      obscureText: isPassword || isConfirmPassword ? !show : false,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: (isPassword || isConfirmPassword)
            ? IconButton(
                icon: Icon(show ? Icons.visibility_off : Icons.visibility),
                onPressed: () {
                  setState(() {
                    if (isPassword) _isPasswordVisible = !_isPasswordVisible;
                    if (isConfirmPassword) _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  });
                },
              )
            : null,
        border: OutlineInputBorder(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text("Đăng ký"),
        leading: IconButton(
  icon: Icon(Icons.arrow_back),
  onPressed: () => GoRouter.of(context).go('/'), // Điều hướng tới LoginScreen
),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Icon(Icons.app_registration, size: 80, color: Colors.blue[600])),
              SizedBox(height: 10),
              Center(
                child: Text(
                  "Tạo tài khoản mới",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue[800]),
                ),
              ),
              SizedBox(height: 15),
              _buildTextField("Họ và tên (*)", Icons.person, _nameController, false),
              SizedBox(height: 10),
              _buildTextField("Email bạn sử dụng (*)", Icons.email, _emailController, false),
              SizedBox(height: 10),
              _buildTextField("Mật khẩu (*)", Icons.lock, _passwordController, true, isPassword: true),
              SizedBox(height: 10),
              _buildTextField("Nhập lại mật khẩu (*)", Icons.lock, _confirmPasswordController, true, isConfirmPassword: true),
              SizedBox(height: 10),
              _buildTextField("Số điện thoại (*)", Icons.phone, _phoneController, false),
              SizedBox(height: 15),
              Row(
                children: [
                  Checkbox(
                    value: _isChecked,
                    onChanged: (value) => setState(() => _isChecked = value!),
                    activeColor: Colors.blue,
                  ),
                  Text("Tôi không phải người máy", style: TextStyle(fontSize: 16)),
                ],
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text("Đăng ký", style: TextStyle(fontSize: 18)),
                ),
              ),
              SizedBox(height: screenHeight * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}

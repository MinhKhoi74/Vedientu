import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _login() async {
    String account = _accountController.text.trim();
    String password = _passwordController.text.trim();

    if (account.isEmpty || password.isEmpty) {
      _showDialog("Lỗi", "Vui lòng nhập đầy đủ thông tin!");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final apiService = ApiService();
    bool isLoggedIn = await apiService.login(account, password);

    setState(() {
      _isLoading = false;
    });

    if (isLoggedIn) {
      String role = await apiService.getUserRole() ?? '';

      // Điều hướng đến trang tương ứng
      if (role == 'CUSTOMER') {
        context.go('/home');
      } else if (role == 'DRIVER') {
        context.go('/driver-home');
      } else if (role == 'ADMIN') {
        context.go('/admin-home');
      } else {
        _showDialog("Lỗi", "Vai trò người dùng không hợp lệ!");
      }
    } else {
      _showDialog("Lỗi", "Sai tài khoản hoặc mật khẩu!");
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_person, size: 80, color: Colors.blue[600]),
              SizedBox(height: 10),
              Text(
                "Đăng nhập",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue[800]),
              ),
              SizedBox(height: 25),
              _buildTextField("Tài khoản", Icons.person, _accountController, false),
              SizedBox(height: 15),
              _buildTextField("Mật khẩu", Icons.lock, _passwordController, true, isPassword: true),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text("Đăng nhập", style: TextStyle(fontSize: 18)),
                ),
              ),
              SizedBox(height: 15),
              TextButton(
                onPressed: () {
                  context.go('/forgot-password');
                },
                child: Text("Quên mật khẩu?", style: TextStyle(color: Colors.blue, fontSize: 16)),
              ),
              Text("Bạn chưa có tài khoản?", style: TextStyle(fontSize: 16, color: Colors.blueGrey)),
              TextButton(
                onPressed: () {
                  context.go('/register');
                },
                child: Text("Đăng ký tài khoản mới tại đây!", style: TextStyle(color: Colors.blue, fontSize: 16)),
              ),
              SizedBox(height: screenHeight * 0.05),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller, bool obscure, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? !_isPasswordVisible : false,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue[600]),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.blue[600],
                ),
                onPressed: _togglePasswordVisibility,
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), // Không dùng const ở đây
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}

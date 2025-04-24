import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'otp_verification_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  final ApiService _apiService = ApiService(); // Tạo instance ApiService

  void _sendOTP() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showDialog("Lỗi", "Vui lòng nhập email.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      bool success = await _apiService.sendOTP(email); // Gọi API từ ApiService

      setState(() => _isLoading = false);

      if (success) {
        // Chuyển hướng tới trang OTPVerificationPage và truyền email
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OTPVerificationPage(email: email),
          ),
        );
      } else {
        _showDialog("Lỗi", "Gửi mã OTP thất bại. Vui lòng thử lại.");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showDialog("Lỗi", e.toString());
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
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
    return Scaffold(
      appBar: AppBar(title: Text("Quên mật khẩu")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Nhập email để nhận mã OTP", style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 1),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _sendOTP,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Nút màu xanh
                  foregroundColor: Colors.white, // Chữ trắng
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text("Gửi OTP"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

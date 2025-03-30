import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  final ApiService apiService = ApiService();

  Future<void> login() async {
    setState(() => isLoading = true);
    bool success = await apiService.login(
      emailController.text,
      passwordController.text,
    );

    if (!mounted) return; // Kiểm tra widget có còn tồn tại không

    if (success) {
      String? role = await apiService.getUserRole();
      if (!mounted) return; // Kiểm tra lần nữa trước khi sử dụng context

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("🎉 Đăng nhập thành công!"),
          backgroundColor: Colors.green,
        ),
      );
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return; // Kiểm tra lại trước khi điều hướng

      switch (role) {
        case "CUSTOMER":
          context.go('/home'); // Điều hướng đến màn hình khách hàng
          break;
        case "DRIVER":
          context.go('/driver-home'); // Điều hướng đến màn hình tài xế
          break;
        case "ADMIN":
          context.go('/admin/dashboard'); // Điều hướng đến màn hình Admin
          break;
        default:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Lỗi: Vai trò không hợp lệ!")),
          );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng nhập thất bại!')),
      );
    }
    
    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đăng nhập")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController, 
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController, 
              decoration: const InputDecoration(labelText: 'Mật khẩu'), 
              obscureText: true,
            ),
            const SizedBox(height: 16),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(onPressed: login, child: const Text('Đăng nhập')),
            TextButton(
              onPressed: () => context.go('/register'), 
              child: const Text('Chưa có tài khoản? Đăng ký')
            )
          ],
        ),
      ),
    );
  }
}

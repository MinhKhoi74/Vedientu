import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController(); // Thêm phone

  bool isLoading = false;
  final ApiService apiService = ApiService();

  Future<void> register() async {
    setState(() => isLoading = true);
    
    bool success = await apiService.register(
      nameController.text,
      emailController.text,
      passwordController.text,
      phoneController.text, // Truyền phone vào API
    );

    if (success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("🎉 Đăng ký thành công!"),
          backgroundColor: Colors.green,
        ),
      );
      await Future.delayed(const Duration(seconds: 2)); // Đợi 2 giây trước khi chuyển trang
      context.go('/'); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng ký thất bại!')),
      );
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đăng ký")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Tên')),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Mật khẩu'), obscureText: true),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Số điện thoại')), // Thêm trường phone
            const SizedBox(height: 16),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(onPressed: register, child: const Text('Đăng ký')),
            TextButton(onPressed: () => context.go('/'), child: const Text('Đã có tài khoản? Đăng nhập'))
          ],
        ),
      ),
    );
  }
}

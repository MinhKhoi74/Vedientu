import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trang Quản Trị')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => context.go('/users'),
              child: const Text("Quản lý Người dùng"),
            ),
            ElevatedButton(
              onPressed: () => context.go('/buses'),
              child: const Text("Quản lý Xe buýt"),
            ),
          ],
        ),
      ),
    );
  }
}

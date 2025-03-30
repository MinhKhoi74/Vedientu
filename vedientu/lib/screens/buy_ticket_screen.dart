import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:go_router/go_router.dart';

class BuyTicketScreen extends StatefulWidget {
  const BuyTicketScreen({super.key});

  @override
  _BuyTicketScreenState createState() => _BuyTicketScreenState();
}

class _BuyTicketScreenState extends State<BuyTicketScreen> {
  String _selectedTicketType = 'STANDARD'; // Mặc định là vé thường
  bool _isLoading = false;

  Future<void> _buyTicket() async {
    setState(() {
      _isLoading = true;
    });

    var response = await ApiService().buyTicket(_selectedTicketType);

    if (response) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('🎉 Mua vé thành công! Loại vé: $_selectedTicketType')),
      );
      if (mounted) {
        context.go('/tickets'); // Chuyển sang trang danh sách vé
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🚨 Lỗi khi mua vé! Vui lòng thử lại.')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mua vé mới'),
      leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/tickets'), // ✅ Nút quay lại trang trước
        ),
  ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Chọn loại vé:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: _selectedTicketType,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedTicketType = newValue!;
                });
              },
              items: ['STANDARD', 'VIP', 'STUDENT'].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _buyTicket, // Gọi hàm mua vé
                    child: const Text('Xác nhận mua vé'),
                  ),
          ],
        ),
      ),
    );
  }
}

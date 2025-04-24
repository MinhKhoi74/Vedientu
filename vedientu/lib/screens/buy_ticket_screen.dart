import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
class BuyTicketScreen extends StatefulWidget {
  const BuyTicketScreen({super.key});

  @override
  _BuyTicketScreenState createState() => _BuyTicketScreenState();
}

class _BuyTicketScreenState extends State<BuyTicketScreen> {
  String _selectedTicketType = 'SINGLE'; // Mặc định là vé đơn
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
        context.go('/home');
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
    final ticketOptions = ['SINGLE', 'VIP', 'MONTHLY'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mua vé mới'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'), //
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '🧾 Chọn loại vé',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedTicketType,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: ticketOptions.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value == 'SINGLE'
                              ? 'Vé đơn'
                              : value == 'VIP'
                                  ? 'Vé VIP'
                                  : 'Vé tháng',
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedTicketType = newValue!;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton.icon(
                            onPressed: _buyTicket,
                            icon: const Icon(Icons.check_circle),
                            label: const Text('Xác nhận mua vé'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              textStyle: const TextStyle(fontSize: 16),
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

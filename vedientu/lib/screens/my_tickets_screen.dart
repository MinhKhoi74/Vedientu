import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:go_router/go_router.dart';

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  _MyTicketsScreenState createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  List<dynamic> _tickets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    List<dynamic> tickets = await ApiService().getTickets();
    if (!mounted) return;

    setState(() {
      _tickets = tickets;
      _isLoading = false;
    });
  }

  Future<void> _cancelTicket(int ticketId) async {
    bool success = await ApiService().hiddenTicket(ticketId);
    if (!mounted) return;

    if (success) {
      setState(() {
        _tickets.removeWhere((ticket) => ticket['id'] == ticketId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🎟️ Vé đã được hủy thành công!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🚨 Lỗi khi hủy vé!')),
      );
    }
  }

  int _calculateDaysLeft(String expiryDateStr) {
    try {
      final expiryDate = DateTime.parse(expiryDateStr);
      final now = DateTime.now();
      final difference = expiryDate.difference(now).inDays;
      return difference > 0 ? difference : 0;
    } catch (e) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎟️ Danh sách vé của bạn'),
        
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tickets.isEmpty
              ? const Center(child: Text('Bạn chưa có vé nào.'))
              : ListView.builder(
                  itemCount: _tickets.length,
                  itemBuilder: (context, index) {
                    final ticket = _tickets[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text('Loại vé: ${ticket['ticketType']}'),
                        subtitle: Text(
                          ticket['ticketType'] == 'MONTHLY'
                              ? 'Hạn sử dụng còn lại: ${_calculateDaysLeft(ticket['expiryDate'])} ngày'
                              : 'Số lượt còn lại: ${ticket['remainingRides']}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                context.push('/tickets/${ticket['id']}', extra: ticket);
                              },
                              child: const Text('Chi tiết'),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Xác nhận hủy vé'),
                                    content: const Text('Bạn có chắc chắn muốn hủy vé này không?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context), // Đóng hộp thoại
                                        child: const Text('Không'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context); // Đóng hộp thoại
                                          _cancelTicket(ticket['id']); // Gọi API hủy vé
                                        },
                                        child: const Text('Có'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),

                          ],
                        ),
                      ),
                    );
                  },
                ),
            floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/buy-ticket'),
        label: const Text(
          'Mua vé mới',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),

    );
  }
}

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
    bool success = await ApiService().cancelTicket(ticketId);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎟️ Danh sách vé của bạn'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'), // Quay về trang chính
        ),
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
                        subtitle: Text('Số lượt còn lại: ${ticket['remainingRides']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                print('Đang mở chi tiết vé: ${ticket['id']}'); // Debug ID vé
                                context.push('/tickets/${ticket['id']}', extra: ticket);
                              },
                              child: const Text('Chi tiết'),
                            ),


                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _cancelTicket(ticket['id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/buy-ticket'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

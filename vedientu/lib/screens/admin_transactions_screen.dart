import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import 'package:go_router/go_router.dart';

class AdminTransactionsScreen extends StatefulWidget {
  const AdminTransactionsScreen({super.key});

  @override
  State<AdminTransactionsScreen> createState() => _AdminTransactionsScreenState();
}

class _AdminTransactionsScreenState extends State<AdminTransactionsScreen> {
  List<dynamic> _transactions = [];
  Map<String, dynamic>? _reportData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final transactions = await ApiService().getAllTransactionsForAdmin();
      final report = await ApiService().fetchReportSummary();

      if (!mounted) return;

      setState(() {
        _transactions = transactions;
        _reportData = report;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (_) {
      return 'Không xác định';
    }
  }

  String _formatPrice(double price) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return formatter.format(price);
  }

  Color _getTicketColor(String type) {
    switch (type.toUpperCase()) {
      case 'VIP':
        return Colors.orange;
      case 'MONTHLY':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lí giao dịch'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _transactions.isEmpty
              ? const Center(child: Text('Không có giao dịch nào.'))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_reportData != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Text(
                          '💰 Tổng doanh thu: ${_formatPrice((_reportData?["totalRevenue"] ?? 0).toDouble())}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color.fromRGBO(4, 53, 109, 1)),
                        ),
                      ),
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          final reversedTransactions = _transactions.reversed.toList(); // 👈 Đảo ngược danh sách
                          return ListView.builder(
                            itemCount: reversedTransactions.length,
                            itemBuilder: (context, index) {
                              final tx = reversedTransactions[index]; // 👈 Dùng danh sách đã đảo
                              final String status = tx['status'] ?? '';
                              final Color ticketColor = _getTicketColor(tx['ticketType'] ?? '');
                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.grey.shade300),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text('Mã giao dịch: ${tx['id']}',
                                            style: const TextStyle(fontWeight: FontWeight.bold)),
                                        const Spacer(),
                                        Text(
                                          status.toUpperCase(),
                                          style: TextStyle(
                                            color: status == 'COMPLETED' ? Colors.green : Colors.orange,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text('${tx['userFullName'] ?? 'Không rõ'}',
                                        style: const TextStyle(fontSize: 16)),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Ngày giao dịch'),
                                            Text(
                                              _formatDate(tx['transactionDate'] ?? ''),
                                              style: const TextStyle(fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            const Text('Loại vé'),
                                            Text(
                                              tx['ticketType'] ?? 'Không rõ',
                                              style: TextStyle(
                                                color: ticketColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Phương thức thanh toán: ${tx['paymentMethod'] ?? 'Không rõ'}'),
                                        Text(
                                          'Số tiền: ${_formatPrice(tx['amount']?.toDouble() ?? 0)}',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),

                  ],
                ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class TransactionDetailsScreen extends StatefulWidget {
  final int transactionId;
  final Map<String, dynamic>? transactionData;

  const TransactionDetailsScreen({super.key, required this.transactionId, this.transactionData});

  @override
  State<TransactionDetailsScreen> createState() => _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState extends State<TransactionDetailsScreen> {
  Map<String, dynamic>? transactionData;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    if (widget.transactionData != null) {
      transactionData = widget.transactionData;
      isLoading = false;
    } else {
      fetchTransactionDetails();
    }
  }

  Future<void> fetchTransactionDetails() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/user/transaction/${widget.transactionId}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          transactionData = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  String _formatPrice(double price) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return formatter.format(price);
  }

  String _formatDate(String rawDate) {
    try {
      final date = DateTime.parse(rawDate);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (_) {
      return 'Không hợp lệ';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (hasError || transactionData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết giao dịch')),
        body: const Center(child: Text('⚠️ Không tìm thấy thông tin giao dịch')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết giao dịch')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🧾 Mã giao dịch: ${widget.transactionId}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('👤 Người dùng: ${transactionData?['userFullName'] ?? 'Không rõ'}'),
            Text('💳 Loại vé: ${transactionData?['ticketType'] ?? 'Không rõ'}'),
            Text('💰 Số tiền: ${_formatPrice(transactionData?['amount']?.toDouble() ?? 0.0)}'),
            Text('📅 Ngày giao dịch: ${_formatDate(transactionData?['transactionDate'] ?? '')}'),
            Text('📄 Phương thức thanh toán: ${transactionData?['paymentMethod'] ?? 'Không rõ'}'),
            Text('📌 Trạng thái: ${transactionData?['status'] ?? 'Không rõ'}'),
          ],
        ),
      ),
    );
  }
}

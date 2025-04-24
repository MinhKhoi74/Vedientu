import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class TransactionDetailsScreen extends StatefulWidget {
  final int transactionId;
  final Map<String, dynamic>? transactionData;

  const TransactionDetailsScreen({
    super.key,
    required this.transactionId,
    this.transactionData,
  });

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

  Widget _buildLabelText(String label, String value, {Color? valueColor, bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
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

    final ticketType = transactionData?['ticketType'] ?? 'UNKNOWN';
    final status = transactionData?['status'] ?? 'UNKNOWN';
    final amount = transactionData?['amount']?.toDouble() ?? 0.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết giao dịch')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                blurRadius: 6,
                color: Colors.grey.shade200,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row đầu tiên: Mã giao dịch + Trạng thái
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mã giao dịch: ${widget.transactionId}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    status.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(transactionData?['userFullName'] ?? 'Không rõ'),

              const SizedBox(height: 12),
              _buildLabelText('Ngày giao dịch', _formatDate(transactionData?['transactionDate'] ?? '')),
              const SizedBox(height: 4),
              _buildLabelText('Loại vé', ticketType.toUpperCase(), valueColor: Colors.red, bold: true),
              const SizedBox(height: 4),
              _buildLabelText('Phương thức thanh toán', transactionData?['paymentMethod'] ?? ''),
              const SizedBox(height: 4),
              _buildLabelText('Số tiền', _formatPrice(amount), bold: true),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // 🆕 Dùng để định dạng tiền và ngày giờ

class TicketDetailsScreen extends StatefulWidget {
  final int ticketId;
  final Map<String, dynamic>? ticketData;

  const TicketDetailsScreen({super.key, required this.ticketId, this.ticketData});

  @override
  _TicketDetailsScreenState createState() => _TicketDetailsScreenState();
}

class _TicketDetailsScreenState extends State<TicketDetailsScreen> {
  Map<String, dynamic>? ticketData;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    if (widget.ticketData != null) {
      setState(() {
        ticketData = widget.ticketData;
        isLoading = false;
      });
    } else {
      fetchTicketDetails();
    }
  }

  Future<void> fetchTicketDetails() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:8080/user/tickets/${widget.ticketId}'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          ticketData = data;
          isLoading = false;
          hasError = false;
        });
      } else {
        setState(() {
          isLoading = false;
          hasError = true;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
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

  int _calculateDaysLeft(String expiryDate) {
    try {
      final expiry = DateTime.parse(expiryDate);
      final now = DateTime.now();
      final difference = expiry.difference(now).inDays;
      return difference > 0 ? difference : 0;  // Nếu hết hạn rồi thì trả về 0
    } catch (_) {
      return 0;  // Nếu có lỗi, trả về 0
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (hasError || ticketData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết vé 🎟️')),
        body: const Center(child: Text('⚠️ Không tìm thấy thông tin vé')),
      );
    }

    final String ticketType = ticketData?['ticketType'] ?? 'N/A';
    final int remainingRides = ticketData?['remainingRides'] ?? 0;
    final double price = ticketData?['price']?.toDouble() ?? 0.0;
    final String purchaseDate = ticketData?['purchaseDate'] ?? 'N/A';
    final String expiryDate = ticketData?['expiryDate'] ?? 'N/A';
    final String qrCodeBase64 = ticketData?['qrCode'] ?? '';

    Uint8List? qrCodeBytes;
    if (qrCodeBase64.isNotEmpty) {
      qrCodeBytes = base64Decode(qrCodeBase64);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết vé 🎟️')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🆔 Mã vé: ${widget.ticketId}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('🎫 Loại vé: $ticketType'),
            Text(
              ticketType == 'MONTHLY'
                  ? '📅 Hạn sử dụng còn lại: ${_calculateDaysLeft(expiryDate)} ngày'
                  : '⏳ Số lượt còn lại: $remainingRides',
            ),
            Text('💰 Giá: ${_formatPrice(price)}'),
            Text('📅 Ngày mua: ${_formatDate(purchaseDate)}'),
            Text('📆 Hạn sử dụng: ${_formatDate(expiryDate)}'),
            const SizedBox(height: 20),
            if (qrCodeBytes != null)
              Center(child: Image.memory(qrCodeBytes, width: 200, height: 200))
            else
              const Center(child: Text('⚠️ Không có mã QR')),
          ],
        ),
      ),
    );
  }
}

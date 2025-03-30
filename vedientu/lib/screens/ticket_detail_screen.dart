import 'dart:convert'; // Dùng để giải mã Base64
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
      print("🔍 Đang gửi request API với ticketId: ${widget.ticketId}");

      final response = await http.get(Uri.parse('http://localhost:8080/user/tickets/${widget.ticketId}'));

      print("📩 Response status: ${response.statusCode}");
      print("📦 Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("✅ Dữ liệu nhận được: $data");

        setState(() {
          ticketData = data;
          isLoading = false;
          hasError = false;
        });
      } else {
        print("❌ Lỗi API: ${response.statusCode}");
        setState(() {
          isLoading = false;
          hasError = true;
        });
      }
    } catch (e) {
      print("🔥 Lỗi khi gọi API: $e");
      setState(() {
        isLoading = false;
        hasError = true;
      });
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

    // 🏷 Lấy dữ liệu từ API
    final String ticketType = ticketData?['ticketType'] ?? 'N/A';
    final int remainingRides = ticketData?['remainingRides'] ?? 0;
    final double price = ticketData?['price']?.toDouble() ?? 0.0;
    final String purchaseDate = ticketData?['purchaseDate'] ?? 'N/A';
    final String expiryDate = ticketData?['expiryDate'] ?? 'N/A';
    final String qrCodeBase64 = ticketData?['qrCode'] ?? '';

    // 📷 Chuyển đổi mã QR từ Base64 thành hình ảnh
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
            Text('⏳ Số lượt còn lại: $remainingRides'),
            Text('💰 Giá: ${price.toStringAsFixed(2)} VNĐ'),
            Text('📅 Ngày mua: $purchaseDate'),
            Text('📆 Hạn sử dụng: $expiryDate'),
            const SizedBox(height: 20),

            // 🖼️ Hiển thị ảnh QR nếu có
            if (qrCodeBytes != null)
              Center(
                child: Image.memory(qrCodeBytes, width: 200, height: 200),
              )
            else
              const Center(child: Text('⚠️ Không có mã QR')),
          ],
        ),
      ),
    );
  }
}

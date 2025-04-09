import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/api_service.dart';
import 'package:go_router/go_router.dart';
class ScanQRScreen extends StatefulWidget {
  const ScanQRScreen({Key? key}) : super(key: key);

  @override
  _ScanQRScreenState createState() => _ScanQRScreenState();
}

class _ScanQRScreenState extends State<ScanQRScreen> {
  Barcode? result;
  final ApiService apiService = ApiService();
  bool isProcessing = false;
  final MobileScannerController cameraController = MobileScannerController(); // Khởi tạo controller

  @override
  void dispose() {
    cameraController.dispose(); // Giải phóng camera khi thoát
    super.dispose();
  }

  // ✅ Hàm xử lý quét mã QR
  void _onDetect(BarcodeCapture barcodeCapture) async {
  if (isProcessing) return; // Không xử lý nếu đang bận
  setState(() => isProcessing = true);

  final Barcode? barcode = barcodeCapture.barcodes.isNotEmpty ? barcodeCapture.barcodes.first : null;
  if (barcode != null && barcode.rawValue != null) {
    setState(() => result = barcode);
    
    print("🔍 Mã QR quét được: ${barcode.rawValue}");

    // Kiểm tra định dạng mã QR
    if (!barcode.rawValue!.startsWith("TicketID")) {
      _showMessage("❌ Mã QR không đúng định dạng");
      setState(() => isProcessing = false);
      return;
    }

    // Tách mã QR và chỉ lấy phần "TicketID"
    String ticketId = barcode.rawValue!.split(",").firstWhere((element) => element.startsWith("TicketID")).split(":").last.trim();

    try {
      print("📤 Gửi request đến API với mã TicketID: $ticketId");
      final response = await apiService.scanDriverQR("TicketID:$ticketId");
      print("📥 Phản hồi từ API: $response");

      if (response != null) {
        final isSuccess = response['success'] as bool? ?? false;
        final message = response['message'] as String? ?? 'Không có thông báo từ server';

        if (isSuccess) {
          _showMessage('✅ $message');
          context.go('/driver-home'); // Chuyển về trang chính của tài xế
        } else {
          _showMessage('❌ $message');
        }
      } else {
        _showMessage('❌ Không nhận được phản hồi từ server!');
      }
    } catch (e) {
      _showMessage('❌ Lỗi hệ thống: $e');
    }
  }

  Future.delayed(const Duration(seconds: 2), () {
    setState(() => isProcessing = false); // Đặt lại trạng thái sau 2s
  });
}


  // ✅ Hàm hiển thị thông báo
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quét Mã QR Tài Xế'),
      leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/driver-home'), // Quay về trang chính
        )),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: MobileScanner(
              controller: cameraController, // Dùng controller để tránh lỗi camera
              onDetect: _onDetect,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: (result != null)
                  ? Text('Mã QR: ${result!.rawValue}')
                  : const Text('Quét mã QR để kiểm tra'),
            ),
          ),
        ],
      ),
    );
  }
}

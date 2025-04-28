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
  final MobileScannerController cameraController = MobileScannerController();

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture barcodeCapture) async {
    if (isProcessing) return;  // Kiểm tra nếu đang xử lý quét, không cho quét lại
    setState(() => isProcessing = true);  // Đánh dấu đang quét

    final Barcode? barcode = barcodeCapture.barcodes.isNotEmpty ? barcodeCapture.barcodes.first : null;
    if (barcode != null && barcode.rawValue != null) {
      setState(() => result = barcode);

      if (!barcode.rawValue!.startsWith("TicketID")) {
        _showMessage("❌ Mã QR không đúng định dạng");
        setState(() => isProcessing = false);
        return;
      }

      String ticketId = barcode.rawValue!
          .split(",")
          .firstWhere((e) => e.startsWith("TicketID"))
          .split(":")
          .last
          .trim();

      try {
        final response = await apiService.scanDriverQR("TicketID:$ticketId");
        if (response != null) {
          final isSuccess = response['success'] as bool? ?? false;
          final message = response['message'] as String? ?? 'Không có thông báo từ server';

          if (isSuccess) {
            _showMessage('✅ $message');

            final tripId = response['tripId'];
            if (tripId != null) {
              await cameraController.stop();  // 🛑 Dừng camera sau khi quét thành công
              context.push('/passenger-list', extra: {'tripId': tripId});
            } else {
              _showMessage("❌ Không tìm thấy tripId trong phản hồi.");
            }
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

    // Delay thêm 2 giây để tránh quét tiếp ngay lập tức
    await Future.delayed(const Duration(seconds: 2), () {
      setState(() => isProcessing = false);  // Reset lại isProcessing sau delay
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Hàm mở lại camera khi cần
  void _startCamera() {
    cameraController.start();  // Mở lại camera
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quét mã QR', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(4, 53, 109, 1),
        actions: [
          // Thêm nút để mở lại camera với chữ
          TextButton(
            onPressed: _startCamera,
            child: const Text(
              'Mở lại camera',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          Icon(Icons.camera_alt, color: Colors.white),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                MobileScanner(
                  controller: cameraController,
                  onDetect: _onDetect,
                ),
                Center(
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.black.withOpacity(0.2),
                    ),
                    child: const Center(
                      child: Icon(Icons.qr_code_scanner, color: Colors.white70, size: 50),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                color: Color.fromRGBO(245, 247, 250, 1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Hướng camera vào mã QR trên vé của hành khách để kiểm tra',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.qr_code, color: Colors.blue),
                        const SizedBox(width: 10),
                        Text(
                          result != null ? result!.rawValue ?? '...' : 'Chưa có mã được quét',
                          style: const TextStyle(fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

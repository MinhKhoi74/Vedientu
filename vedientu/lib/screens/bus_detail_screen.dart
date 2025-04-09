import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'edit_bus_screen.dart';

class BusDetailScreen extends StatelessWidget {
  final String busId;
  final dynamic bus;

  BusDetailScreen({
    Key? key,
    required this.busId,
    required this.bus,
  }) : super(key: key);

  final ApiService _apiService = ApiService();

  Future<void> _deleteBus(BuildContext context, String busId) async {
    final int parsedBusId = int.tryParse(busId) ?? -1;
    if (parsedBusId == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ ID không hợp lệ')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc muốn xóa xe buýt này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _apiService.deleteBusById(parsedBusId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Xóa xe buýt thành công')),
        );
        Navigator.of(context).pop(true); // Thông báo cần reload
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Xóa xe buýt thất bại')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final int busIdInt = bus['id'];
    final String licensePlate = bus['licensePlate'];
    final String model = bus['model'];
    final int capacity = bus['capacity'];
    final String route = bus['route'];
    final driver = bus['driver'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi Tiết Xe Buýt'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID xe buýt: $busIdInt', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Biển số: $licensePlate'),
            Text('Mẫu xe: $model'),
            Text('Sức chứa: $capacity'),
            Text('Tuyến đường: $route'),
            const SizedBox(height: 16),
            driver != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tài xế: ${driver['fullName']}'),
                      Text('ID Tài xế: ${driver['id']}'),
                    ],
                  )
                : const Text('❌ Chưa có tài xế'),
            const SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => EditBusScreen(busId: busIdInt),
                      ),
                    );
                    if (result == true) {
                      Navigator.of(context).pop(true); // Báo về cần reload
                    }
                  },
                  child: const Text('Chỉnh sửa'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () => _deleteBus(context, busId),
                  child: const Text('Xóa'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

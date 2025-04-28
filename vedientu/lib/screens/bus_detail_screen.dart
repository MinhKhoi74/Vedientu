import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'edit_bus_screen.dart';

class BusDetailScreen extends StatefulWidget {
  final String busId;
  final dynamic bus;

  const BusDetailScreen({
    Key? key,
    required this.busId,
    required this.bus,
  }) : super(key: key);

  @override
  State<BusDetailScreen> createState() => _BusDetailScreenState();
}

class _BusDetailScreenState extends State<BusDetailScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? assignedDriver;

  @override
  void initState() {
    super.initState();
    fetchAssignedDriver();
  }

  void fetchAssignedDriver() async {
    final data = await _apiService.getAllDrivers();
    final int currentBusId = widget.bus['id'];
    final driver = data.firstWhere(
      (d) => d['bus'] != null && d['bus']['id'] == currentBusId,
      orElse: () => null,
    );

    setState(() {
      assignedDriver = driver;
    });
  }

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
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Xóa xe buýt thất bại')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final int busIdInt = widget.bus['id'];
    final String licensePlate = widget.bus['licensePlate'];
    final String model = widget.bus['model'];
    final int capacity = widget.bus['capacity'];
    final String route = widget.bus['route'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi Tiết Xe Buýt'),
        centerTitle: true,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.directions_bus, size: 60, color: Colors.blue.shade700),
                    const SizedBox(height: 10),
                    Text(
                      'Biển số: $licensePlate',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Mẫu xe: $model',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const Divider(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.people, color: Colors.green),
                        Text('Sức chứa: $capacity'),
                        const Icon(Icons.route, color: Colors.orange),
                        Expanded(child: Text('Tuyến: $route', textAlign: TextAlign.end)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    assignedDriver != null
                    ? Container(
                        width: double.infinity, // 👈 THÊM DÒNG NÀY
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              '🧑‍✈️ Tài xế phụ trách:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Text('👤 Họ tên: ${assignedDriver!['fullName']}'),
                            Text('🆔 Mã tài xế: ${assignedDriver!['id']}'),
                          ],
                        ),
                      )
                    : const Text(
                        '❌ Xe này chưa có tài xế phụ trách',
                        style: TextStyle(color: Colors.redAccent),
                      ),                    const SizedBox(height: 20),

                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => EditBusScreen(busId: busIdInt),
                        ),
                      );
                      if (result == true) {
                        Navigator.of(context).pop(true);
                      }
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Chỉnh sửa'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _deleteBus(context, widget.busId),
                    icon: const Icon(Icons.delete),
                    label: const Text('Xóa'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

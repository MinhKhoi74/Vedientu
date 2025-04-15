import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class MyRidesScreen extends StatefulWidget {
  const MyRidesScreen({super.key});

  @override
  State<MyRidesScreen> createState() => _MyRidesScreenState();
}

class _MyRidesScreenState extends State<MyRidesScreen> {
  List<dynamic> _rides = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRides();
  }

  Future<void> _loadRides() async {
    List<dynamic> rides = await ApiService().getRideHistory(); // Gọi API lịch sử chuyến đi
    if (!mounted) return;

    setState(() {
      _rides = rides;
      _isLoading = false;
    });
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (_) {
      return 'Không xác định';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🚌 Lịch sử chuyến đi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _rides.isEmpty
              ? const Center(child: Text('Bạn chưa có chuyến đi nào.'))
              : ListView.builder(
                  itemCount: _rides.length,
                  itemBuilder: (context, index) {
                    final ride = _rides[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text('Mã chuyến đi: ${ride['id']}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tuyến: ${ride['route'] ?? 'Không rõ'}'),
                            Text('Tài xế: ${ride['driverName'] ?? 'Không rõ'}'),
                            Text('Thời gian: ${_formatDate(ride['rideTime'] ?? '')}'),
                            Text('Trạng thái: ${ride['status'] ?? 'Không rõ'}'),
                          ],
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {
                            context.push('/rides/${ride['id']}', extra: ride);
                          },
                          child: const Text('Chi tiết'),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

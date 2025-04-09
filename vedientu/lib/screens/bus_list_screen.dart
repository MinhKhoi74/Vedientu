import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'add_bus_screen.dart';
import 'bus_detail_screen.dart';
import 'package:go_router/go_router.dart';
class BusListScreen extends StatefulWidget {
  @override
  _BusListScreenState createState() => _BusListScreenState();
}

class _BusListScreenState extends State<BusListScreen> {
  final ApiService _apiService = ApiService();
  Future<List<dynamic>>? _buses;

  @override
  void initState() {
    super.initState();
    _loadBuses();
  }

  void _loadBuses() {
    setState(() {
      _buses = _apiService.getBuses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Danh sách Xe Buýt'),
      leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin-home'), // ✅ Nút quay lại trang trước
        ),),
      body: FutureBuilder<List<dynamic>>(
        future: _buses,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('❌ Lỗi tải dữ liệu'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('🚫 Không có xe buýt nào'));
          }

          final buses = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async {
              _loadBuses();
            },
            child: ListView.builder(
              itemCount: buses.length,
              itemBuilder: (context, index) {
                final bus = buses[index];
                return ListTile(
                  title: Text('Xe: ${bus['licensePlate']}'),
                  subtitle: Text('Mẫu: ${bus['model']}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BusDetailScreen(
                          busId: bus['id'].toString(),
                          bus: bus,
                        ),
                      ),
                    );

                    if (result == true) {
                      _loadBuses(); // Reload nếu có thay đổi
                    }
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => AddBusScreen()),
          );
          if (result == true) {
            _loadBuses();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

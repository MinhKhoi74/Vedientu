import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'add_bus_screen.dart';
import 'bus_detail_screen.dart';

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
      appBar: AppBar(
        title: const Text('Danh sách Xe Buýt'),
        centerTitle: true,
        elevation: 2,
      ),
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
              padding: const EdgeInsets.all(12),
              itemCount: buses.length,
              itemBuilder: (context, index) {
                final bus = buses[index];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.blue.shade100,
                      child: const Icon(Icons.directions_bus, color: Colors.blue),
                    ),
                    title: Text(
                      'Biển số: ${bus['licensePlate']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Mẫu xe: ${bus['model']}'),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
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
                        _loadBuses();
                      }
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => AddBusScreen()),
          );
          if (result == true) {
            _loadBuses();
          }
        },
        label: const Text("Thêm xe"),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

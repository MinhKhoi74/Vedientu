import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:go_router/go_router.dart';

class DriverTripListScreen extends StatefulWidget {
  const DriverTripListScreen({Key? key}) : super(key: key);

  @override
  State<DriverTripListScreen> createState() => _DriverTripListScreenState();
}

class _DriverTripListScreenState extends State<DriverTripListScreen> {
  final ApiService _apiService = ApiService();
  late Future<Map<String, dynamic>> _tripData;

  @override
  void initState() {
    super.initState();
    _tripData = _apiService.getRidesHistory(); // Trả về một Map, không còn là List
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chuyến đi của tài xế'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/driver-home'),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _tripData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không có dữ liệu.'));
          }

          final data = snapshot.data!;
          final tripDetails = data['tripDetails'] as List<dynamic>;
          final totalTrips = data['totalTrips'] ?? 0;
          final totalPassengers = data['totalPassengers'] ?? 0;


          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tổng chuyến đi: $totalTrips'),
                    Text('Tổng lượt hành khách: $totalPassengers'),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: tripDetails.length,
                  itemBuilder: (context, index) {
                    final trip = tripDetails[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.directions_bus),
                        title: Text('Tuyến: ${trip['route'] ?? 'Không xác định'}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Mã chuyến: ${trip['tripId'] ?? ''}'),
                            Text('Bắt đầu: ${trip['startTime'] ?? ''}'),
                            Text('Kết thúc: ${trip['endTime'] ?? 'Đang chạy'}'),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () {
                          context.go(
                            '/passenger-list',
                            extra: {'tripId': trip['tripId']},
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

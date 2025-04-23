import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

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
    _tripData = _apiService.getRidesHistory();
  }

  String formatTime(String? rawTime) {
    if (rawTime == null || rawTime.isEmpty) return "Không xác định";
    try {
      final dateTime = DateTime.parse(rawTime);
      return DateFormat('HH:mm dd/MM/yyyy').format(dateTime);
    } catch (_) {
      return rawTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: _tripData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                '❌ Lỗi: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('⚠️ Không có dữ liệu.'));
          }

          final data = snapshot.data!;
          final tripDetails = data['tripDetails'] as List<dynamic>;
          final totalTrips = data['totalTrips'] ?? 0;
          final totalPassengers = data['totalPassengers'] ?? 0;

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '🚌 Tổng chuyến đi: $totalTrips',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(4, 53, 109, 1),
                      ),
                    ),
                    Text(
                      '👤 Tổng hành khách: $totalPassengers',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(4, 53, 109, 1),
                      ),
                    ),
                  ],
                ),

              ),
              Expanded(
                child: ListView.builder(
                  itemCount: tripDetails.length,
                  itemBuilder: (context, index) {
                    final trip = tripDetails[index];

                    return Card(
                      margin:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: const Icon(Icons.directions_bus, color: Colors.blue),
                        ),
                        title: Text(
                          'Tuyến: ${trip['route'] ?? 'Không xác định'}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('🚍 Mã chuyến: ${trip['tripId'] ?? ''}'),
                            Text('🕓 Bắt đầu: ${formatTime(trip['startTime'])}'),
                            Text('🏁 Kết thúc: ${trip['endTime'] != null ? formatTime(trip['endTime']) : 'Đang chạy'}'),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                        onTap: () {
                          context.push('/passenger-list',
                              extra: {'tripId': trip['tripId']});
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

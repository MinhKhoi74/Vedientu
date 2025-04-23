import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:go_router/go_router.dart';

class PassengerListScreen extends StatefulWidget {
  final int tripId;

  const PassengerListScreen({Key? key, required this.tripId}) : super(key: key);

  @override
  State<PassengerListScreen> createState() => _PassengerListScreenState();
}

class _PassengerListScreenState extends State<PassengerListScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _passengerList;

  @override
  void initState() {
    super.initState();
    _passengerList = _apiService.getPassengersByTripId(widget.tripId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Text(
              'Danh sách hàng khách chuyến ${widget.tripId}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),

      body: FutureBuilder<List<dynamic>>(
        future: _passengerList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không có hành khách nào.'));
          }

          final passengers = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: passengers.length,
            itemBuilder: (context, index) {
              final passenger = passengers[index];
              final name = passenger['passengerName'] ?? 'Không có tên';
              final passengerId = passenger['passengerId'] ?? 'N/A';
              final ticketId = passenger['ticketId'] ?? 'N/A';
              final route = passenger['route'] ?? '';
              final rideTime = passenger['rideTime'] ?? 'Chưa có thông tin';
              final status = passenger['status'] ?? 'Đang xử lý';

              return Container(
                margin: const EdgeInsets.only(bottom: 12.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Mã hàng khách: $passengerId',
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text('Mã vé: $ticketId',
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(name, style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Lộ trình $route',
                                style: const TextStyle(color: Colors.grey)),
                            Text(rideTime,
                                style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                        Text(
                          status.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

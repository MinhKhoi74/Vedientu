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
        title: Text('Hành khách chuyến ${widget.tripId}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/driver-trip'),
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
            itemCount: passengers.length,
            itemBuilder: (context, index) {
              final passenger = passengers[index];

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(passenger['passengerName'] ?? 'Không có tên'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mã hành khách: ${passenger['passengerId'] ?? 'Không có'}'),
                      Text('Mã vé: ${passenger['ticketId'] ?? 'Không có'}'),
                      Text('Thời gian: ${passenger['rideTime'] ?? 'Chưa có thông tin'}'),
                    ],
                  ),
                  trailing: Text(passenger['status'] ?? 'Đang xử lý'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

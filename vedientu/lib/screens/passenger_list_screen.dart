import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:go_router/go_router.dart';

class PassengerListScreen extends StatefulWidget {
  const PassengerListScreen({Key? key}) : super(key: key);

  @override
  _PassengerListScreenState createState() => _PassengerListScreenState();
}

class _PassengerListScreenState extends State<PassengerListScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _passengerList;

  @override
  void initState() {
    super.initState();
    _passengerList = _apiService.getPassengers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Danh sách hành khách'),
      leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/driver-home'), // Quay về trang chính
        )),
      body: FutureBuilder<List<dynamic>>(
        future: _passengerList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            print('${snapshot.data}');
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
                      Text('Lộ trình: ${passenger['route'] ?? 'Không xác định'}'),
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

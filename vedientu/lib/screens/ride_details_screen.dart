import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';

class RideDetailsScreen extends StatefulWidget {
  final int rideId;
  final Map<String, dynamic>? rideData;

  const RideDetailsScreen({super.key, required this.rideId, this.rideData});

  @override
  State<RideDetailsScreen> createState() => _RideDetailsScreenState();
}

class _RideDetailsScreenState extends State<RideDetailsScreen> {
  Map<String, dynamic>? rideData;
  bool isLoading = true;
  bool hasError = false;

  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    if (widget.rideData != null) {
      rideData = widget.rideData;
      isLoading = false;
    } else {
      fetchRideDetails();
    }
  }

  Future<void> fetchRideDetails() async {
    try {
      final data = await apiService.getRideDetails(widget.rideId);
      if (data != null) {
        setState(() {
          rideData = data;
          print('Ride data: $rideData');
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  String _formatDate(String rawDate) {
    try {
      final date = DateTime.parse(rawDate);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (_) {
      return 'Không hợp lệ';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (hasError || rideData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết chuyến đi')),
        body: const Center(child: Text('⚠️ Không tìm thấy thông tin chuyến đi')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết chuyến đi')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🚌 Mã chuyến đi: ${rideData?['id'] ?? 'Không rõ'}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('👨‍✈️ Tên khách hàng: ${rideData?['userName'] ?? 'Không rõ'}'),
            Text('🚍 Biển số xe buýt: ${rideData?['busCode'] ?? 'Không rõ'}'),
            Text('🚍 Mã xe buýt: ${rideData?['busId'] ?? 'Không rõ'}'),
            Text('🛣️ Tuyến: ${rideData?['route'] ?? 'Không rõ'}'),
            Text('👨‍✈️ Tài xế: ${rideData?['driverName'] ?? 'Không rõ'}'),
            Text('🕒 Thời gian đi: ${_formatDate(rideData?['rideTime'] ?? '')}'),
            Text('🎟️ Mã vé: ${rideData?['ticketId'] ?? 'Không rõ'}'),
            Text('📌 Trạng thái: ${rideData?['status'] ?? 'Không rõ'}'),
          ],
        ),
      ),
    );
  }
}

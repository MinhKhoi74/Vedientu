import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';

class RideDetailsScreen extends StatefulWidget {
  final int rideId;
  final Map<String, dynamic>? rideData;

  const RideDetailsScreen({
    super.key,
    required this.rideId,
    this.rideData,
  });

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
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (_) {
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

  Widget _buildLabelText(String label, String value, {Color? valueColor, bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: valueColor ?? Colors.black,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
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

    final status = rideData?['status'] ?? 'UNKNOWN';

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết chuyến đi')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                blurRadius: 6,
                color: Colors.grey.shade200,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: Ride ID and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mã chuyến đi: ${rideData?['id'] ?? 'Không rõ'}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
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
              const SizedBox(height: 4),
              Text(
                rideData?['userName'] ?? 'Không rõ',
                style: const TextStyle(color: Colors.black87),
              ),

              const SizedBox(height: 12),
              _buildLabelText('Biển số xe buýt', rideData?['busCode'] ?? 'Không rõ'),
              const SizedBox(height: 4),
              _buildLabelText('Mã xe buýt', rideData?['busId']?.toString() ?? 'Không rõ'),
              const SizedBox(height: 4),
              _buildLabelText('Tuyến', rideData?['route'] ?? 'Không rõ'),
              const SizedBox(height: 4),
              _buildLabelText('Tài xế', rideData?['driverName'] ?? 'Không rõ'),
              const SizedBox(height: 4),
              _buildLabelText('Thời gian đi', _formatDate(rideData?['rideTime'] ?? '')),
              const SizedBox(height: 4),
              _buildLabelText('Mã vé', rideData?['ticketId']?.toString() ?? 'Không rõ'),
            ],
          ),
        ),
      ),
    );
  }
}

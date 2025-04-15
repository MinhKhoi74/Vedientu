import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? reportData;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    loadReport();
  }

  Future<void> loadReport() async {
    final result = await _apiService.fetchReportSummary();
    setState(() {
      if (result != null) {
        reportData = result;
        hasError = false;
      } else {
        hasError = true;
      }
      isLoading = false;
    });
  }

  String formatCurrency(dynamic value) {
    try {
      final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
      return formatter.format(double.tryParse(value.toString()) ?? 0);
    } catch (_) {
      return 'Không hợp lệ';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📊 Báo cáo tổng quan'),
      leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin-home'), // ✅ Nút quay lại trang trước
        ),),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? const Center(child: Text('❌ Không thể tải báo cáo'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('💰 Tổng doanh thu: ${formatCurrency(reportData?["totalRevenue"])}'),
                      Text('🚌 Tổng lượt đi: ${reportData?["totalRides"] ?? 0}'),
                      Text('🎫 Vé SINGLE: ${reportData?["totalSingleTickets"] ?? 0}'),
                      Text('📆 Vé MONTHLY: ${reportData?["totalMonthlyTickets"] ?? 0}'),
                      Text('🌟 Vé VIP: ${reportData?["totalVipTickets"] ?? 0}'),
                      const Divider(),
                      Text('👥 Tổng người dùng: ${reportData?["totalUsers"] ?? 0}'),
                      Text('🧍‍♂️ Tổng khách hàng (CUSTOMER): ${reportData?["totalCustomers"] ?? 0}'),
                      Text('🚗 Tổng tài xế (DRIVER): ${reportData?["totalDrivers"] ?? 0}'),
                      Text('🛡️ Tổng quản trị viên (ADMIN): ${reportData?["totalAdmins"] ?? 0}'),
                    ],
                  ),
                ),
    );
  }
}

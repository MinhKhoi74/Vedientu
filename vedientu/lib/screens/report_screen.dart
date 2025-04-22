import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

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

  List<PieChartSectionData> buildUserPieChart() {
    final customer = reportData?["totalCustomers"] ?? 0;
    final driver = reportData?["totalDrivers"] ?? 0;
    final admin = reportData?["totalAdmins"] ?? 0;

    return [
      PieChartSectionData(
        value: customer.toDouble(),
        color: Colors.blue,
        title: '$customer',
        radius: 50,
        titleStyle: const TextStyle(color: Colors.white),
      ),
      PieChartSectionData(
        value: driver.toDouble(),
        color: Colors.pinkAccent,
        title: '$driver',
        radius: 50,
        titleStyle: const TextStyle(color: Colors.white),
      ),
      PieChartSectionData(
        value: admin.toDouble(),
        color: Colors.purple,
        title: '$admin',
        radius: 50,
        titleStyle: const TextStyle(color: Colors.white),
      ),
    ];
  }

  Widget buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        legendItem(Colors.blue, "Khách hàng"),
        const SizedBox(width: 10),
        legendItem(Colors.pinkAccent, "Tài xế"),
        const SizedBox(width: 10),
        legendItem(Colors.purple, "Quản trị viên"),
      ],
    );
  }

  Widget legendItem(Color color, String label) {
    return Row(
      children: [
        Container(width: 10, height: 10, color: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget buildTicketBarChart() {
  final single = reportData?["totalSingleTickets"] ?? 0;
  final monthly = reportData?["totalMonthlyTickets"] ?? 0;
  final vip = reportData?["totalVipTickets"] ?? 0;

  return SizedBox(
    height: 300,
    child: BarChart(
      BarChartData(
        alignment: BarChartAlignment.center,
        groupsSpace: 30,
        maxY: ([single, monthly, vip].reduce((a, b) => a > b ? a : b)).toDouble() + 5,
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: single.toDouble(),
                color: Colors.orange,
                width: 50,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
            showingTooltipIndicators: [0],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: monthly.toDouble(),
                color: Colors.green,
                width: 50,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
            showingTooltipIndicators: [0],
          ),
          BarChartGroupData(
            x: 2,
            barRods: [
              BarChartRodData(
                toY: vip.toDouble(),
                color: Colors.red,
                width: 50,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
            showingTooltipIndicators: [0],
          ),
        ],
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                switch (value.toInt()) {
                  case 0:
                    return Text('SINGLE ($single)', style: const TextStyle(fontSize: 12));
                  case 1:
                    return Text('MONTHLY ($monthly)', style: const TextStyle(fontSize: 12));
                  case 2:
                    return Text('VIP ($vip)', style: const TextStyle(fontSize: 12));
                  default:
                    return const Text('');
                }
              },
            ),
          ),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('📊 Báo cáo tổng quan'),
      centerTitle: true,),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? const Center(child: Text('❌ Không thể tải báo cáo'))
              : Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('💰 Tổng doanh thu: ${formatCurrency(reportData?["totalRevenue"])}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color.fromRGBO(4, 53, 109, 1)),),
                        Text('🚌 Tổng lượt đi: ${reportData?["totalRides"] ?? 0}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color.fromRGBO(4, 53, 109, 1)),),
                        const Divider(),

                        const SizedBox(height: 16),
                        Text(
                          '👥 Tổng người dùng: ${reportData?["totalUsers"] ?? 0}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color.fromRGBO(4, 53, 109, 1)),
                        ),

                        const SizedBox(height: 16),
                        SizedBox(
                          height: 160,
                          child: PieChart(
                            PieChartData(
                              sections: buildUserPieChart(),
                              centerSpaceRadius: 40,
                              sectionsSpace: 2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        buildLegend(),
                        const Divider(),
                        // Phần quản lý vé
                        const Text(
                          '📊 Quản lý vé theo loại',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color.fromRGBO(4, 53, 109, 1)),
                        ),
                        buildTicketBarChart(),
                      ],
                    ),
                  ),
                ),
    );
  }
}

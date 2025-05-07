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

  int _currentPage = 0;
  final PageController _pageController = PageController();

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
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return formatter.format(double.tryParse(value.toString()) ?? 0);
  }

  Widget _buildImageSlider() {
    List<String> imagePaths = [
      'images/image_1.jpg',
      'images/image_2.jpg',
      'images/image_3.jpg',
      'images/image_4.jpg',
    ];

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: imagePaths.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                        image: AssetImage(imagePaths[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                left: 12,
                top: 60,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white),
                  onPressed: _currentPage > 0
                      ? () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.ease,
                          );
                        }
                      : null,
                ),
              ),
              Positioned(
                right: 12,
                top: 60,
                child: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios_rounded,
                      color: Colors.white),
                  onPressed: _currentPage < imagePaths.length - 1
                      ? () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.ease,
                          );
                        }
                      : null,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(imagePaths.length, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 12 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == index ? Colors.teal : Colors.grey,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal, size: 22),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBox({
    required IconData icon,
    required String title,
    required int count,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        trailing: Text(
          '$count',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    final totalUsers = reportData?['totalUsers'] ?? 0;
    final totalSingleTickets = reportData?['totalSingleTickets'] ?? 0;
    final totalMonthlyTickets = reportData?['totalMonthlyTickets'] ?? 0;
    final totalVipTickets = reportData?['totalVipTickets'] ?? 0;

    return Container(
      width: double.infinity,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              const Text(
                '📊 Biểu đồ thống kê',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 250,
                width: double.infinity,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: ([
                          totalUsers,
                          totalSingleTickets,
                          totalMonthlyTickets,
                          totalVipTickets
                        ].reduce((a, b) => a > b ? a : b) *
                            1.2)
                        .toDouble(),
                    barGroups: [
                      BarChartGroupData(x: 0, barRods: [
                        BarChartRodData(
                            toY: totalUsers.toDouble(),
                            width: 22,
                            color: Colors.blue,
                          borderRadius: BorderRadius.zero,
                        )

                      ]),
                      BarChartGroupData(x: 1, barRods: [
                        BarChartRodData(
                            toY: totalSingleTickets.toDouble(),
                            width: 22,
                            color: Colors.deepOrange,
                          borderRadius: BorderRadius.zero,)
                      ]),
                      BarChartGroupData(x: 2, barRods: [
                        BarChartRodData(
                            toY: totalMonthlyTickets.toDouble(),
                            width: 22,
                            color: Colors.green,
                          borderRadius: BorderRadius.zero,)
                      ]),
                      BarChartGroupData(x: 3, barRods: [
                        BarChartRodData(
                            toY: totalVipTickets.toDouble(),
                            width: 22,
                            color: Colors.redAccent,
                          borderRadius: BorderRadius.zero,)
                      ]),
                    ],
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, _) {
                            switch (value.toInt()) {
                              case 0:
                                return const Text("Người dùng");
                              case 1:
                                return const Text("Vé Thường");
                              case 2:
                                return const Text("Vé Tháng");
                              case 3:
                                return const Text("Vé VIP");
                              default:
                                return const Text('');
                            }
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? const Center(child: Text('❌ Không thể tải báo cáo'))
              : SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Tổng doanh thu
                        Card(
                          color: Colors.teal.shade50,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                const Icon(Icons.monetization_on,
                                    color: Colors.teal, size: 40),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text("Tổng doanh thu:",
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Text(
                                        formatCurrency(
                                            reportData?["totalRevenue"]),
                                        style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.teal),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildImageSlider(),
                        const SizedBox(height: 20),
                        _buildBarChart(),
                        _buildSectionTitle("Quản lý người dùng", Icons.people),
                        _buildCategoryBox(
                          icon: Icons.people,
                          title: "Tổng người dùng",
                          count: reportData?["totalUsers"] ?? 0,
                          color: Colors.blue,
                        ),
                        _buildCategoryBox(
                          icon: Icons.directions_bus,
                          title: "Tổng lượt đi",
                          count: reportData?["totalRides"] ?? 0,
                          color: Colors.orange,
                        ),
                        _buildSectionTitle("Quản lý vé", Icons.confirmation_num),
                        _buildCategoryBox(
                          icon: Icons.confirmation_num_outlined,
                          title: "Vé Thường",
                          count: reportData?["totalSingleTickets"] ?? 0,
                          color: Colors.deepOrange,
                        ),
                        _buildCategoryBox(
                          icon: Icons.calendar_month,
                          title: "Vé Tháng",
                          count: reportData?["totalMonthlyTickets"] ?? 0,
                          color: Colors.green,
                        ),
                        _buildCategoryBox(
                          icon: Icons.star,
                          title: "Vé VIP",
                          count: reportData?["totalVipTickets"] ?? 0,
                          color: Colors.redAccent,
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}

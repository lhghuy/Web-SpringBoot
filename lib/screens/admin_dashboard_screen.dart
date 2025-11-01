import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Dashboard - Admin Panel"),
        backgroundColor: const Color(0xFF667EEA),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundImage: AssetImage("assets/avatar.png"), // đổi thành NetworkImage nếu cần
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildWelcomeSection(),
            const SizedBox(height: 20),
            _buildQuickActions(context),
            const SizedBox(height: 20),
            _buildStatsCards(),
            const SizedBox(height: 20),
            _buildRevenueChart(),
            const SizedBox(height: 20),
            _buildPopularFoodsChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Chào mừng trở lại, Admin!",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text(
                  "Hôm nay là một ngày tuyệt vời để quản lý nhà hàng của bạn. Hãy xem tổng quan hoạt động kinh doanh bên dưới.",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          const Icon(Icons.show_chart, size: 64, color: Colors.white54),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {"icon": Icons.dashboard, "label": "Dashboard"},
      {"icon": Icons.fastfood, "label": "Sản phẩm"},
      {"icon": Icons.table_bar, "label": "Bàn ăn"},
      {"icon": Icons.people, "label": "Nhân viên"},
      {"icon": Icons.receipt, "label": "Hoá đơn"},
      {"icon": Icons.bar_chart, "label": "Báo cáo"},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate:
      const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 2),
      itemCount: actions.length,
      itemBuilder: (context, i) {
        final item = actions[i];
        return InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item["icon"] as IconData,
                    color: const Color(0xFF667EEA), size: 32),
                const SizedBox(height: 8),
                Text(
                  item["label"] as String,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, color: Color(0xFF2C3E50)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsCards() {
    final stats = [
      {"label": "Doanh thu", "value": "48M", "icon": Icons.attach_money},
      {"label": "Đơn hàng", "value": "135", "icon": Icons.receipt_long},
      {"label": "Khách hàng", "value": "89", "icon": Icons.people},
      {"label": "Bàn hoạt động", "value": "24", "icon": Icons.table_bar},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.length,
      gridDelegate:
      const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.6),
      itemBuilder: (context, i) {
        final s = stats[i];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2))
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF667EEA),
                child: Icon(s["icon"] as IconData, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(s["value"] as String,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(s["label"] as String,
                      style:
                      const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildRevenueChart() {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
      ),
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              isCurved: true,
              color: const Color(0xFF667EEA),
              barWidth: 3,
              belowBarData: BarAreaData(show: true, color: const Color(0xFF667EEA).withOpacity(0.15)),
              spots: const [
                FlSpot(0, 32),
                FlSpot(1, 28),
                FlSpot(2, 35),
                FlSpot(3, 42),
                FlSpot(4, 38),
                FlSpot(5, 45),
                FlSpot(6, 48),
              ],
            ),
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  const days = ["T2", "T3", "T4", "T5", "T6", "T7", "CN"];
                  return Text(days[v.toInt() % 7]);
                },
              ),
            ),
            leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true, reservedSize: 28)),
          ),
          gridData: FlGridData(show: true, horizontalInterval: 10),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Widget _buildPopularFoodsChart() {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
      ),
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(value: 30, color: const Color(0xFF667EEA), title: "Phở Bò"),
            PieChartSectionData(value: 25, color: const Color(0xFF56AB2F), title: "Bánh Mì"),
            PieChartSectionData(value: 20, color: const Color(0xFFF093FB), title: "Cơm Tấm"),
            PieChartSectionData(value: 15, color: const Color(0xFF4FACFE), title: "Bún Chả"),
            PieChartSectionData(value: 10, color: const Color(0xFFFF9F40), title: "Khác"),
          ],
          sectionsSpace: 2,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }
}

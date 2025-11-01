import 'package:flutter/material.dart';

class EmployeeDashboardScreen extends StatelessWidget {
  const EmployeeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Dashboard - Nhân viên"),
        backgroundColor: const Color(0xFF667EEA),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Đăng xuất thành công!")),
              );
              Navigator.pop(context);
            },
          )
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
                Text("Chào mừng trở lại, Nhân viên!",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text(
                  "Hôm nay là một ngày tuyệt vời để quản lý nhà hàng của bạn.",
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
      {
        "icon": Icons.table_bar,
        "label": "Quản lý bàn",
        "color": const Color(0xFF667EEA)
      },
      {
        "icon": Icons.receipt_long,
        "label": "Hoá đơn bàn",
        "color": const Color(0xFF4FACFE)
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12),
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
                    color: item["color"] as Color, size: 32),
                const SizedBox(height: 8),
                Text(
                  item["label"] as String,
                  textAlign: TextAlign.center,
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
      {"label": "Bàn đang hoạt động", "value": "12", "icon": Icons.table_bar},
      {"label": "Món đang phục vụ", "value": "47", "icon": Icons.fastfood},
      {"label": "Đơn hoàn tất", "value": "34", "icon": Icons.check_circle},
      {"label": "Tổng doanh thu", "value": "9.8M", "icon": Icons.attach_money},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12),
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
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/report_data.dart';
import '../../services/report_service.dart';
import '../../widgets/stat_card.dart';

class AdminReportScreen extends StatefulWidget {
  const AdminReportScreen({super.key});

  @override
  State<AdminReportScreen> createState() => _AdminReportScreenState();
}

class _AdminReportScreenState extends State<AdminReportScreen> {
  String? dateFrom;
  String? dateTo;
  bool loading = false;
  ReportData? reportData;

  @override
  void initState() {
    super.initState();
    setDateRange('week');
  }

  void setDateRange(String type) {
    final today = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd');

    dateTo = formatter.format(today);
    if (type == 'today') {
      dateFrom = dateTo;
    } else if (type == 'week') {
      dateFrom = formatter.format(today.subtract(const Duration(days: 7)));
    } else if (type == 'month') {
      dateFrom = formatter.format(today.subtract(const Duration(days: 30)));
    } else if (type == 'quarter') {
      dateFrom = formatter.format(today.subtract(const Duration(days: 90)));
    }
    setState(() {});
  }

  Future<void> generateReport() async {
    if (dateFrom == null || dateTo == null) return;
    setState(() => loading = true);

    final data = await ReportService.fetchReport(dateFrom!, dateTo!);
    setState(() {
      reportData = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Báo Cáo Kinh Doanh')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // date picker + button
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: "Từ ngày",
                      hintText: dateFrom ?? "yyyy-MM-dd",
                    ),
                    readOnly: true,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2023),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() => dateFrom = DateFormat('yyyy-MM-dd').format(picked));
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: "Đến ngày",
                      hintText: dateTo ?? "yyyy-MM-dd",
                    ),
                    readOnly: true,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2023),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() => dateTo = DateFormat('yyyy-MM-dd').format(picked));
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: generateReport,
                  child: loading
                      ? const CircularProgressIndicator()
                      : const Text("Tạo Báo Cáo"),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Cards
            if (reportData != null)
              Expanded(
                child: ListView(
                  children: [
                    Row(
                      children: [
                        Expanded(child: StatCard(label: "Tổng doanh thu", value: NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(reportData!.totalSales), icon: Icons.monetization_on, color: Colors.blue)),
                        Expanded(child: StatCard(label: "Tổng đơn hàng", value: "${reportData!.totalOrders}", icon: Icons.shopping_cart, color: Colors.green)),
                        Expanded(child: StatCard(label: "Hoàn thành", value: "${reportData!.totalInvoices}", icon: Icons.check_circle, color: Colors.purple)),
                        Expanded(child: StatCard(label: "Đơn TB", value: NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(reportData!.averageOrderValue), icon: Icons.trending_up, color: Colors.orange)),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Chart
                    SizedBox(
                      height: 300,
                      child: LineChart(
                        LineChartData(
                          lineBarsData: [
                            LineChartBarData(
                              spots: reportData!.dailySales.entries
                                  .toList()
                                  .asMap()
                                  .entries
                                  .map((e) => FlSpot(e.key.toDouble(), e.value.value))
                                  .toList(),
                              isCurved: true,
                              color: Colors.blue,
                              barWidth: 3,
                              dotData: FlDotData(show: false),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

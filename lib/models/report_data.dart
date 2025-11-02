class ReportData {
  final double totalSales;
  final int totalOrders;
  final int totalInvoices;
  final double averageOrderValue;
  final Map<String, int> orderStatusBreakdown;
  final Map<String, double> dailySales;
  final Map<String, int> topSellingItems;

  ReportData({
    required this.totalSales,
    required this.totalOrders,
    required this.totalInvoices,
    required this.averageOrderValue,
    required this.orderStatusBreakdown,
    required this.dailySales,
    required this.topSellingItems,
  });

  factory ReportData.fromJson(Map<String, dynamic> json) {
    return ReportData(
      totalSales: (json['totalSales'] ?? 0).toDouble(),
      totalOrders: json['totalOrders'] ?? 0,
      totalInvoices: json['totalInvoices'] ?? 0,
      averageOrderValue: (json['averageOrderValue'] ?? 0).toDouble(),
      orderStatusBreakdown: Map<String, int>.from(json['orderStatusBreakdown'] ?? {}),
      dailySales: Map<String, double>.from(json['dailySales'] ?? {}),
      topSellingItems: Map<String, int>.from(json['topSellingItems'] ?? {}),
    );
  }
}

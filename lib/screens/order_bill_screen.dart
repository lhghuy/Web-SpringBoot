import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

/// OrderBillScreen
///
/// Cách gọi:
/// ```dart
/// Navigator.pushNamed(
///   context,
///   '/order/bill',
///   arguments: {'orderId': 'HD123'},
/// );
/// ```
///
/// API được gọi: GET /employee/tables/api/order/{orderId}/bill
/// Hỗ trợ response dạng:
/// { success: true, data: {...} } hoặc {...}
class OrderBillScreen extends StatefulWidget {
  const OrderBillScreen({super.key});

  @override
  State<OrderBillScreen> createState() => _OrderBillScreenState();
}

class _OrderBillScreenState extends State<OrderBillScreen> {
  final ApiService api = ApiService();
  bool loading = true;
  String? error;
  Map<String, dynamic>? billData;
  String? orderId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args['orderId'] != null) {
      orderId = args['orderId'].toString();
    } else {
      // Nếu dùng route dạng '/employee/tables/order/{id}/bill' thì parse từ tên route
      final name = ModalRoute.of(context)?.settings.name ?? '';
      final parts = name.split('/');
      final idx = parts.indexWhere((p) => p == 'order');
      if (idx >= 0 && idx + 1 < parts.length && parts[idx + 1].isNotEmpty) {
        orderId = parts[idx + 1];
      }
    }

    if (orderId == null) {
      setState(() {
        loading = false;
        error = 'Không tìm thấy ID hóa đơn.';
      });
    } else {
      _loadBill();
    }
  }

  Future<void> _loadBill() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final r = await api.get('/employee/tables/api/order/$orderId/bill');
      final resp = r;

      final data = (resp is Map &&
          resp.containsKey('success') &&
          resp['success'] == true &&
          resp.containsKey('data'))
          ? resp['data']
          : (resp is Map && resp.containsKey('data') ? resp['data'] : resp);

      if (data == null) throw Exception('Server không trả về dữ liệu hóa đơn.');

      setState(() {
        billData = Map<String, dynamic>.from(data as Map);
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  // Format tiền tệ
  String formatCurrency(dynamic amount) {
    try {
      if (amount == null) return '0 đ';
      num val;
      if (amount is num) {
        val = amount;
      } else {
        val = num.tryParse(amount.toString()) ?? 0;
      }
      final f = NumberFormat.currency(
          locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
      return f.format(val).replaceAll('\u00A0', ' ');
    } catch (_) {
      return '${amount ?? 0} đ';
    }
  }

  // Format thời gian
  String formatDateTime(String? iso) {
    if (iso == null) return 'N/A';
    try {
      final dt = DateTime.parse(iso);
      final df = DateFormat('dd/MM/yyyy HH:mm');
      return df.format(dt.toLocal());
    } catch (_) {
      return iso;
    }
  }

  // Header
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 22),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.receipt_long, size: 36, color: Colors.white),
          const SizedBox(height: 8),
          const Text(
            'HÓA ĐƠN THANH TOÁN',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '#${billData?['order']?['orderID'] ?? ''}',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  // Thông tin khách hàng & nhân viên
  Widget _buildCustomerInfo() {
    final order = billData?['order'] as Map<String, dynamic>?;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(10),
        border: const Border(
          left: BorderSide(width: 4, color: Color(0xFF667EEA)),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _infoRow('Khách hàng', order?['fullName'] ?? 'N/A')),
              const SizedBox(width: 12),
              Expanded(
                  child: _infoRow('Nhân viên', order?['createdBy']?['fullName'] ?? 'N/A')),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _infoRow('SĐT', order?['phone'] ?? 'N/A')),
              const SizedBox(width: 12),
              Expanded(
                child: _infoRow(
                    'Bàn', order?['table']?['tableNumber']?.toString() ?? 'N/A'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _infoRow('Thời gian', formatDateTime(order?['createdAt']?.toString())),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('Trạng thái: ',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(width: 6),
                    Chip(
                      label: Text(order?['status'] ?? 'N/A'),
                      backgroundColor: Colors.green[50],
                      labelStyle: const TextStyle(color: Colors.green),
                    )
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      children: [
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(width: 6),
        Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
      ],
    );
  }

  // Bảng món ăn
  Widget _buildItemsTable() {
    final details = List<Map<String, dynamic>>.from(
        billData?['orderDetails'] as List? ?? []);
    final total = billData?['total'] ?? 0;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          DataTable(
            headingRowColor: MaterialStateProperty.all(const Color(0xFF667EEA)),
            headingTextStyle: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
            columns: const [
              DataColumn(label: Text('Tên món')),
              DataColumn(label: Text('Số lượng'), numeric: true),
              DataColumn(label: Text('Đơn giá'), numeric: true),
              DataColumn(label: Text('Thành tiền'), numeric: true),
            ],
            rows: details.map((it) {
              final name = it['foodItem']?['name'] ?? it['name'] ?? '-';
              final qty = it['quantity'] ?? 0;
              final price = it['priceAtOrderTime'] ?? it['price'] ?? 0;
              final line = (price is num ? price : num.tryParse(price.toString()) ?? 0) *
                  (qty is num ? qty : int.tryParse(qty.toString()) ?? 0);

              return DataRow(cells: [
                DataCell(Row(children: [
                  const Icon(Icons.local_cafe, color: Colors.blue),
                  const SizedBox(width: 8),
                  Flexible(child: Text(name))
                ])),
                DataCell(Center(child: Text(qty.toString()))),
                DataCell(
                    Align(alignment: Alignment.centerRight, child: Text(formatCurrency(price)))),
                DataCell(
                    Align(alignment: Alignment.centerRight, child: Text(formatCurrency(line)))),
              ]);
            }).toList(),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: Row(
              children: [
                const Text('TỔNG TIỀN:',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                const Spacer(),
                Text(formatCurrency(total),
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<void> _onPrintPressed() async {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog( // <--- Lỗi xảy ra ở đây
        title: const Text('Test Title'),
        content: const Text('Test Content'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hóa đơn'),
        backgroundColor: const Color(0xFF667EEA),
      ),
      backgroundColor: const Color(0xFFF8F9FA),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: loading
            ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text('Đang tải hóa đơn...'),
            ],
          ),
        )
            : (error != null)
            ? Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  size: 56, color: Colors.redAccent),
              const SizedBox(height: 12),
              Text('Không thể tải hóa đơn',
                  style:
                  TextStyle(fontSize: 18, color: Colors.grey[800])),
              const SizedBox(height: 8),
              Text(error ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 16),
              ElevatedButton(
                  onPressed: _loadBill,
                  child: const Text('Thử lại')),
            ],
          ),
        )
            : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              _buildCustomerInfo(),
              const SizedBox(height: 12),
              _buildItemsTable(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _onPrintPressed,
                    icon: const Icon(Icons.print),
                    label: const Text('In hoá đơn'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF28A745)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Quay về'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[700]),
                  ),
                ],
              ),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}

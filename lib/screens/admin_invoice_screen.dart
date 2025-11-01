// lib/screens/admin_invoice_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

/// AdminInvoiceScreen
/// - Gọi API nếu chỉ có orderId: GET /admin/orders/{orderId}/bill (tuỳ backend)
/// - Hoặc truyền sẵn `invoiceData` trong arguments: {'invoice': {...}}
/// Usage:
///  Navigator.pushNamed(context, '/admin/invoice', arguments: {'orderId': 'HD123'});
///  hoặc
///  Navigator.pushNamed(context, '/admin/invoice', arguments: {'invoice': invoiceMap});
class AdminInvoiceScreen extends StatefulWidget {
  const AdminInvoiceScreen({super.key});

  @override
  State<AdminInvoiceScreen> createState() => _AdminInvoiceScreenState();
}

class _AdminInvoiceScreenState extends State<AdminInvoiceScreen> {
  final ApiService api = ApiService();

  bool loading = true;
  String? error;
  Map<String, dynamic>? invoice; // expected structure: { order: {...}, orderDetails: [...], total: 0 }

  String? orderIdFromArgs;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args['invoice'] != null) {
      invoice = Map<String, dynamic>.from(args['invoice'] as Map);
      loading = false;
      setState(() {});
    } else if (args is Map && args['orderId'] != null) {
      orderIdFromArgs = args['orderId'].toString();
      _loadInvoice(orderIdFromArgs!);
    } else {
      // try parse from route name like '/admin/orders/HD123/invoice'
      final rn = ModalRoute.of(context)?.settings.name ?? '';
      final parts = rn.split('/');
      final idx = parts.indexWhere((p) => p == 'orders');
      if (idx >= 0 && idx + 1 < parts.length) {
        orderIdFromArgs = parts[idx + 1];
        _loadInvoice(orderIdFromArgs!);
      } else {
        loading = false;
        error = 'Không có dữ liệu hóa đơn để hiển thị.';
        setState(() {});
      }
    }
  }

  Future<void> _loadInvoice(String orderId) async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final r = await api.get('/admin/orders/$orderId/bill'); // chỉnh endpoint nếu khác
      final data = r.data;
      // support { success: true, data: {...} } or raw
      final d = (data is Map && data.containsKey('success') && data.containsKey('data')) ? data['data'] : (data is Map && data.containsKey('data') ? data['data'] : data);
      invoice = Map<String, dynamic>.from(d as Map);
    } catch (e) {
      error = e.toString();
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  String fmtCurrency(dynamic amount) {
    if (amount == null) return '0 đ';
    num v;
    if (amount is num) v = amount;
    else v = num.tryParse(amount.toString()) ?? 0;
    final f = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    return f.format(v).replaceAll('\u00A0', ' ');
  }

  String fmtDateTime(String? iso) {
    if (iso == null) return 'N/A';
    try {
      final dt = DateTime.parse(iso);
      return DateFormat('dd/MM/yyyy HH:mm').format(dt);
    } catch (_) {
      return iso;
    }
  }

  Widget _buildHeader() {
    final order = invoice?['order'] as Map<String, dynamic>?;
    return Column(
      children: [
        const SizedBox(height: 12),
        Text('HÓA ĐƠN THANH TOÁN', style: Theme.of(context).textTheme.headline6?.copyWith(color: Colors.blue, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text('#${order?['orderID'] ?? ''}', style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(flex: 5, child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildCustomerInfo() {
    final order = invoice?['order'] as Map<String, dynamic>?;
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _buildInfoRow('Khách hàng', order?['fullName'] ?? 'N/A'),
            _buildInfoRow('SĐT', order?['phone'] ?? 'N/A'),
            _buildInfoRow('Bàn', order?['table']?['tableNumber'] ?? order?['table']?['tableNumber'] ?? 'N/A'),
            _buildInfoRow('Nhân viên', order?['createdBy']?['fullName'] ?? 'N/A'),
            _buildInfoRow('Thời gian', fmtDateTime(order?['createdAt']?.toString())),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsTable() {
    final items = List<Map<String, dynamic>>.from(invoice?['orderDetails'] as List? ?? []);
    final total = invoice?['total'] ?? 0;
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          // custom header row
          Container(
            color: Colors.blue,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Row(
              children: const [
                Expanded(flex: 4, child: Text('Tên món', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('Số lượng', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                Expanded(flex: 3, child: Text('Đơn giá', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
                Expanded(flex: 3, child: Text('Thành tiền', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
              ],
            ),
          ),
          ...items.map((it) {
            final name = it['food']?['name'] ?? it['foodItem']?['name'] ?? it['name'] ?? '-';
            final qty = it['quantity'] ?? it['qty'] ?? 0;
            final price = it['priceAtOrderTime'] ?? it['price'] ?? 0;
            final line = (price is num ? price : num.tryParse(price.toString()) ?? 0) * (qty is num ? qty : int.tryParse(qty.toString()) ?? 0);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Row(
                children: [
                  Expanded(flex: 4, child: Text(name)),
                  Expanded(flex: 2, child: Center(child: Text(qty.toString()))),
                  Expanded(flex: 3, child: Align(alignment: Alignment.centerRight, child: Text(fmtCurrency(price)))),
                  Expanded(flex: 3, child: Align(alignment: Alignment.centerRight, child: Text(fmtCurrency(line)))),
                ],
              ),
            );
          }).toList(),
          // total
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]),
            ),
            child: Row(
              children: [
                const Expanded(flex: 9, child: Text('TỔNG TIỀN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                Expanded(flex: 3, child: Align(alignment: Alignment.centerRight, child: Text(fmtCurrency(total), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
              ],
            ),
          ),
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
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : (error != null)
            ? Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
              const SizedBox(height: 12),
              Text('Lỗi: $error', textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: () {
                if (orderIdFromArgs != null) _loadInvoice(orderIdFromArgs!);
              }, child: const Text('Thử lại')),
            ],
          ),
        )
            : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              _buildCustomerInfo(),
              _buildItemsTable(),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Quay về'),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

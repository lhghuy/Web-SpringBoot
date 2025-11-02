import 'package:flutter/material.dart';
import 'package:teamfoode/models/order.dart';
import 'package:teamfoode/services/api_service.dart'; // Đảm bảo import ApiService
import 'package:teamfoode/services/order_service.dart';
import 'package:intl/intl.dart';

class OrderProvider with ChangeNotifier {
  final OrderService _orderService;

  OrderProvider({required OrderService orderService})
      : _orderService = orderService;

  List<Order> _orders = [];

  List<Order> get orders => _orders;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  Order? _selectedOrder;

  Order? get selectedOrder => _selectedOrder;

  List<OrderDetail> _orderDetails = [];

  List<OrderDetail> get orderDetails => _orderDetails;

  bool _showDetailsModal = false;

  bool get showDetailsModal => _showDetailsModal;

  String? _alertMessageType; // 'success' hoặc 'error'
  String? _alertMessageText;

  bool get showAlertMessage => _alertMessageText != null;

  String? get alertMessageType => _alertMessageType;

  String? get alertMessageText => _alertMessageText;

  // Lấy tất cả hóa đơn
  Future<void> loadOrders(String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _orders = await _orderService.fetchOrders(token: token);
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _showAlert('error', e.message);
    } catch (e) {
      _errorMessage = 'Lỗi không xác định: $e';
      _showAlert('error', 'Lỗi không xác định khi tải hóa đơn: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Tải chi tiết hóa đơn và hiển thị modal
  Future<void> viewOrderDetails(int orderId, String token) async {
    // Có thể thêm trạng thái loading riêng cho modal nếu cần,
    // hoặc sử dụng _isLoading chung nếu chỉ có 1 hoạt động loading lớn trên màn hình.
    // Nếu không muốn làm ảnh hưởng loading chính, không cần set _isLoading = true ở đây.
    // For now, let's assume it's a quick fetch and not block the whole screen's loading.
    // Nếu muốn hiển thị loading trong modal, bạn sẽ cần một biến trạng thái khác: _isModalLoading
    // _isLoading = true; // Không nên set _isLoading = true ở đây nếu nó dùng cho toàn bộ màn hình
    // notifyListeners();

    try {
      final data = await _orderService.fetchOrderDetails(orderId, token: token);
      _selectedOrder = data['order'];
      _orderDetails = data['orderDetails'];
      _showDetailsModal = true;
    } on ApiException catch (e) {
      _showAlert('error', e.message);
    } catch (e) {
      _showAlert('error', 'Lỗi khi tải chi tiết hóa đơn: $e');
    } finally {
      // _isLoading = false; // Tương tự, không set ở đây nếu không set ở trên
      notifyListeners(); // Chỉ cần notify để cập nhật modal
    }
  }

  void closeDetailsModal() {
    _showDetailsModal = false;
    _selectedOrder = null;
    _orderDetails = [];
    notifyListeners();
  }

  void _showAlert(String type, String text) {
    _alertMessageType = type;
    _alertMessageText = text;
    notifyListeners();
    Future.delayed(const Duration(seconds: 5), () {
      _alertMessageText = null;
      _alertMessageType = null;
      notifyListeners(); // SỬA LỖI: Thêm notifyListeners() ở đây
    });
  }

  void dismissAlert() {
    _alertMessageText = null;
    _alertMessageType = null;
    notifyListeners();
  }

  // --- Các hàm tiện ích (Helpers) ---

  // SỬA LỖI: Trả về IconData thay vì String codePoint
  IconData getStatusIcon(String? status) {
    final icons = {
      'PENDING': Icons.access_time,
      'PREPARING': Icons.settings,
      'READY': Icons.check_circle_outline,
      'SERVED': Icons.check_circle,
      'CANCELLED': Icons.cancel,
    };
    return icons[status] ??
        Icons.question_mark; // Trả về biểu tượng mặc định nếu không tìm thấy
  }

  Color getStatusColor(String? status) {
    switch (status) {
      case 'PENDING':
        return Colors.orange;
      case 'PREPARING':
        return Colors.blue;
      case 'READY':
        return Colors.teal;
      case 'SERVED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return "N/A";
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime.toLocal());
  }

  String formatCurrency(double? amount) {
    if (amount == null) return "0 đ";
    // Đảm bảo NumberFormat được import từ 'package:intl/intl.dart'
    final formatCurrency = NumberFormat.currency(
        locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    return formatCurrency.format(amount);
  }

  double calculateTotal(List<OrderDetail> orderDetails) {
    return orderDetails.fold(
        0.0, (sum, item) => sum + (item.priceAtOrderTime * item.quantity));
  }

  // Thêm các getter tính toán giống như trên web dashboard
  int get totalOrders => _orders.length;

  int get servedOrders =>
      _orders
          .where((o) => o.status == 'SERVED')
          .length;

  int get processingOrders =>
      _orders
          .where((o) => ['PENDING', 'PREPARING', 'READY'].contains(o.status))
          .length;

  double get totalRevenue => _orders.fold(0.0, (sum, o) => sum + o.total);
}
import 'package:teamfoode/services/api_service.dart';
import 'package:teamfoode/models/order.dart'; // Import models của bạn

class OrderService {
  final ApiService _apiService;

  OrderService(this._apiService);

  // Lấy danh sách tất cả hóa đơn
  Future<List<Order>> fetchOrders({required String token}) async {
    try {
      final response = await _apiService.get('/orders', token: token);
      if (response['success'] == true && response['data'] is List) {
        return (response['data'] as List)
            .map((json) => Order.fromJson(json))
            .toList();
      } else {
        throw ApiException(
            response['message'] ?? "Dữ liệu hóa đơn không hợp lệ.");
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Không thể tải danh sách hóa đơn: $e');
    }
  }

  // Lấy chi tiết một hóa đơn cụ thể
  Future<Map<String, dynamic>> fetchOrderDetails(int orderId,
      {required String token}) async {
    try {
      final response = await _apiService.get(
          '/orders/$orderId/details', token: token);
      if (response['success'] == true && response['data'] is Map) {
        final Map<String, dynamic> data = response['data'];
        final order = Order.fromJson(data['order']);
        final orderDetails = (data['orderDetails'] as List)
            .map((json) => OrderDetail.fromJson(json))
            .toList();
        return {
          'order': order,
          'orderDetails': orderDetails,
        };
      } else {
        throw ApiException(
            response['message'] ?? "Dữ liệu chi tiết hóa đơn không hợp lệ.");
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Không thể tải chi tiết hóa đơn: $e');
    }
  }

  // Lấy danh sách các trạng thái có sẵn (nếu API có hỗ trợ)
  Future<List<String>> fetchAvailableStatuses({required String token}) async {
    try {
      final response = await _apiService.get('/orders/statuses', token: token);
      if (response['success'] == true && response['data'] is List) {
        return List<String>.from(response['data']);
      } else {
        return [];
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      print('Error fetching available statuses: $e');
      return [];
    }
  }

  // Cập nhật trạng thái hóa đơn (nếu có chức năng này trên web)
  Future<Order> updateOrderStatus(int orderId, String newStatus,
      {required String token}) async {
    try {
      final response = await _apiService.put(
        '/orders/$orderId/status',
        data: {'status': newStatus},
        token: token,
      );
      if (response['success'] == true && response['data'] is Map) {
        return Order.fromJson(response['data']);
      } else {
        throw ApiException(
            response['message'] ?? "Không thể cập nhật trạng thái hóa đơn.");
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Lỗi khi cập nhật trạng thái hóa đơn: $e');
    }
  }
}
import 'package:teamfoode/services/api_service.dart'; // Đảm bảo đã có ApiService
import 'package:teamfoode/models/table_model.dart';
import 'package:teamfoode/models/table_detail.dart';
import 'package:teamfoode/models/table_order_details.dart';
import 'package:teamfoode/models/food.dart'; // Để lấy danh sách món ăn
import 'package:intl/intl.dart'; // Để định dạng tiền tệ

class EmployeeTableService {
  final ApiService _apiService;

  EmployeeTableService(this._apiService);

  // Lấy chi tiết bàn và các món đã order
  Future<TableOrderDetails> fetchTableDetails(int tableId,
      {required String token}) async {
    try {
      final response = await _apiService.get(
          '/employee/tables/$tableId', token: token);
      if (response is Map && response.containsKey(
          'table')) { // API trả về trực tiếp TableOrderDetails object
        return TableOrderDetails.fromJson(response);
      }
      throw ApiException(response['message'] ?? 'Không thể tải thông tin bàn.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Lỗi khi tải chi tiết bàn $tableId: $e');
    }
  }

  // Lấy danh sách món ăn có sẵn để thêm vào bàn
  Future<List<Food>> fetchAvailableFoodItems(int tableId,
      {required String token}) async {
    try {
      final response = await _apiService.get(
          '/employee/tables/$tableId/food-items', token: token);
      if (response is Map && response.containsKey('foodItems') &&
          response['foodItems'] is List) {
        return (response['foodItems'] as List).map((json) =>
            Food.fromJson(json)).toList();
      }
      throw ApiException(
          response['message'] ?? 'Không thể tải danh sách món ăn có sẵn.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Lỗi khi tải món ăn có sẵn: $e');
    }
  }

  // Thêm món ăn vào bàn
  Future<TableOrderDetails> addItemToTable(int tableId, int foodId,
      int quantity, {required String token}) async {
    try {
      final response = await _apiService.post(
        '/employee/tables/$tableId/add',
        data: {
          'foodItem': {'foodID': foodId}, // Gửi foodID trong foodItem object
          'quantity': quantity,
        },
        token: token,
      );
      if (response is Map && response.containsKey('table')) {
        return TableOrderDetails.fromJson(response);
      }
      throw ApiException(response['message'] ?? 'Không thể thêm món ăn.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Lỗi khi thêm món ăn vào bàn: $e');
    }
  }

  // Lấy chi tiết một món đã order
  Future<TableDetail> fetchTableDetailItem(int tableDetailId,
      {required String token}) async {
    try {
      final response = await _apiService.get(
          '/employee/tables/detail/$tableDetailId', token: token);
      if (response is Map) { // API trả về trực tiếp TableDetail object
        return TableDetail.fromJson(response);
      }
      throw ApiException(
          response['message'] ?? 'Không thể tải chi tiết món ăn đã order.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Lỗi khi tải chi tiết món ăn $tableDetailId: $e');
    }
  }

  // Cập nhật số lượng món ăn đã order
  Future<TableOrderDetails> updateTableDetailItem(int tableDetailId,
      int quantity, {required String token}) async {
    try {
      final response = await _apiService.put(
        '/employee/tables/detail/$tableDetailId',
        data: {'quantity': quantity},
        token: token,
      );
      if (response is Map && response.containsKey(
          'table')) { // API trả về lại toàn bộ chi tiết bàn sau khi update
        return TableOrderDetails.fromJson(response);
      }
      throw ApiException(
          response['message'] ?? 'Không thể cập nhật số lượng món ăn.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Lỗi khi cập nhật số lượng món ăn: $e');
    }
  }

  // Xóa món ăn đã order
  Future<TableOrderDetails> deleteTableDetailItem(int tableDetailId,
      int tableId, {required String token}) async {
    try {
      final response = await _apiService.delete(
          '/employee/tables/detail/$tableDetailId', token: token);
      // Giả định API xóa trả về object TableOrderDetails mới
      if (response is Map && response.containsKey('table')) {
        return TableOrderDetails.fromJson(response);
      }
      // Hoặc nếu chỉ trả về success, bạn có thể gọi lại fetchTableDetails
      throw ApiException(response['message'] ?? 'Không thể xóa món ăn.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Lỗi khi xóa món ăn khỏi bàn: $e');
    }
  }

  // Tiện ích định dạng tiền tệ
  String formatCurrency(dynamic amount) {
    if (amount == null) return '0 VND';
    num value;
    if (amount is num) {
      value = amount;
    } else {
      value = num.tryParse(amount.toString()) ?? 0;
    }
    final formatter = NumberFormat('#,##0', 'vi_VN'); // Ví dụ: 123.456
    return '${formatter.format(value.toInt())} VND';
  }
}
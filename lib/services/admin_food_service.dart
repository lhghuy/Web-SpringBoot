import 'package:teamfoode/services/api_service.dart'; // Đảm bảo đã có ApiService
import 'package:teamfoode/models/food.dart';
import 'package:teamfoode/models/category.dart';
import 'package:intl/intl.dart'; // Import for currency formatting

class AdminFoodService {
  final ApiService _apiService;

  AdminFoodService(this._apiService);

  // Lấy danh sách danh mục
  Future<List<Category>> fetchCategories({required String token}) async {
    try {
      final response = await _apiService.get(
          '/admin/foods/categories', token: token);
      if (response['success'] == true && response['data'] is List) {
        return (response['data'] as List)
            .map((json) => Category.fromJson(json))
            .toList();
      }
      throw ApiException(response['message'] ?? 'Không thể tải danh mục.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Lỗi khi tải danh mục: $e');
    }
  }

  // Lấy danh sách tất cả món ăn
  Future<List<Food>> fetchFoods({required String token}) async {
    try {
      final response = await _apiService.get('/admin/foods', token: token);
      if (response['success'] == true && response['data'] is List) {
        return (response['data'] as List)
            .map((json) => Food.fromJson(json))
            .toList();
      }
      throw ApiException(
          response['message'] ?? 'Không thể tải danh sách món ăn.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Lỗi khi tải danh sách món ăn: $e');
    }
  }

  // Lấy chi tiết một món ăn
  Future<Food> fetchFood(int foodId, {required String token}) async {
    try {
      final response = await _apiService.get(
          '/admin/foods/$foodId', token: token);
      if (response['success'] == true && response['data'] is Map) {
        return Food.fromJson(response['data']);
      }
      throw ApiException(
          response['message'] ?? 'Không thể tải thông tin món ăn.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Lỗi khi tải món ăn $foodId: $e');
    }
  }

  // Tạo món ăn mới
  Future<Food> createFood(Food food, {required String token}) async {
    try {
      final response = await _apiService.post(
          '/admin/foods', data: food.toJson(), token: token);
      if (response['success'] == true && response['data'] is Map) {
        return Food.fromJson(response['data']);
      }
      throw ApiException(response['message'] ?? 'Không thể tạo món ăn.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Lỗi khi tạo món ăn: $e');
    }
  }

  // Cập nhật món ăn
  Future<Food> updateFood(int foodId, Food food,
      {required String token}) async {
    try {
      final response = await _apiService.put(
          '/admin/foods/$foodId', data: food.toJson(), token: token);
      if (response['success'] == true && response['data'] is Map) {
        return Food.fromJson(response['data']);
      }
      throw ApiException(response['message'] ?? 'Không thể cập nhật món ăn.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Lỗi khi cập nhật món ăn: $e');
    }
  }

  // Xóa món ăn
  Future<void> deleteFood(int foodId, {required String token}) async {
    try {
      final response = await _apiService.delete(
          '/admin/foods/$foodId', token: token);
      if (response['success'] !=
          true) { // Backend có thể trả về success: false hoặc không có success
        throw ApiException(response['message'] ?? 'Không thể xóa món ăn.');
      }
      // Nếu success: true hoặc không có lỗi, coi như thành công
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Lỗi khi xóa món ăn: $e');
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
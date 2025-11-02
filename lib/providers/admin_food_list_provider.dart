import 'dart:async';
import 'package:flutter/material.dart';
import 'package:teamfoode/models/food.dart';
import 'package:teamfoode/services/admin_food_service.dart';
import 'package:teamfoode/services/api_service.dart'; // For ApiException

class AdminFoodListProvider with ChangeNotifier {
  final AdminFoodService _foodService;

  AdminFoodListProvider(this._foodService);

  // --- State Variables ---
  List<Food> _foods = [];
  List<Food> get foods => _foods;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _alertMessageText;
  String? get alertMessageText => _alertMessageText;

  bool get hasAlert => _alertMessageText != null; // ✅ đổi tên để tránh trùng
  bool _isSuccessAlert = false;
  bool get isSuccessAlert => _isSuccessAlert;

  // --- Business Logic ---

  Future<void> loadFoods(String token) async {
    _isLoading = true;
    _errorMessage = null;
    _alertMessageText = null;
    notifyListeners();

    try {
      _foods = await _foodService.fetchFoods(token: token);
    } on ApiException catch (e) {
      _errorMessage = e.message;
      showAlert(false, e.message);
    } catch (e) {
      _errorMessage =
      'Đã xảy ra lỗi không mong muốn khi tải danh sách món ăn: $e';
      showAlert(false, 'Lỗi không mong muốn: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteFood(int foodId, String token) async {
    try {
      await _foodService.deleteFood(foodId, token: token);
      _foods.removeWhere((food) => food.foodID == foodId);
      showAlert(true, 'Xóa sản phẩm thành công!');
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      showAlert(false, e.message);
      return false;
    } catch (e) {
      showAlert(false, 'Lỗi khi xóa sản phẩm: $e');
      return false;
    }
  }

  // Display temporary alerts
  void showAlert(bool isSuccess, String message) {
    _alertMessageText = message;
    _isSuccessAlert = isSuccess;
    notifyListeners();

    Future.delayed(const Duration(seconds: 3), () {
      _alertMessageText = null;
      notifyListeners();
    });
  }

  void dismissAlert() {
    _alertMessageText = null;
    notifyListeners();
  }

  // Helper for quantity badge color
  Color getQuantityBadgeColor(int quantity) {
    return quantity < 10 ? Colors.red.shade100 : Colors.green.shade100;
  }

  Color getQuantityBadgeTextColor(int quantity) {
    return quantity < 10 ? Colors.red.shade700 : Colors.green.shade700;
  }

  // Helper for category badge color
  Color getCategoryBadgeColor() => Colors.blue.shade100;
  Color getCategoryBadgeTextColor() => Colors.blue.shade700;

  String formatPrice(dynamic price) {
    return _foodService.formatCurrency(price);
  }
}

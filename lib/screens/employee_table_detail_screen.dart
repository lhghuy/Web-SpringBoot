import 'dart:async';
import 'package:flutter/material.dart';
import 'package:teamfoode/models/table_order_details.dart';
import 'package:teamfoode/models/food.dart';
import 'package:teamfoode/models/table_detail.dart';
import 'package:teamfoode/services/employee_table_service.dart';
import 'package:teamfoode/services/api_service.dart'; // For ApiException

class EmployeeTableDetailProvider with ChangeNotifier {
  final EmployeeTableService _tableService;

  EmployeeTableDetailProvider(this._tableService);

  // --- State Variables ---
  TableOrderDetails? _tableOrderDetails;

  TableOrderDetails? get tableOrderDetails => _tableOrderDetails;

  List<Food> _availableFoodItems = [];

  List<Food> get availableFoodItems => _availableFoodItems;

  bool _isLoading = true;

  bool get isLoading => _isLoading;

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  String? _successMessage;

  String? get successMessage => _successMessage;

  bool _showAddModal = false;

  bool get showAddModal => _showAddModal;

  bool _showEditModal = false;

  bool get showEditModal => _showEditModal;

  bool _submittingAdd = false;

  bool get submittingAdd => _submittingAdd;

  bool _submittingEdit = false;

  bool get submittingEdit => _submittingEdit;

  // Add Form fields
  int? _addFoodItemId;

  int? get addFoodItemId => _addFoodItemId;
  int _addQuantity = 1;

  int get addQuantity => _addQuantity;
  String? _addFormError;

  String? get addFormError => _addFormError;

  // Edit Form fields
  int? _editDetailId;

  int? get editDetailId => _editDetailId;
  String? _editFoodItemName;

  String? get editFoodItemName => _editFoodItemName;
  int _editQuantity = 1;

  int get editQuantity => _editQuantity;
  String? _editFormError;

  String? get editFormError => _editFormError;

  // --- Business Logic ---

  Future<void> loadTableDetails(int tableId, String token) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      _tableOrderDetails =
      await _tableService.fetchTableDetails(tableId, token: token);
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Lỗi không mong muốn khi tải chi tiết bàn: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadAvailableFoodItems(int tableId, String token) async {
    try {
      _availableFoodItems =
      await _tableService.fetchAvailableFoodItems(tableId, token: token);
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Không thể tải danh sách món ăn có sẵn.';
    }
  }

  // --- Add Item Modal Logic ---
  Future<void> openAddItemModal(int tableId, String token) async {
    _showAddModal = true;
    _addFoodItemId = null;
    _addQuantity = 1;
    _addFormError = null;
    notifyListeners();
    await _loadAvailableFoodItems(
        tableId, token); // Load items when modal opens
  }

  void closeAddItemModal() {
    _showAddModal = false;
    _submittingAdd = false; // Reset submitting state
    _addFormError = null; // Clear error on close
    notifyListeners();
  }

  void updateAddForm({int? foodItemId, int? quantity}) {
    if (foodItemId != null) _addFoodItemId = foodItemId;
    if (quantity != null) _addQuantity = quantity;
    _addFormError = null; // Clear error on input change
    notifyListeners();
  }

  Future<void> addItem(int tableId, String token) async {
    if (_submittingAdd) return;

    _submittingAdd = true;
    _addFormError = null;
    notifyListeners();

    if (_addFoodItemId == null) {
      _addFormError = 'Vui lòng chọn món ăn.';
      _submittingAdd = false;
      notifyListeners();
      return;
    }
    if (_addQuantity <= 0) {
      _addFormError = 'Số lượng phải lớn hơn 0.';
      _submittingAdd = false;
      notifyListeners();
      return;
    }

    try {
      _tableOrderDetails = await _tableService.addItemToTable(
        tableId,
        _addFoodItemId!,
        _addQuantity,
        token: token,
      );
      _successMessage = 'Thêm món thành công!';
      closeAddItemModal();
      _startSuccessMessageTimer();
    } on ApiException catch (e) {
      _addFormError = e.message;
    } catch (e) {
      _addFormError = 'Không thể thêm món. Vui lòng thử lại.';
    } finally {
      _submittingAdd = false;
      notifyListeners();
    }
  }

  // --- Edit Item Modal Logic ---
  Future<void> openEditItemModal(int tableDetailId, String token) async {
    _showEditModal = true;
    _editDetailId = tableDetailId;
    _editFormError = null;
    notifyListeners();

    try {
      final detail = await _tableService.fetchTableDetailItem(
          tableDetailId, token: token);
      _editFoodItemName = detail.foodItem.name;
      _editQuantity = detail.quantity;
    } on ApiException catch (e) {
      _errorMessage = e.message; // Use main error for fetch issues
      closeEditItemModal();
    } catch (e) {
      _errorMessage = 'Không thể tải thông tin món ăn để sửa.';
      closeEditItemModal();
    } finally {
      notifyListeners();
    }
  }

  void closeEditItemModal() {
    _showEditModal = false;
    _submittingEdit = false; // Reset submitting state
    _editFormError = null; // Clear error on close
    notifyListeners();
  }

  void updateEditForm({int? quantity}) {
    if (quantity != null) _editQuantity = quantity;
    _editFormError = null; // Clear error on input change
    notifyListeners();
  }

  Future<void> updateItem(int tableId, String token) async {
    if (_submittingEdit) return;

    _submittingEdit = true;
    _editFormError = null;
    notifyListeners();

    if (_editQuantity <= 0) {
      _editFormError = 'Số lượng phải lớn hơn 0.';
      _submittingEdit = false;
      notifyListeners();
      return;
    }

    try {
      _tableOrderDetails = await _tableService.updateTableDetailItem(
        _editDetailId!,
        _editQuantity,
        token: token,
      );
      _successMessage = 'Cập nhật số lượng thành công!';
      closeEditItemModal();
      _startSuccessMessageTimer();
    } on ApiException catch (e) {
      _editFormError = e.message;
    } catch (e) {
      _editFormError = 'Không thể cập nhật món. Vui lòng thử lại.';
    } finally {
      _submittingEdit = false;
      notifyListeners();
    }
  }

  // --- Delete Item Logic ---
  Future<void> deleteItem(int tableDetailId, int tableId, String token) async {
    _successMessage = null; // Clear any existing success messages
    _errorMessage = null; // Clear any existing action errors
    notifyListeners();

    try {
      _tableOrderDetails = await _tableService.deleteTableDetailItem(
          tableDetailId, tableId, token: token);
      _successMessage = 'Xóa món thành công!';
      _startSuccessMessageTimer();
    } on ApiException catch (e) {
      _errorMessage = e.message;
      dismissErrorMessage(); // Call the public dismiss method
    } catch (e) {
      _errorMessage = 'Không thể xóa món. Vui lòng thử lại.';
      dismissErrorMessage(); // Call the public dismiss method
    } finally {
      notifyListeners();
    }
  }


  // --- Helper Methods ---
  String formatCurrency(dynamic amount) {
    return _tableService.formatCurrency(amount);
  }

  String getTableStatusText(String status) {
    return status == 'Trong' ? 'Trống' : 'Đang phục vụ';
  }

  IconData getTableStatusIcon(String status) {
    return status == 'Trong' ? Icons.check_circle : Icons.people;
  }

  Color getTableStatusColor(String status) {
    return status == 'Trong' ? Colors.green : Colors.red;
  }

  // SỬA LỖI: Đổi tên và làm public
  void dismissSuccessMessage() {
    _successMessage = null;
    notifyListeners();
  }

  // SỬA LỖI: Đổi tên và làm public
  void dismissErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }

  // Private timers (called internally)
  void _startSuccessMessageTimer() {
    Future.delayed(const Duration(seconds: 3), () {
      dismissSuccessMessage(); // Call the public dismiss method
    });
  }

  void _startErrorMessageTimer() {
    Future.delayed(const Duration(seconds: 5), () {
      dismissErrorMessage(); // Call the public dismiss method
    });
  }
}
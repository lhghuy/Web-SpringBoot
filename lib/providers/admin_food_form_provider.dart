import 'dart:async'; // For Completer
import 'dart:convert'; // For jsonDecode

import 'package:flutter/material.dart';
import 'package:teamfoode/models/food.dart';
import 'package:teamfoode/models/category.dart';
import 'package:teamfoode/services/admin_food_service.dart';
import 'package:teamfoode/services/api_service.dart'; // For ApiException

class AdminFoodFormProvider with ChangeNotifier {
  final AdminFoodService _foodService;

  AdminFoodFormProvider(this._foodService);

  // --- State Variables ---
  bool _isLoading = true;

  bool get isLoading => _isLoading;

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  bool _submitting = false;

  bool get submitting => _submitting;

  bool _isEditMode = false;

  bool get isEditMode => _isEditMode;

  int? _foodId;

  int? get foodId => _foodId;

  List<Category> _categories = [];

  List<Category> get categories => _categories;

  Food _formData = Food(
    name: '',
    price: 0.0,
    quantity: 1,
    category: Category(
        categoryID: -1, name: ''), // Placeholder cho "Chọn danh mục"
  );

  Food get formData => _formData;

  Map<String, String> _validationErrors = {};

  Map<String, String> get validationErrors => _validationErrors;

  String? _alertMessageText;

  String? get alertMessageText => _alertMessageText;

  bool get showAlert => _alertMessageText != null;
  bool _isSuccessAlert = false;

  bool get isSuccessAlert => _isSuccessAlert;

  bool _imageUrlValid = false;

  bool get imageUrlValid => _imageUrlValid;

  // --- Business Logic ---

  Future<void> loadInitialData(int? foodIdToEdit, String token) async {
    _isLoading = true;
    _errorMessage = null;
    _isEditMode = foodIdToEdit != null;
    _foodId = foodIdToEdit;
    _validationErrors = {}; // Clear errors on load
    notifyListeners();

    try {
      _categories = await _foodService.fetchCategories(token: token);

      if (_isEditMode && _foodId != null) {
        final food = await _foodService.fetchFood(_foodId!, token: token);
        _formData = food;
        if (_formData.anh != null && _formData.anh!.isNotEmpty) {
          await _validateImageUrl(_formData.anh!); // Wait for image validation
        }
      } else {
        // Set a default valid category if adding new and categories are available
        if (_categories.isNotEmpty) {
          _formData = _formData.copyWith(category: _categories.first);
        }
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Đã xảy ra lỗi không mong muốn khi tải dữ liệu: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cập nhật dữ liệu form khi người dùng nhập/chọn
  void updateFormData({
    String? name,
    String? description,
    double? price,
    String? anh,
    int? quantity,
    int? categoryId // Dùng categoryId để tìm Category object
  }) {
    Category? selectedCategoryObject;
    if (categoryId != null) {
      selectedCategoryObject = _categories.firstWhere(
            (cat) => cat.categoryID == categoryId,
        orElse: () => _formData.category, // Fallback to current or default
      );
    }

    _formData = _formData.copyWith(
      name: name,
      description: description,
      price: price,
      anh: anh,
      quantity: quantity,
      category: selectedCategoryObject,
    );

    if (anh != null) {
      _validateImageUrl(anh);
    }
    notifyListeners();
  }

  // Client-side image URL validation (async)
  Future<void> _validateImageUrl(String url) async {
    if (url.isEmpty) {
      _imageUrlValid = false;
      notifyListeners();
      return;
    }
    try {
      final completer = Completer<ImageInfo>();
      final image = Image.network(url);
      image.image.resolve(const ImageConfiguration()).addListener(
        ImageStreamListener(
              (info, _) {
            completer.complete(info);
            _imageUrlValid = true;
            notifyListeners();
          },
          onError: (dynamic exception, StackTrace? stackTrace) {
            completer.completeError(exception ?? 'Image loading failed');
            _imageUrlValid = false;
            notifyListeners();
          },
        ),
      );
      await completer.future; // Wait for image to load or fail
    } catch (e) {
      _imageUrlValid = false;
      notifyListeners();
    }
  }

  // Gửi form
  Future<bool> submitForm(String token) async {
    if (_submitting) return false;

    _submitting = true;
    _validationErrors = {};
    _alertMessageText = null;
    notifyListeners();

    // Client-side validation before sending to API
    if (!_validateFormInputs()) {
      _submitting = false;
      notifyListeners();
      _showAlert(false, 'Vui lòng kiểm tra lại các trường bị lỗi.');
      return false;
    }

    try {
      if (_isEditMode && _foodId != null) {
        await _foodService.updateFood(_foodId!, _formData, token: token);
      } else {
        await _foodService.createFood(_formData, token: token);
      }
      _showAlert(true, 'Sản phẩm đã được ${_isEditMode
          ? 'cập nhật'
          : 'thêm mới'} thành công!');
      return true;
    } on ApiException catch (e) {
      _handleApiErrors(e);
      return false;
    } catch (e) {
      _showAlert(false, 'Đã xảy ra lỗi không mong muốn: $e');
      return false;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  bool _validateFormInputs() {
    bool isValid = true;
    if (_formData.name
        .trim()
        .isEmpty) {
      _validationErrors['name'] = 'Tên sản phẩm không được trống.';
      isValid = false;
    }
    if (_formData.category.categoryID ==
        -1) { // -1 is our placeholder for "Choose category"
      _validationErrors['categoryId'] = 'Vui lòng chọn danh mục.';
      isValid = false;
    }
    if (_formData.price <= 0) {
      _validationErrors['price'] = 'Giá phải lớn hơn 0.';
      isValid = false;
    }
    if (_formData.quantity <= 0) {
      _validationErrors['quantity'] = 'Số lượng phải lớn hơn 0.';
      isValid = false;
    }
    // Add more client-side validation as needed (e.g., URL format for _formData.anh)

    return isValid;
  }

  void _handleApiErrors(ApiException e) {
    // Attempt to parse validation errors from API message if it's JSON
    if (e.message.contains('{') && e.message.contains('}')) {
      try {
        final errorMap = jsonDecode(e.message) as Map<String, dynamic>;
        // This part depends heavily on your backend's exact error structure
        // Assuming your backend sends field-specific errors in an 'errors' map or list
        if (errorMap.containsKey('errors') && errorMap['errors'] is Map) {
          (errorMap['errors'] as Map).forEach((key, value) {
            _validationErrors[key.toString()] =
            (value is List) ? value.join(', ') : value.toString();
          });
          _showAlert(false, 'Vui lòng kiểm tra các lỗi trên form.');
        } else {
          _showAlert(false, errorMap['message'] ?? 'Có lỗi xảy ra từ server.');
        }
      } catch (_) {
        _showAlert(false, e.message); // Fallback if JSON parsing fails
      }
    } else {
      _showAlert(false, e.message); // Use raw message if not JSON
    }
  }

  // Display temporary alerts
  void _showAlert(bool isSuccess, String message) {
    _alertMessageText = message;
    _isSuccessAlert = isSuccess;
    notifyListeners();
    Future.delayed(const Duration(seconds: 3), () {
      _alertMessageText = null;
      notifyListeners();
    });
  }

  // Clear a displayed alert manually
  void dismissAlert() {
    _alertMessageText = null;
    notifyListeners();
  }
}
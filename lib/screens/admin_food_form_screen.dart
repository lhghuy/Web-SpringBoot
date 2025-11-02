import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/admin_food_service.dart';
import '../services/api_service.dart';
import '../models/food.dart';
import '../models/category.dart';

/// ---------------------------
/// MODEL PHỤ TRỢ
/// ---------------------------
class FoodFormData {
  final String name;
  final Category? category;
  final double price;
  final int quantity;

  FoodFormData({
    required this.name,
    required this.category,
    required this.price,
    required this.quantity,
  });

  FoodFormData copyWith({
    String? name,
    Category? category,
    double? price,
    int? quantity,
  }) {
    return FoodFormData(
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
    );
  }
}

/// ---------------------------
/// PROVIDER
/// ---------------------------
class AdminFoodFormProvider extends ChangeNotifier {
  final AdminFoodService _service;
  final String token;
  final int? foodId;

  AdminFoodFormProvider(this._service, this.token, {this.foodId});

  bool isLoading = true;
  bool isSubmitting = false;
  bool isSuccessAlert = false;
  String? alertMessageText;

  List<Category> categories = [];
  FoodFormData formData = FoodFormData(
    name: '',
    category: null,
    price: 0,
    quantity: 0,
  );

  Future<void> initForm() async {
    try {
      isLoading = true;
      notifyListeners();

      categories = await _service.fetchCategories(token: token);

      if (foodId != null) {
        final existing = await _service.fetchFood(foodId!, token: token);
        formData = FoodFormData(
          name: existing.name,
          category: categories.firstWhere(
                (c) => c.categoryID == existing.category.categoryID,
            orElse: () => categories.first,
          ),
          price: existing.price,
          quantity: existing.quantity,
        );
      }
    } catch (e) {
      showAlert(false, 'Không thể tải dữ liệu: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void updateName(String value) {
    formData = formData.copyWith(name: value);
    notifyListeners();
  }

  void updateCategory(Category? selected) {
    formData = formData.copyWith(category: selected);
    notifyListeners();
  }

  void updatePrice(String val) {
    final parsed = double.tryParse(val) ?? 0;
    formData = formData.copyWith(price: parsed);
    notifyListeners();
  }

  void updateQuantity(String val) {
    final parsed = int.tryParse(val) ?? 0;
    formData = formData.copyWith(quantity: parsed);
    notifyListeners();
  }

  Future<void> submitForm(BuildContext context) async {
    if (!_validateFormInputs()) {
      showAlert(false, 'Vui lòng điền đúng thông tin.');
      return;
    }

    try {
      isSubmitting = true;
      notifyListeners();

      final food = Food(
        foodID: foodId,
        name: formData.name,
        category: formData.category!,
        price: formData.price,
        quantity: formData.quantity,
      );

      if (foodId == null) {
        await _service.createFood(food, token: token);
        showAlert(true, 'Thêm món ăn thành công!');
      } else {
        await _service.updateFood(foodId!, food, token: token);
        showAlert(true, 'Cập nhật món ăn thành công!');
      }
    } catch (e) {
      showAlert(false, 'Lỗi khi lưu: $e');
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  bool _validateFormInputs() {
    if (formData.name.trim().isEmpty) return false;
    if (formData.category == null) return false;
    if (formData.price <= 0) return false;
    if (formData.quantity <= 0) return false;
    return true;
  }

  void showAlert(bool success, String msg) {
    isSuccessAlert = success;
    alertMessageText = msg;
    notifyListeners();
  }

  void dismissAlert() {
    alertMessageText = null;
    notifyListeners();
  }
}

/// ---------------------------
/// UI
/// ---------------------------
class AdminFoodFormScreen extends StatelessWidget {
  final String token;
  final int? foodId;

  const AdminFoodFormScreen({Key? key, required this.token, this.foodId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();
    final foodService = AdminFoodService(apiService);

    return ChangeNotifierProvider(
      create: (_) => AdminFoodFormProvider(foodService, token, foodId: foodId)..initForm(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(foodId == null ? 'Thêm món ăn' : 'Chỉnh sửa món ăn'),
        ),
        body: Consumer<AdminFoodFormProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (provider.alertMessageText != null)
                      Container(
                        color: provider.isSuccessAlert
                            ? Colors.green[100]
                            : Colors.red[100],
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text(provider.alertMessageText!)),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: provider.dismissAlert,
                            )
                          ],
                        ),
                      ),
                    TextFormField(
                      initialValue: provider.formData.name,
                      decoration: const InputDecoration(labelText: 'Tên món ăn'),
                      onChanged: provider.updateName,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<Category>(
                      value: provider.formData.category,
                      hint: const Text('Chọn danh mục'),
                      items: provider.categories.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text(cat.name),
                        );
                      }).toList(),
                      onChanged: provider.updateCategory,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: provider.formData.price.toString(),
                      decoration: const InputDecoration(labelText: 'Giá'),
                      keyboardType: TextInputType.number,
                      onChanged: provider.updatePrice,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: provider.formData.quantity.toString(),
                      decoration: const InputDecoration(labelText: 'Số lượng'),
                      keyboardType: TextInputType.number,
                      onChanged: provider.updateQuantity,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: provider.isSubmitting
                          ? null
                          : () => provider.submitForm(context),
                      icon: provider.isSubmitting
                          ? const CircularProgressIndicator()
                          : const Icon(Icons.save),
                      label: Text(provider.isSubmitting
                          ? 'Đang lưu...'
                          : 'Lưu món ăn'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

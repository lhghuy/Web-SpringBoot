import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teamfoode/models/food.dart';
import 'package:teamfoode/providers/admin_food_list_provider.dart';
import 'package:teamfoode/screens/admin_dashboard_screen.dart';
import 'package:teamfoode/screens/admin_food_form_screen.dart';

class AdminFoodsListScreen extends StatefulWidget {
  const AdminFoodsListScreen({Key? key}) : super(key: key);

  @override
  State<AdminFoodsListScreen> createState() => _AdminFoodsListScreenState();
}

class _AdminFoodsListScreenState extends State<AdminFoodsListScreen> {
  String? _userToken;

  @override
  void initState() {
    super.initState();
    _loadUserTokenAndFoods();
  }

  Future<void> _loadUserTokenAndFoods() async {
    final prefs = await SharedPreferences.getInstance();
    _userToken = prefs.getString('auth_token');

    if (_userToken == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không tìm thấy token. Vui lòng đăng nhập lại.'),
        ),
      );
      return;
    }

    Provider.of<AdminFoodListProvider>(context, listen: false)
        .loadFoods(_userToken!);
  }

  Future<void> _refreshFoods() async {
    if (_userToken != null) {
      await Provider.of<AdminFoodListProvider>(context, listen: false)
          .loadFoods(_userToken!);
    }
  }

  Future<void> _confirmDelete(
      BuildContext context, Food food, AdminFoodListProvider provider) async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content:
          Text('Bạn có chắc chắn muốn xóa sản phẩm "${food.name}"?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style:
              ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );

    if (confirm == true && _userToken != null) {
      await provider.deleteFood(food.foodID!, _userToken!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminFoodListProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFecf0f1),
          appBar: AppBar(
            title: const Text(
              'Quản Lý Sản Phẩm',
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
            backgroundColor: const Color(0xFF2c3e50),
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: provider.isLoading ? null : _refreshFoods,
              ),
            ],
          ),
          drawer: _buildAdminDrawer(context),
          body: Column(
            children: [
              if (provider.hasAlert)
                _buildAlert(provider.isSuccessAlert, provider.alertMessageText!,
                    provider.dismissAlert),
              Expanded(
                child: Card(
                  margin: const EdgeInsets.all(16.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  elevation: 4,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Danh sách sản phẩm',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2c3e50),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () async {
                                final result = await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => AdminFoodFormScreen(
                                      token: _userToken!,
                                    ),
                                  ),
                                );
                                if (result == true) _refreshFoods();
                              },
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Thêm món ăn mới'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF667eea),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      if (provider.isLoading)
                        const Expanded(child: _LoadingView())
                      else if (provider.errorMessage != null)
                        Expanded(
                            child: _ErrorView(
                                error: provider.errorMessage!,
                                onRetry: _refreshFoods))
                      else if (provider.foods.isEmpty)
                          Expanded(
                            child: _EmptyStateView(
                              onAddFood: () async {
                                final result = await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => AdminFoodFormScreen(
                                      token: _userToken!,
                                    ),
                                  ),
                                );
                                if (result == true) _refreshFoods();
                              },
                            ),
                          )
                        else
                          Expanded(
                            child: ListView.builder(
                              itemCount: provider.foods.length,
                              itemBuilder: (context, index) {
                                final food = provider.foods[index];
                                return _buildFoodListItem(
                                    context, food, provider);
                              },
                            ),
                          ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAdminDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFF2c3e50),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF2c3e50)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.shield_rounded, color: Colors.white, size: 48),
                  SizedBox(height: 8),
                  Text(
                    'ADMIN',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(context, Icons.dashboard, 'Dashboard', () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => const AdminDashboardScreen()));
            }),
            _buildDrawerItem(context, Icons.fastfood, 'Quản lý sản phẩm', () {
              Navigator.pop(context);
            }, isActive: true),
            _buildDrawerItem(context, Icons.logout, 'Đăng xuất', () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('auth_token');
              // TODO: Navigate to login
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title,
      VoidCallback onTap,
      {bool isActive = false}) {
    return ListTile(
      leading: Icon(icon, color: isActive ? Colors.yellow : Colors.white),
      title: Text(
        title,
        style: TextStyle(
          color: isActive ? Colors.yellow : Colors.white,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: onTap,
      tileColor: isActive ? Colors.white.withOpacity(0.1) : null,
    );
  }

  Widget _buildAlert(bool isSuccess, String message, VoidCallback onDismiss) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSuccess
            ? Colors.green.withOpacity(0.08)
            : Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color:
            isSuccess ? Colors.green.shade700 : Colors.red.shade700,
            width: 4,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isSuccess ? Icons.check_circle : Icons.error_outline,
            color: isSuccess ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                  color: isSuccess ? Colors.green : Colors.red),
            ),
          ),
          IconButton(icon: const Icon(Icons.close), onPressed: onDismiss),
        ],
      ),
    );
  }

  Widget _buildFoodListItem(
      BuildContext context, Food food, AdminFoodListProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: food.anh != null && food.anh!.isNotEmpty
                  ? Image.network(
                food.anh!,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              )
                  : Container(
                width: 80,
                height: 80,
                color: Colors.grey.shade200,
                child: const Icon(Icons.fastfood,
                    size: 40, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    food.description ?? 'Không có mô tả',
                    style: TextStyle(
                        color: Colors.grey.shade700, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    children: [
                      _buildBadge(provider.formatPrice(food.price),
                          Colors.green.shade100, Colors.green.shade700),
                      _buildBadge(
                          'SL: ${food.quantity}',
                          provider.getQuantityBadgeColor(food.quantity),
                          provider.getQuantityBadgeTextColor(food.quantity)),
                      _buildBadge(
                          food.category.name,
                          provider.getCategoryBadgeColor(),
                          provider.getCategoryBadgeTextColor()),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue.shade700),
                  onPressed: () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AdminFoodFormScreen(
                          foodId: food.foodID,
                          token: _userToken!,
                        ),
                      ),
                    );
                    if (result == true) _refreshFoods();
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red.shade700),
                  onPressed: () => _confirmDelete(context, food, provider),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration:
      BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        text,
        style: TextStyle(color: fg, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Đang tải danh sách sản phẩm...'),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text('Lỗi: $error'),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onRetry, child: const Text('Thử lại')),
          ],
        ),
      ),
    );
  }
}

class _EmptyStateView extends StatelessWidget {
  final VoidCallback? onAddFood;

  const _EmptyStateView({this.onAddFood});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fastfood, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 24),
            Text('Chưa có sản phẩm nào',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: Colors.grey.shade700)),
            const SizedBox(height: 8),
            Text(
              'Nhấn "Thêm món ăn mới" để tạo sản phẩm đầu tiên.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            if (onAddFood != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAddFood,
                icon: const Icon(Icons.add),
                label: const Text('Thêm món ăn mới'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667eea),
                  foregroundColor: Colors.white,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

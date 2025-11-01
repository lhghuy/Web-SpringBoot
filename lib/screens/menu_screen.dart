import 'package:flutter/material.dart';
import '../services/api_service.dart';

/// MenuScreen
/// - Gọi API: GET /client/foods và GET /client/foods/categories
/// - Hiển thị danh sách categories (chips) + grid món ăn
/// - Loading / Error / Retry
class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final ApiService api = ApiService();

  bool loading = true;
  String? error;
  List<Map<String, dynamic>> allFoods = [];
  List<Map<String, dynamic>> categories = [];
  dynamic selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _loadMenuData();
  }

  Future<void> _loadMenuData() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      // parallel requests
      final responses = await Future.wait([
        api.get('/client/foods'),
        api.get('/client/foods/categories'),
      ]);

      final foodsResp = responses[0];
      final catsResp = responses[1];

      // defensive parsing:
      final foodsData = _extractDataFromResponse(foodsResp.data);
      final catsData = _extractDataFromResponse(catsResp.data);

      // Normalize to List<Map<String,dynamic>>
      allFoods = (foodsData is List) ? List<Map<String, dynamic>>.from(foodsData.map((e) => Map<String, dynamic>.from(e as Map))) : [];
      categories = (catsData is List) ? List<Map<String, dynamic>>.from(catsData.map((e) => Map<String, dynamic>.from(e as Map))) : [];

      // if categories empty, keep default 'all'
      if (categories.isEmpty) {
        selectedCategory = 'all';
      } else {
        // ensure selectedCategory remains valid
        if (selectedCategory != 'all' && !categories.any((c) => c['categoryID'] == selectedCategory)) {
          selectedCategory = 'all';
        }
      }
    } catch (e) {
      error = _extractErrorMessage(e);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  /// The backend sometimes wraps { success: true, data: [...] } or returns raw list.
  dynamic _extractDataFromResponse(dynamic respData) {
    try {
      if (respData == null) return [];
      if (respData is Map && respData.containsKey('success') && respData.containsKey('data')) {
        return respData['data'];
      }
      if (respData is Map && respData.containsKey('data')) return respData['data'];
      return respData;
    } catch (_) {
      return [];
    }
  }

  String _extractErrorMessage(Object err) {
    try {
      final s = err.toString();
      return s;
    } catch (_) {
      return 'Lỗi kết nối. Vui lòng thử lại.';
    }
  }

  void _selectCategory(dynamic id) {
    setState(() {
      selectedCategory = id;
    });
    // optionally scroll to top
    // ScrollController could be used if desired
  }

  List<Map<String, dynamic>> _foodsForSelectedCategory() {
    if (selectedCategory == 'all') return allFoods;
    return allFoods.where((food) {
      final cat = food['category'];
      if (cat == null) return false;
      final catId = cat['categoryID'] ?? cat['id'] ?? cat['categoryId'];
      return catId == selectedCategory;
    }).toList();
  }

  String formatCurrency(dynamic amount) {
    if (amount == null) return '0 VND';
    // amount might be string or number
    num value;
    if (amount is num) {
      value = amount;
    } else {
      value = num.tryParse(amount.toString()) ?? 0;
    }
    final s = value.toInt().toString();
    final reg = RegExp(r'\B(?=(\d{3})+(?!\d))');
    final withCommas = s.replaceAllMapped(reg, (m) => ',${m.group(0)}');
    return '$withCommas VND';
  }

  @override
  Widget build(BuildContext context) {
    final foods = _foodsForSelectedCategory();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Nhà Hàng'),
        backgroundColor: const Color(0xFF667EEA),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: loading ? null : _loadMenuData,
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: loading
          ? const _LoadingView()
          : (error != null)
          ? _ErrorView(error: error!, onRetry: _loadMenuData)
          : Column(
        children: [
          // Category chips (horizontal)
          SizedBox(
            height: 72,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              scrollDirection: Axis.horizontal,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: ChoiceChip(
                    label: const Text('Tất cả'),
                    selected: selectedCategory == 'all',
                    onSelected: (_) => _selectCategory('all'),
                    selectedColor: const Color(0xFF667EEA),
                    labelStyle: TextStyle(color: selectedCategory == 'all' ? Colors.white : Colors.black87),
                  ),
                ),
                ...categories.map((c) {
                  final id = c['categoryID'] ?? c['id'] ?? c['categoryId'];
                  final name = c['name'] ?? c['categoryName'] ?? 'Danh mục';
                  final isSelected = id == selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: ChoiceChip(
                      label: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
                      selected: isSelected,
                      onSelected: (_) => _selectCategory(id),
                      selectedColor: const Color(0xFF667EEA),
                      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),

          // Content
          Expanded(
            child: foods.isEmpty
                ? Center(
              child: Text(
                'Không có món ăn trong mục này',
                style: TextStyle(color: Colors.grey[700]),
              ),
            )
                : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: GridView.builder(
                padding: const EdgeInsets.only(bottom: 12, top: 6),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: foods.length,
                itemBuilder: (context, i) {
                  final f = foods[i];
                  final imageUrl = f['anh'] ?? f['image'] ?? f['imageUrl'] ?? '';
                  final name = f['name'] ?? f['foodName'] ?? '-';
                  final price = f['price'] ?? f['gia'] ?? 0;
                  return _FoodCard(
                    imageUrl: imageUrl,
                    name: name,
                    priceText: formatCurrency(price),
                    onTap: () {
                      // Navigate to detail screen if exists
                      // Navigator.pushNamed(context, '/food-detail', arguments: f);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FoodCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String priceText;
  final VoidCallback? onTap;

  const _FoodCard({
    required this.imageUrl,
    required this.name,
    required this.priceText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                imageUrl,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 120,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.image, size: 48),
                ),
              )
                  : Container(
                height: 120,
                color: Colors.grey.shade200,
                child: const Icon(Icons.fastfood, size: 48),
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(priceText, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          // placeholder add-to-cart or view detail
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF667EEA), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), minimumSize: const Size(0, 32)),
                        child: const Text('Chọn', style: TextStyle(fontSize: 12)),
                      )
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        height: 160,
        child: Center(child: CircularProgressIndicator()),
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
            Text('Không thể tải menu', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(error, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onRetry, child: const Text('Thử lại'))
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../services/api_service.dart';

class AddItemFormScreen extends StatefulWidget {
  final int tableId;

  const AddItemFormScreen({super.key, required this.tableId});

  @override
  State<AddItemFormScreen> createState() => _AddItemFormScreenState();
}

class _AddItemFormScreenState extends State<AddItemFormScreen> {
  final ApiService api = ApiService();
  final _formKey = GlobalKey<FormState>();

  List<dynamic> allFoodItems = [];
  int? selectedFoodId;
  int quantity = 1;
  bool loading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchFoodItems();
  }

  Future<void> fetchFoodItems() async {
    setState(() => loading = true);
    try {
      final res = await api.get('/foods');
      setState(() {
        allFoodItems = res.data;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate() || selectedFoodId == null) return;

    _formKey.currentState!.save();
    setState(() => loading = true);

    try {
      await api.post(
        '/employee/tables/${widget.tableId}/add',
        data: {"foodItemId": selectedFoodId, "quantity": quantity},
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thêm món thành công!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm món mới'),
        backgroundColor: Colors.deepPurple,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text('Lỗi tải dữ liệu: $error'))
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Chọn món:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: selectedFoodId,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Chọn món ăn',
                ),
                items: allFoodItems
                    .map<DropdownMenuItem<int>>(
                      (item) => DropdownMenuItem<int>(
                    value: item['foodID'] ?? item['id'],
                    child: Text(item['name']),
                  ),
                )
                    .toList(),
                onChanged: (val) => setState(() => selectedFoodId = val),
                validator: (val) =>
                val == null ? 'Vui lòng chọn món' : null,
              ),
              const SizedBox(height: 16),
              const Text('Số lượng:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: '1',
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Nhập số lượng',
                ),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Không được bỏ trống';
                  }
                  final numValue = int.tryParse(val);
                  if (numValue == null || numValue < 1) {
                    return 'Số lượng phải ≥ 1';
                  }
                  return null;
                },
                onSaved: (val) => quantity = int.parse(val ?? '1'),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  onPressed: loading ? null : submit,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

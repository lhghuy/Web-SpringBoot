import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../services/api_service.dart';

class EditItemFormScreen extends StatefulWidget {
  final int detailId;
  final int initialQuantity;

  const EditItemFormScreen({
    super.key,
    required this.detailId,
    required this.initialQuantity,
  });

  @override
  State<EditItemFormScreen> createState() => _EditItemFormScreenState();
}

class _EditItemFormScreenState extends State<EditItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService api = ApiService();
  late TextEditingController _quantityController;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _quantityController =
        TextEditingController(text: widget.initialQuantity.toString());
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);
    final int quantity = int.parse(_quantityController.text);

    try {
      await api.post(
        '/employee/tables/detail/${widget.detailId}/update',
        data: {'quantity': quantity},
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật thành công!')),
        );
        Navigator.pop(context, true);
      }
    } on DioError catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.response?.data ?? e.message}')),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sửa số lượng'),
        backgroundColor: const Color(0xFF667EEA),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Số lượng',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Vui lòng nhập số lượng';
                  }
                  final numValue = int.tryParse(val);
                  if (numValue == null || numValue < 1) {
                    return 'Số lượng phải ≥ 1';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: Text(loading ? 'Đang cập nhật...' : 'Cập nhật'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF667EEA),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  onPressed: loading ? null : _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

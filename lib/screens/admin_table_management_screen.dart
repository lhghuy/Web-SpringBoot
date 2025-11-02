import 'package:flutter/material.dart';
import 'package:teamfoode/models/table_model.dart';
import 'package:teamfoode/services/api_service.dart';

class TableManagementScreen extends StatefulWidget {
  const TableManagementScreen({super.key});

  @override
  State<TableManagementScreen> createState() => _TableManagementScreenState();
}

class _TableManagementScreenState extends State<TableManagementScreen> {
  final ApiService _api = ApiService();
  List<TableModel> _tables = [];
  bool _loading = true;
  String? _error;

  // Form fields
  final TextEditingController _tableNumberController = TextEditingController();
  String _status = "Trong";
  int? _editingId;

  @override
  void initState() {
    super.initState();
    _loadTables();
  }

  Future<void> _loadTables() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await _api.get('/tables');
      if (response['success'] == true) {
        final List data = response['data'];
        _tables = data.map((e) => TableModel.fromJson(e)).toList();
      } else {
        _error = response['message'] ?? "Không thể tải danh sách bàn";
      }
    } catch (e) {
      _error = e.toString();
    }
    setState(() => _loading = false);
  }

  void _openCreateModal() {
    _editingId = null;
    _tableNumberController.clear();
    _status = "Trong";
    _showTableDialog(title: "Thêm bàn mới", onSubmit: _createTable);
  }

  void _openEditModal(TableModel table) {
    _editingId = table.tableID;
    _tableNumberController.text = table.tableNumber.toString();
    _status = table.status;
    _showTableDialog(title: "Sửa thông tin bàn", onSubmit: _updateTable);
  }

  Future<void> _createTable() async {
    final tableNumber = int.tryParse(_tableNumberController.text.trim());
    if (tableNumber == null) {
      _showError("Số bàn không hợp lệ");
      return;
    }

    try {
      final response = await _api.post('/tables', data: {
        'tableNumber': tableNumber,
        'status': _status,
      });
      if (response['success'] == true) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Thêm bàn thành công!")),
        );
        _loadTables();
      } else {
        _showError(response['message'] ?? "Lỗi thêm bàn");
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _updateTable() async {
    final tableNumber = int.tryParse(_tableNumberController.text.trim());
    if (tableNumber == null) {
      _showError("Số bàn không hợp lệ");
      return;
    }

    try {
      final response = await _api.put('/tables/$_editingId', data: {
        'tableNumber': tableNumber,
        'status': _status,
      });
      if (response['success'] == true) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cập nhật bàn thành công!")),
        );
        _loadTables();
      } else {
        _showError(response['message'] ?? "Lỗi cập nhật bàn");
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _deleteTable(int id, int tableNumber) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Xóa bàn"),
        content: Text('Bạn có chắc chắn muốn xóa bàn "$tableNumber"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Hủy")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Xóa")),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final response = await _api.delete('/tables/$id');
        if (response['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Xóa bàn thành công!")),
          );
          _loadTables();
        } else {
          _showError(response['message'] ?? "Không thể xóa bàn");
        }
      } catch (e) {
        _showError(e.toString());
      }
    }
  }

  void _showTableDialog({
    required String title,
    required VoidCallback onSubmit,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _tableNumberController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Số bàn",
                prefixIcon: Icon(Icons.table_bar),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(
                labelText: "Trạng thái",
                prefixIcon: Icon(Icons.toggle_on),
              ),
              items: const [
                DropdownMenuItem(value: "Trong", child: Text("Trống")),
                DropdownMenuItem(value: "DangPhucVu", child: Text("Đang phục vụ")),
              ],
              onChanged: (val) => _status = val ?? "Trong",
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(onPressed: onSubmit, child: const Text("Lưu")),
        ],
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản Lý Bàn"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTables,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateModal,
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : _tables.isEmpty
          ? const Center(child: Text("Chưa có bàn nào"))
          : GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _tables.length,
        itemBuilder: (context, index) {
          final table = _tables[index];
          final isEmpty = table.status == "Trong";
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.chair, size: 40, color: Colors.blueAccent),
                  const SizedBox(height: 8),
                  Text(
                    table.tableNumber.toString(), // ✅ Chuyển int sang String
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Chip(
                    label: Text(isEmpty ? "Trống" : "Đang phục vụ"),
                    backgroundColor:
                    isEmpty ? Colors.green[100] : Colors.red[100],
                    labelStyle: TextStyle(
                        color: isEmpty ? Colors.green[800] : Colors.red[800]),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () => _openEditModal(table),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteTable(
                            table.tableID, table.tableNumber),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

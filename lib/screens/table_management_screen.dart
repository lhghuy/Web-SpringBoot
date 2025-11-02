import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TableModel {
  final int tableID;
  final String tableNumber;
  final String status;

  TableModel({
    required this.tableID,
    required this.tableNumber,
    required this.status,
  });

  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      tableID: json['tableID'],
      tableNumber: json['tableNumber'],
      status: json['status'],
    );
  }
}

class TableManagementScreen extends StatefulWidget {
  const TableManagementScreen({super.key});

  @override
  State<TableManagementScreen> createState() => _TableManagementScreenState();
}

class _TableManagementScreenState extends State<TableManagementScreen> {
  late Future<List<TableModel>> _futureTables;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _futureTables = fetchTables();
  }

  Future<List<TableModel>> fetchTables() async {
    final response = await http.get(Uri.parse('http://localhost:8080/api/employee/tables'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => TableModel.fromJson(e)).toList();
    } else {
      throw Exception('Không thể tải danh sách bàn');
    }
  }

  Future<void> assignTable(int tableId) async {
    setState(() => _loading = true);
    final response = await http.post(Uri.parse('http://localhost:8080/api/employee/tables/$tableId/assign'));
    setState(() => _loading = false);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gán bàn thành công')));
      setState(() {
        _futureTables = fetchTables();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gán bàn thất bại')));
    }
  }

  Future<void> checkoutTable(int tableId) async {
    final TextEditingController nameCtrl = TextEditingController();
    final TextEditingController phoneCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Thanh toán'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Họ tên khách hàng'),
            ),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Số điện thoại (10 số)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              if (phoneCtrl.text.length != 10) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Số điện thoại không hợp lệ')));
                return;
              }
              final res = await http.post(
                Uri.parse('http://localhost:8080/api/employee/tables/$tableId/checkout'),
                headers: {'Content-Type': 'application/json'},
                body: json.encode({
                  'fullName': nameCtrl.text,
                  'phone': phoneCtrl.text,
                }),
              );
              if (res.statusCode == 200) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thanh toán thành công')));
                setState(() {
                  _futureTables = fetchTables();
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thanh toán thất bại')));
              }
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản Lý Bàn Ăn'),
        backgroundColor: Colors.deepPurple,
      ),
      body: FutureBuilder<List<TableModel>>(
        future: _futureTables,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không có bàn nào.'));
          }

          final tables = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
            ),
            itemCount: tables.length,
            itemBuilder: (context, index) {
              final t = tables[index];
              final isAvailable = t.status == 'Trong';
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: isAvailable ? Colors.green[50] : Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Bàn ${t.tableNumber}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Chip(
                        label: Text(isAvailable ? 'Trống' : 'Đang phục vụ'),
                        backgroundColor: isAvailable ? Colors.green[100] : Colors.red[100],
                        labelStyle: TextStyle(color: isAvailable ? Colors.green[800] : Colors.red[800]),
                      ),
                      if (_loading)
                        const CircularProgressIndicator()
                      else if (isAvailable)
                        ElevatedButton.icon(
                          onPressed: () => assignTable(t.tableID),
                          icon: const Icon(Icons.add),
                          label: const Text('Gán bàn'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        )
                      else
                        ElevatedButton.icon(
                          onPressed: () => checkoutTable(t.tableID),
                          icon: const Icon(Icons.payments),
                          label: const Text('Thanh toán'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

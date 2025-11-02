import 'package:flutter/material.dart';
import 'package:teamfoode/models/table_detail.dart';
import 'package:teamfoode/services/api_service.dart';
import 'package:teamfoode/models/food.dart';

class TableDetailScreen extends StatefulWidget {
  final int tableId;

  const TableDetailScreen({Key? key, required this.tableId}) : super(key: key);

  @override
  State<TableDetailScreen> createState() => _TableDetailScreenState();
}

class _TableDetailScreenState extends State<TableDetailScreen> {
  bool loading = true;
  bool updating = false;
  String? error;
  Map<String, dynamic>? tableData;

  final ApiService apiService = ApiService();
  String selectedStatus = "Trong";

  @override
  void initState() {
    super.initState();
    loadTableDetails();
  }

  Future<void> loadTableDetails() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final response = await apiService.get("/tables/${widget.tableId}/details");
      if (response["success"] == true) {
        setState(() {
          tableData = response["data"];
          selectedStatus = tableData?["table"]["status"] ?? "Trong";
        });
      } else {
        error = response["message"] ?? "Không thể tải thông tin bàn";
      }
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> updateTableStatus() async {
    if (updating) return;
    setState(() => updating = true);

    try {
      final response = await apiService.put(
        "/tables/${tableData?["table"]["tableID"]}/status",
        data: {"status": selectedStatus},
      );

      if (response["success"] == true) {
        setState(() {
          tableData?["table"]["status"] = selectedStatus;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cập nhật trạng thái bàn thành công!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response["message"] ?? "Cập nhật thất bại")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi kết nối: $e")),
      );
    } finally {
      setState(() => updating = false);
    }
  }

  String formatCurrency(num? amount) {
    if (amount == null) return "0 vnđ";
    return "${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} vnđ";
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Chi tiết bàn")),
        body: Center(child: Text(error!)),
      );
    }

    final table = tableData?["table"];
    final details = (tableData?["tableDetails"] as List?) ?? [];
    final totalPrice = tableData?["totalPrice"] ?? 0;
    final itemCount = tableData?["itemCount"] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text("Chi tiết bàn ${table?["tableNumber"] ?? ""}"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Thông tin bàn
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _infoRow(Icons.tag, "Số bàn", "${table?["tableNumber"]}"),
                    _infoRow(Icons.person, "Nhân viên", table?["employee"]?["fullName"] ?? "Chưa có"),
                    _infoRow(
                      Icons.toggle_on,
                      "Trạng thái",
                      table?["status"] == "Trong" ? "Trống" : "Đang phục vụ",
                      color: table?["status"] == "Trong" ? Colors.green : Colors.red,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Cập nhật trạng thái bàn
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text("Cập nhật trạng thái bàn",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      items: const [
                        DropdownMenuItem(value: "Trong", child: Text("Trống")),
                        DropdownMenuItem(value: "DangPhucVu", child: Text("Đang phục vụ")),
                      ],
                      onChanged: (value) => setState(() => selectedStatus = value!),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Trạng thái mới",
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      icon: updating
                          ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.save),
                      onPressed: updating ? null : updateTableStatus,
                      label: Text(updating ? "Đang cập nhật..." : "Cập nhật"),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Tổng quan
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _summaryCard(Icons.fastfood, "$itemCount", "Số món"),
                _summaryCard(Icons.monetization_on, formatCurrency(totalPrice), "Tổng tiền"),
              ],
            ),

            const SizedBox(height: 16),

            // Danh sách món
            details.isNotEmpty
                ? Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  const ListTile(
                    leading: Icon(Icons.list),
                    title: Text("Các món đã gọi"),
                  ),
                  const Divider(height: 1),
                  ...details.map((detail) {
                    final food = detail["foodItem"];
                    return ListTile(
                      title: Text(food["name"]),
                      subtitle: Text("Số lượng: ${detail["quantity"]}"),
                      trailing: Text(
                        formatCurrency(detail["totalPrice"]),
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }).toList(),
                  const Divider(),
                  ListTile(
                    title: const Text(
                      "TỔNG TIỀN:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: Text(
                      formatCurrency(totalPrice),
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            )
                : const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text("Bàn này chưa có món nào"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: color ?? Colors.blueGrey),
          const SizedBox(width: 10),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
              child: Text(value,
                  style: TextStyle(color: color ?? Colors.black, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _summaryCard(IconData icon, String value, String label) {
    return Expanded(
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: Colors.blue),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}

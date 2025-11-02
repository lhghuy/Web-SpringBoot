import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teamfoode/providers/order_provider.dart'; // Import OrderProvider của bạn
import 'package:teamfoode/models/order.dart'; // Import các models
import 'package:teamfoode/screens/admin_dashboard_screen.dart'; // Import dashboard screen
// import 'package:teamfoode/screens/admin_foods_screen.dart'; // TODO: Tạo màn hình này
// import 'package:teamfoode/screens/admin_tables_screen.dart'; // TODO: Tạo màn hình này
// import 'package:teamfoode/screens/admin_users_screen.dart'; // TODO: Tạo màn hình này
// import 'package:teamfoode/screens/admin_reports_screen.dart'; // TODO: Tạo màn hình này
// import 'package:teamfoode/screens/login_screen.dart'; // TODO: Màn hình đăng nhập của bạn

class AdminOrderScreen extends StatefulWidget {
  const AdminOrderScreen({Key? key}) : super(key: key);

  @override
  State<AdminOrderScreen> createState() => _AdminOrderScreenState();
}

class _AdminOrderScreenState extends State<AdminOrderScreen> {
  String? _userToken; // Token xác thực

  @override
  void initState() {
    super.initState();
    _loadUserTokenAndFetchOrders();
  }

  // Giả định bạn lưu token trong SharedPreferences sau khi đăng nhập
  Future<void> _loadUserTokenAndFetchOrders() async {
    final prefs = await SharedPreferences.getInstance();
    // Thay 'auth_token' bằng key bạn dùng để lưu token
    _userToken =
        prefs.getString('auth_token'); // Lấy token thật, nếu không có thì null
    if (_userToken != null && mounted) {
      // Gọi provider để tải hóa đơn
      Provider.of<OrderProvider>(context, listen: false).loadOrders(
          _userToken!);
    } else {
      // Xử lý trường hợp không có token (ví dụ: chuyển về màn hình đăng nhập)
      print('No auth token found. User might not be logged in.');
      // TODO: Điều hướng đến màn hình đăng nhập nếu không có token
      // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sử dụng Consumer để lắng nghe thay đổi từ OrderProvider
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFecf0f1),
          appBar: AppBar(
            title: const Text(
                'Quản Lý Hóa Đơn', style: TextStyle(color: Colors.white)),
            centerTitle: true,
            backgroundColor: const Color(0xFF2c3e50),
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: () {
                  if (_userToken != null) {
                    orderProvider.loadOrders(_userToken!);
                  } else {
                    // TODO: Xử lý khi không có token, ví dụ: hiển thị snackbar hoặc chuyển về login
                    print('Cannot refresh orders: no user token.');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text(
                          'Không tìm thấy token. Vui lòng đăng nhập lại.')),
                    );
                  }
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // Khu vực Stats Row
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    _buildStatCard(
                      icon: Icons.receipt_long,
                      title: 'Tổng hóa đơn',
                      value: orderProvider.totalOrders.toString(),
                      color: Colors.blue,
                    ),
                    _buildStatCard(
                      icon: Icons.check_circle,
                      title: 'Đã hoàn thành',
                      value: orderProvider.servedOrders.toString(),
                      color: Colors.green,
                    ),
                    _buildStatCard(
                      icon: Icons.history,
                      title: 'Đang xử lý',
                      value: orderProvider.processingOrders.toString(),
                      color: Colors.orange,
                    ),
                    _buildStatCard(
                      icon: Icons.monetization_on,
                      title: 'Doanh thu',
                      value: orderProvider.formatCurrency(
                          orderProvider.totalRevenue),
                      color: Colors.teal,
                    ),
                  ],
                ),
              ),

              // Alert Message (giống alertMessage trên web)
              if (orderProvider.showAlertMessage)
                Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: orderProvider.alertMessageType == 'success' ? Colors
                        .green.shade100 : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                        color: orderProvider.alertMessageType == 'success'
                            ? Colors.green.shade400
                            : Colors.red.shade400),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        orderProvider.alertMessageType == 'success' ? Icons
                            .check_circle : Icons.error,
                        color: orderProvider.alertMessageType == 'success'
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          orderProvider.alertMessageText!,
                          style: TextStyle(
                            color: orderProvider.alertMessageType == 'success'
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          // Thêm hàm dismiss trong provider để đóng alert một cách thủ công
                          orderProvider.dismissAlert();
                        },
                      ),
                    ],
                  ),
                ),

              // Main Card (Danh sách Hóa đơn)
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
                          children: [
                            const Icon(Icons.receipt, color: Color(0xFF2c3e50)),
                            const SizedBox(width: 8.0),
                            Text(
                              'Danh sách Hóa đơn',
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2c3e50),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),

                      if (orderProvider.isLoading)
                        const Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text('Đang tải dữ liệu...'),
                                Text('Vui lòng chờ trong giây lát',
                                    style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ),
                        )
                      else
                        if (orderProvider.errorMessage != null)
                          Expanded(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  'Lỗi: ${orderProvider.errorMessage}',
                                  style: const TextStyle(
                                      color: Colors.red, fontSize: 16),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          )
                        else
                          if (orderProvider.orders.isEmpty)
                            const Expanded(
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.receipt_long, size: 60,
                                        color: Colors.grey),
                                    SizedBox(height: 16),
                                    Text('Không có hóa đơn nào',
                                        style: TextStyle(fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                    Text(
                                        'Chưa có hóa đơn nào được tạo trong hệ thống.',
                                        style: TextStyle(color: Colors.grey)),
                                  ],
                                ),
                              ),
                            )
                          else
                            Expanded(
                              child: ListView.builder(
                                itemCount: orderProvider.orders.length,
                                itemBuilder: (context, index) {
                                  final order = orderProvider.orders[index];
                                  return _buildOrderListItem(
                                      context, order, orderProvider);
                                },
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          drawer: _buildAdminDrawer(context), // Thêm Drawer để mô phỏng sidebar
        );
      },
    );
  }

  // Widget cho các Stat Card (giống .stat-card trên web)
  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  Text(title,
                      style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                value,
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget cho mỗi item hóa đơn trong danh sách
  Widget _buildOrderListItem(BuildContext context, Order order,
      OrderProvider provider) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: _buildInfoRow(
                      'ID', '#${order.orderID}', Icons.tag, Colors.grey),
                ),
                Expanded(
                  flex: 2,
                  child: _buildInfoRow(
                      'Khách hàng', order.fullName ?? 'N/A', Icons.person,
                      Colors.blueGrey),
                ),
                Expanded(
                  flex: 2,
                  child: _buildInfoRow(
                      'Ngày tạo', provider.formatDateTime(order.createdAt),
                      Icons.calendar_today, Colors.blueGrey),
                ),
                Expanded(
                  flex: 1,
                  child: _buildInfoRow(
                      'Bàn', order.table?.tableNumber ?? 'N/A', Icons.table_bar,
                      Colors.blueGrey),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildInfoRow(
                      'Nhân viên', order.createdBy?.fullName ?? 'N/A',
                      Icons.person,
                      // ĐÃ SỬA: Icons.person_badge -> Icons.person
                      Colors.blueGrey),
                ),
                Expanded(
                  flex: 2,
                  child: _buildStatusBadge(order.status, provider),
                ),
                Expanded(
                  flex: 2,
                  child: _buildInfoRow(
                      'Tổng tiền', provider.formatCurrency(order.total),
                      Icons.monetization_on, Colors.green),
                ),
                Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (_userToken != null) {
                          provider.viewOrderDetails(order.orderID, _userToken!);
                          _showOrderDetailsModal(context);
                        } else {
                          print('Cannot view order details: no user token.');
                          // TODO: Xử lý khi không có token
                        }
                      },
                      icon: const Icon(Icons.remove_red_eye, size: 18),
                      label: const Text('Xem', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget tiện ích cho hàng thông tin
  Widget _buildInfoRow(String label, String value, IconData icon,
      Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 4.0),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Widget tiện ích cho badge trạng thái
  Widget _buildStatusBadge(String status, OrderProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: provider.getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ĐÃ SỬA: provider.getStatusIcon(status) giờ trả về IconData trực tiếp, không cần int.parse
          Icon(
            provider.getStatusIcon(status),
            size: 14,
            color: provider.getStatusColor(status),
          ),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              fontSize: 12,
              color: provider.getStatusColor(status),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Modal Chi tiết Hóa đơn (giống showDetailsModal trên web)
  void _showOrderDetailsModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        // Sử dụng Consumer trong Dialog để lấy OrderProvider
        return Consumer<OrderProvider>(
          builder: (context, orderProvider, child) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              titlePadding: EdgeInsets.zero,
              contentPadding: EdgeInsets.zero,
              insetPadding: const EdgeInsets.all(20),
              title: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF2c3e50),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Chi tiết hóa đơn #${orderProvider.selectedOrder
                          ?.orderID ?? 'N/A'}',
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        orderProvider.closeDetailsModal();
                        Navigator.of(dialogContext).pop();
                      },
                    ),
                  ],
                ),
              ),
              content: orderProvider.selectedOrder == null
                  ? const SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator()))
                  : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Thông tin chung hóa đơn
                      _buildDetailsInfoCard(orderProvider.selectedOrder!,
                          orderProvider),
                      const SizedBox(height: 20),
                      // Bảng chi tiết món ăn
                      Text('Chi tiết món ăn', style: Theme
                          .of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      _buildOrderDetailsTable(
                          orderProvider.orderDetails, orderProvider),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    orderProvider.closeDetailsModal();
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Đóng'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      // Sau khi dialog đóng, đảm bảo provider cũng đóng modal state
      Provider.of<OrderProvider>(context, listen: false).closeDetailsModal();
    });
  }

  // Widget cho thông tin chi tiết hóa đơn trong modal
  Widget _buildDetailsInfoCard(Order order, OrderProvider provider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(
                'Khách hàng:', order.fullName ?? 'N/A', Icons.person,
                Colors.black87),
            _buildDetailRow(
                'SĐT:', order.phone ?? 'N/A', Icons.phone, Colors.black87),
            _buildDetailRow(
                'Bàn:', order.table?.tableNumber ?? 'N/A', Icons.table_bar,
                Colors.black87),
            _buildDetailRow(
                'Nhân viên:', order.createdBy?.fullName ?? 'N/A',
                Icons.person, // ĐÃ SỬA: Icons.person_badge -> Icons.person
                Colors.black87),
            _buildDetailRow(
                'Thời gian:', provider.formatDateTime(order.createdAt),
                Icons.access_time, Colors.black87),
            Row(
              children: [
                const Icon(Icons.flag, size: 18, color: Colors.black87),
                const SizedBox(width: 8),
                const Text('Trạng thái:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                _buildStatusBadge(order.status, provider),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon,
      Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Flexible(child: Text(value)),
        ],
      ),
    );
  }

  // Widget cho bảng chi tiết món ăn trong modal
  Widget _buildOrderDetailsTable(List<OrderDetail> details,
      OrderProvider provider) {
    return Column(
      children: [
        Table(
          columnWidths: const {
            0: FlexColumnWidth(3),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(2),
            3: FlexColumnWidth(2),
          },
          border: TableBorder.all(color: Colors.grey.shade300),
          children: [
            TableRow(
              decoration: BoxDecoration(color: Colors.grey.shade200),
              children: const [
                TableCell(child: Padding(padding: EdgeInsets.all(8.0),
                    child: Text('Tên món',
                        style: TextStyle(fontWeight: FontWeight.bold)))),
                TableCell(child: Padding(padding: EdgeInsets.all(8.0),
                    child: Text(
                        'SL', style: TextStyle(fontWeight: FontWeight.bold)))),
                TableCell(child: Padding(padding: EdgeInsets.all(8.0),
                    child: Text('Đơn giá',
                        style: TextStyle(fontWeight: FontWeight.bold)))),
                TableCell(child: Padding(padding: EdgeInsets.all(8.0),
                    child: Text('Thành tiền',
                        style: TextStyle(fontWeight: FontWeight.bold)))),
              ],
            ),
            ...details.map((item) =>
                TableRow(
                  children: [
                    TableCell(child: Padding(padding: EdgeInsets.all(8.0),
                        child: Text(item.foodItem?.name ?? 'N/A'))),
                    TableCell(child: Padding(padding: EdgeInsets.all(8.0),
                        child: Text(item.quantity.toString()))),
                    TableCell(child: Padding(padding: EdgeInsets.all(8.0),
                        child: Text(
                            provider.formatCurrency(item.priceAtOrderTime)))),
                    TableCell(child: Padding(padding: EdgeInsets.all(8.0),
                        child: Text(provider.formatCurrency(
                            item.priceAtOrderTime * item.quantity)))),
                  ],
                )).toList(),
            TableRow(
              decoration: BoxDecoration(color: Colors.blue.shade50),
              children: [
                TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('TỔNG TIỀN:', style: Theme
                        .of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight
                        .bold)),
                  ),
                ),
                const TableCell(child: SizedBox()),
                const TableCell(child: SizedBox()),
                TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      provider.formatCurrency(provider.calculateTotal(details)),
                      style: Theme
                          .of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold,
                          color: Colors.blue
                              .shade800),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // Placeholder cho Drawer (Sidebar)
  Widget _buildAdminDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFF2c3e50), // Màu nền sidebar
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF2c3e50),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                      Icons.shield_rounded, color: Colors.white, size: 48),
                  const SizedBox(height: 8),
                  Text('ADMIN', style: Theme
                      .of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            _buildDrawerItem(context, Icons.dashboard,
                'Dashboard', () { // ĐÃ SỬA: Icons.speedometer2 -> Icons.dashboard
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => const AdminDashboardScreen()));
                }),
            _buildDrawerItem(context, Icons.fastfood, 'Quản lý sản phẩm', () {
              // TODO: Tạo màn hình AdminFoodsScreen
              // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const AdminFoodsScreen()));
              Navigator.pop(context); // Đóng drawer
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text(
                      'Tính năng quản lý sản phẩm chưa được triển khai.')));
            }),
            _buildDrawerItem(context, Icons.table_bar, 'Quản lý bàn', () {
              // TODO: Tạo màn hình AdminTablesScreen
              // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const AdminTablesScreen()));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text(
                      'Tính năng quản lý bàn chưa được triển khai.')));
            }),
            _buildDrawerItem(context, Icons.people, 'Quản lý nhân viên', () {
              // TODO: Tạo màn hình AdminUsersScreen
              // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const AdminUsersScreen()));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text(
                      'Tính năng quản lý nhân viên chưa được triển khai.')));
            }),
            _buildDrawerItem(context, Icons.receipt, 'Quản lý hoá đơn', () {
              Navigator.pop(context); // Đóng drawer
            }, isActive: true), // Đánh dấu active cho màn hình hiện tại
            _buildDrawerItem(
                context, Icons.bar_chart, 'Báo cáo kinh doanh', () {
              // TODO: Tạo màn hình AdminReportsScreen
              // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const AdminReportsScreen()));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text(
                      'Tính năng báo cáo kinh doanh chưa được triển khai.')));
            }),
            const Divider(color: Colors.white54),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: const Text(
                  'Đăng xuất', style: TextStyle(color: Colors.white)),
              onTap: () async {
                // Xử lý đăng xuất: xóa token, chuyển về màn hình đăng nhập
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('auth_token'); // Xóa token
                Navigator.pop(context); // Đóng drawer
                // TODO: Điều hướng đến màn hình đăng nhập sau khi đăng xuất
                // Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const LoginScreen()), (Route<dynamic> route) => false);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã đăng xuất.')));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title,
      VoidCallback onTap, {bool isActive = false}) {
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
}
import 'package:flutter/material.dart';
import 'package:teamfoode/models/order.dart';
import 'package:teamfoode/services/order_service.dart';
import 'package:teamfoode/services/api_service.dart';

class OrderScreen extends StatefulWidget {
  final bool isAdmin; // true: admin, false: user
  final String token;

  const OrderScreen({Key? key, required this.isAdmin, required this.token}) : super(key: key);

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  late OrderService _orderService;
  late Future<List<Order>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _orderService = OrderService(ApiService());
    _ordersFuture = _orderService.fetchOrders(token: widget.token);
  }

  String _translateStatus(String status) {
    switch (status) {
      case 'Đã nhận':
        return 'Đang nấu';
      case 'Đang nấu':
        return 'Hoàn thành';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Đã nhận':
        return Colors.orange;
      case 'Đang nấu':
        return Colors.blueAccent;
      case 'Hoàn thành':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Future<void> _updateStatus(Order order) async {
    try {
      final nextStatus = _translateStatus(order.status);
      if (nextStatus == order.status) return;

      final updatedOrder = await _orderService.updateOrderStatus(
        order.orderID,
        nextStatus,
        token: widget.token,
      );

      setState(() {
        _ordersFuture = _orderService.fetchOrders(token: widget.token);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật trạng thái thành công: ${updatedOrder.status}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi cập nhật: $e')),
      );
    }
  }

  Widget _buildOrderCard(Order order) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: Icon(Icons.receipt_long, color: _getStatusColor(order.status)),
        title: Text(
          'Mã đơn: #${order.orderID}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Khách: ${order.fullName ?? "Không rõ"}\n'
              'Trạng thái: ${order.status}\n'
              'Tổng: ${order.total.toStringAsFixed(0)} VNĐ',
        ),
        trailing: widget.isAdmin
            ? ElevatedButton(
          onPressed: order.status == 'Hoàn thành'
              ? null
              : () => _updateStatus(order),
          style: ElevatedButton.styleFrom(
            backgroundColor: _getStatusColor(order.status),
          ),
          child: Text(
            _translateStatus(order.status),
            style: const TextStyle(color: Colors.white),
          ),
        )
            : Text(
          order.status,
          style: TextStyle(
            color: _getStatusColor(order.status),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isAdmin ? 'Quản lý đơn hàng' : 'Đơn hàng của tôi'),
        backgroundColor: widget.isAdmin ? Colors.redAccent : Colors.green,
      ),
      body: FutureBuilder<List<Order>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }
          final orders = snapshot.data ?? [];
          if (orders.isEmpty) {
            return const Center(child: Text('Không có đơn hàng nào.'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _ordersFuture = _orderService.fetchOrders(token: widget.token);
              });
            },
            child: ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) => _buildOrderCard(orders[index]),
            ),
          );
        },
      ),
    );
  }
}

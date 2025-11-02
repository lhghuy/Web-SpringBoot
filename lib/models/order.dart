import 'package:json_annotation/json_annotation.dart';

part 'order.g.dart';

@JsonSerializable()
class Order {
  final int orderID;
  final String? fullName; // Tên khách hàng
  final String? phone; // SĐT khách hàng
  final DateTime createdAt;
  final OrderTable? table; // Thông tin bàn
  final OrderUser? createdBy; // Thông tin nhân viên tạo đơn
  final String status;
  final double total;

  Order({
    required this.orderID,
    this.fullName,
    this.phone,
    required this.createdAt,
    this.table,
    this.createdBy,
    required this.status,
    required this.total,
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

  Map<String, dynamic> toJson() => _$OrderToJson(this);
}

@JsonSerializable()
class OrderTable {
  final int tableID;
  final String tableNumber;

  OrderTable({required this.tableID, required this.tableNumber});

  factory OrderTable.fromJson(Map<String, dynamic> json) =>
      _$OrderTableFromJson(json);

  Map<String, dynamic> toJson() => _$OrderTableToJson(this);
}

@JsonSerializable()
class OrderUser {
  final int userID;
  final String fullName;

  OrderUser({required this.userID, required this.fullName});

  factory OrderUser.fromJson(Map<String, dynamic> json) =>
      _$OrderUserFromJson(json);

  Map<String, dynamic> toJson() => _$OrderUserToJson(this);
}

@JsonSerializable()
class OrderDetail {
  final int orderDetailID;
  final FoodItem? foodItem;
  final int quantity;
  final double priceAtOrderTime;

  OrderDetail({
    required this.orderDetailID,
    this.foodItem,
    required this.quantity,
    required this.priceAtOrderTime,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) =>
      _$OrderDetailFromJson(json);

  Map<String, dynamic> toJson() => _$OrderDetailToJson(this);
}

@JsonSerializable()
class FoodItem {
  final int foodItemID; // Changed from foodID for consistency
  final String name;

  FoodItem({required this.foodItemID, required this.name});

  factory FoodItem.fromJson(Map<String, dynamic> json) =>
      _$FoodItemFromJson(json);

  Map<String, dynamic> toJson() => _$FoodItemToJson(this);
}
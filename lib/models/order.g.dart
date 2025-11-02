// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
  orderID: (json['orderID'] as num).toInt(),
  fullName: json['fullName'] as String?,
  phone: json['phone'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  table: json['table'] == null
      ? null
      : OrderTable.fromJson(json['table'] as Map<String, dynamic>),
  createdBy: json['createdBy'] == null
      ? null
      : OrderUser.fromJson(json['createdBy'] as Map<String, dynamic>),
  status: json['status'] as String,
  total: (json['total'] as num).toDouble(),
);

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
  'orderID': instance.orderID,
  'fullName': instance.fullName,
  'phone': instance.phone,
  'createdAt': instance.createdAt.toIso8601String(),
  'table': instance.table,
  'createdBy': instance.createdBy,
  'status': instance.status,
  'total': instance.total,
};

OrderTable _$OrderTableFromJson(Map<String, dynamic> json) => OrderTable(
  tableID: (json['tableID'] as num).toInt(),
  tableNumber: json['tableNumber'] as String,
);

Map<String, dynamic> _$OrderTableToJson(OrderTable instance) =>
    <String, dynamic>{
      'tableID': instance.tableID,
      'tableNumber': instance.tableNumber,
    };

OrderUser _$OrderUserFromJson(Map<String, dynamic> json) => OrderUser(
  userID: (json['userID'] as num).toInt(),
  fullName: json['fullName'] as String,
);

Map<String, dynamic> _$OrderUserToJson(OrderUser instance) => <String, dynamic>{
  'userID': instance.userID,
  'fullName': instance.fullName,
};

OrderDetail _$OrderDetailFromJson(Map<String, dynamic> json) => OrderDetail(
  orderDetailID: (json['orderDetailID'] as num).toInt(),
  foodItem: json['foodItem'] == null
      ? null
      : FoodItem.fromJson(json['foodItem'] as Map<String, dynamic>),
  quantity: (json['quantity'] as num).toInt(),
  priceAtOrderTime: (json['priceAtOrderTime'] as num).toDouble(),
);

Map<String, dynamic> _$OrderDetailToJson(OrderDetail instance) =>
    <String, dynamic>{
      'orderDetailID': instance.orderDetailID,
      'foodItem': instance.foodItem,
      'quantity': instance.quantity,
      'priceAtOrderTime': instance.priceAtOrderTime,
    };

FoodItem _$FoodItemFromJson(Map<String, dynamic> json) => FoodItem(
  foodItemID: (json['foodItemID'] as num).toInt(),
  name: json['name'] as String,
);

Map<String, dynamic> _$FoodItemToJson(FoodItem instance) => <String, dynamic>{
  'foodItemID': instance.foodItemID,
  'name': instance.name,
};

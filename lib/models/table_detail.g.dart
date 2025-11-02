// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'table_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TableDetail _$TableDetailFromJson(Map<String, dynamic> json) => TableDetail(
  tableDetailId: (json['tableDetailId'] as num).toInt(),
  foodItem: Food.fromJson(json['foodItem'] as Map<String, dynamic>),
  quantity: (json['quantity'] as num).toInt(),
  totalPrice: (json['totalPrice'] as num).toDouble(),
);

Map<String, dynamic> _$TableDetailToJson(TableDetail instance) =>
    <String, dynamic>{
      'tableDetailId': instance.tableDetailId,
      'foodItem': instance.foodItem,
      'quantity': instance.quantity,
      'totalPrice': instance.totalPrice,
    };

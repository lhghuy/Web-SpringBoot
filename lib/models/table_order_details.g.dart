// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'table_order_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TableOrderDetails _$TableOrderDetailsFromJson(Map<String, dynamic> json) =>
    TableOrderDetails(
      table: TableModel.fromJson(json['table'] as Map<String, dynamic>),
      tableDetails: (json['tableDetails'] as List<dynamic>)
          .map((e) => TableDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
    );

Map<String, dynamic> _$TableOrderDetailsToJson(TableOrderDetails instance) =>
    <String, dynamic>{
      'table': instance.table,
      'tableDetails': instance.tableDetails,
      'totalPrice': instance.totalPrice,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'table_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TableModel _$TableModelFromJson(Map<String, dynamic> json) => TableModel(
  tableID: (json['tableID'] as num).toInt(),
  tableNumber: (json['tableNumber'] as num).toInt(),
  status: json['status'] as String,
  employee: json['employee'] == null
      ? null
      : User.fromJson(json['employee'] as Map<String, dynamic>),
);

Map<String, dynamic> _$TableModelToJson(TableModel instance) =>
    <String, dynamic>{
      'tableID': instance.tableID,
      'tableNumber': instance.tableNumber,
      'status': instance.status,
      'employee': instance.employee,
    };

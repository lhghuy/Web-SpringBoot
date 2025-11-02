import 'package:json_annotation/json_annotation.dart';
import 'package:teamfoode/models/table_model.dart';
import 'package:teamfoode/models/table_detail.dart';

part 'table_order_details.g.dart';

@JsonSerializable()
class TableOrderDetails {
  final TableModel table;
  final List<TableDetail> tableDetails;
  final double totalPrice; // Tổng tiền của tất cả các món trong bàn

  TableOrderDetails({
    required this.table,
    required this.tableDetails,
    required this.totalPrice,
  });

  factory TableOrderDetails.fromJson(Map<String, dynamic> json) =>
      _$TableOrderDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$TableOrderDetailsToJson(this);
}
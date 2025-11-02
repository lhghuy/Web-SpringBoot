import 'package:json_annotation/json_annotation.dart';
import 'package:teamfoode/models/food.dart'; // Sử dụng Food model đã có

part 'table_detail.g.dart';

@JsonSerializable()
class TableDetail {
  final int tableDetailId; // tableDetailId (tên trường từ backend)
  final Food foodItem;
  final int quantity;
  final double totalPrice; // total price for this specific item quantity

  TableDetail({
    required this.tableDetailId,
    required this.foodItem,
    required this.quantity,
    required this.totalPrice,
  });

  factory TableDetail.fromJson(Map<String, dynamic> json) =>
      _$TableDetailFromJson(json);

  Map<String, dynamic> toJson() => _$TableDetailToJson(this);

  TableDetail copyWith({
    int? tableDetailId,
    Food? foodItem,
    int? quantity,
    double? totalPrice,
  }) {
    return TableDetail(
      tableDetailId: tableDetailId ?? this.tableDetailId,
      foodItem: foodItem ?? this.foodItem,
      quantity: quantity ?? this.quantity,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }
}
import 'package:json_annotation/json_annotation.dart';
import 'package:teamfoode/models/food.dart'; // Sử dụng Food model đã có
import 'package:teamfoode/models/user.dart'; // Giả định bạn có User model cho Employee

part 'table_model.g.dart'; // Đổi tên file này thành table_model.g.dart

@JsonSerializable()
class TableModel {
  final int tableID; // tableID (tên trường từ backend)
  final int tableNumber;
  final String status;
  final User? employee; // Nhân viên phụ trách (có thể null)

  TableModel({
    required this.tableID,
    required this.tableNumber,
    required this.status,
    this.employee,
  });

  factory TableModel.fromJson(Map<String, dynamic> json) =>
      _$TableModelFromJson(json);

  Map<String, dynamic> toJson() => _$TableModelToJson(this);

  TableModel copyWith({
    int? tableID,
    int? tableNumber,
    String? status,
    User? employee,
  }) {
    return TableModel(
      tableID: tableID ?? this.tableID,
      tableNumber: tableNumber ?? this.tableNumber,
      status: status ?? this.status,
      employee: employee ?? this.employee,
    );
  }
}

// Giả định User model có cấu trúc như sau (nếu chưa có):
// class User {
//   final int userID;
//   final String fullName;
//   // ... other fields
//   User({required this.userID, required this.fullName});
//   factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
//   Map<String, dynamic> toJson() => _$UserToJson(this);
// }
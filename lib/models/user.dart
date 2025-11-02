import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int userID;
  final String fullName;
  final String username;

  // Thêm các trường khác của user nếu cần

  User({required this.userID, required this.fullName, required this.username});

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    int? userID,
    String? fullName,
    String? username,
  }) {
    return User(
      userID: userID ?? this.userID,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
    );
  }
}
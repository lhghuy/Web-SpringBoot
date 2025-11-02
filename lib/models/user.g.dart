// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  userID: (json['userID'] as num).toInt(),
  fullName: json['fullName'] as String,
  username: json['username'] as String,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'userID': instance.userID,
  'fullName': instance.fullName,
  'username': instance.username,
};

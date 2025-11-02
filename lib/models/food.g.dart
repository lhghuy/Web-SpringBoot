// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Food _$FoodFromJson(Map<String, dynamic> json) => Food(
  foodID: (json['foodID'] as num?)?.toInt(),
  name: json['name'] as String,
  description: json['description'] as String?,
  price: (json['price'] as num).toDouble(),
  anh: json['anh'] as String?,
  quantity: (json['quantity'] as num).toInt(),
  category: Category.fromJson(json['category'] as Map<String, dynamic>),
);

Map<String, dynamic> _$FoodToJson(Food instance) => <String, dynamic>{
  'foodID': instance.foodID,
  'name': instance.name,
  'description': instance.description,
  'price': instance.price,
  'anh': instance.anh,
  'quantity': instance.quantity,
  'category': instance.category,
};

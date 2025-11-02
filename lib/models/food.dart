import 'package:json_annotation/json_annotation.dart';
import 'package:teamfoode/models/category.dart'; // Import Category model của bạn

part 'food.g.dart';

@JsonSerializable()
class Food {
  final int? foodID; // Null for new food, int for existing food
  final String name;
  final String? description;
  final double price;
  final String? anh; // Image URL (tên trường theo backend của bạn)
  final int quantity;
  final Category category;

  Food({
    this.foodID,
    required this.name,
    this.description,
    required this.price,
    this.anh,
    required this.quantity,
    required this.category,
  });

  factory Food.fromJson(Map<String, dynamic> json) => _$FoodFromJson(json);

  Map<String, dynamic> toJson() => _$FoodToJson(this);

  Food copyWith({
    int? foodID,
    String? name,
    String? description,
    double? price,
    String? anh,
    int? quantity,
    Category? category,
  }) {
    return Food(
      foodID: foodID ?? this.foodID,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      anh: anh ?? this.anh,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
    );
  }
}
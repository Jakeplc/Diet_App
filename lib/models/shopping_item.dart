class ShoppingItem {
  String id;
  String name;
  String category;
  double quantity;
  String unit;
  bool isChecked;
  List<String> mealPlanIds; // Which meal plans this item is for

  ShoppingItem({
    required this.id,
    required this.name,
    required this.category,
    this.quantity = 1.0,
    this.unit = 'serving',
    this.isChecked = false,
    this.mealPlanIds = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'isChecked': isChecked,
      'mealPlanIds': mealPlanIds,
    };
  }

  factory ShoppingItem.fromMap(Map<String, dynamic> map) {
    return ShoppingItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? 'Other',
      quantity: (map['quantity'] ?? 1.0).toDouble(),
      unit: map['unit'] ?? 'serving',
      isChecked: map['isChecked'] ?? false,
      mealPlanIds: List<String>.from(map['mealPlanIds'] ?? []),
    );
  }
}

class PriceCategoryModel {
  final List<PriceModel> items;
  final String lastUpdated;

  PriceCategoryModel({
    required this.items,
    required this.lastUpdated,
  });

  factory PriceCategoryModel.fromJson(Map<String, dynamic> json) {
    return PriceCategoryModel(
      lastUpdated: json["last_updated"] ?? "",
      items: (json["items"] as List)
          .map((e) => PriceModel.fromJson(e))
          .toList(),
    );
  }
}

class PriceModel {
  final int id;
  final String type;
  final String quantity;
  final String unit;
  final dynamic price;
  final String currency;
  final String? priceDirection;

  PriceModel({
    required this.id,
    required this.type,
    required this.quantity,
    required this.unit,
    required this.price,
    required this.currency,
    required this.priceDirection,
  });

  factory PriceModel.fromJson(Map<String, dynamic> json) {
    return PriceModel(
      id: json["id"],
      type: json["type"] ?? "",
      quantity: json["quantity"] ?? "",
      unit: json["unit"] ?? "",
      price: json["price"] ?? 0,
      currency: json["currency"] ?? "",
      priceDirection: json["price_direction"],
    );
  }
}
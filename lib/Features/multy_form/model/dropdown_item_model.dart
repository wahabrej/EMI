class DropdownItemModel {
  final String id;
  final String name;
  final String? code;
  final double? price;
  final Map<String, dynamic> rawJson;

  DropdownItemModel({
    required this.id,
    required this.name,
    this.code,
    this.price,
    required this.rawJson,
  });

  factory DropdownItemModel.fromJson(Map<String, dynamic> json) {
    // ১. নাম খুঁজে বের করা (টপ লেভেল বা নেস্টেড product লেভেল থেকে)
    String? name = json['name'] ?? json['title'] ?? json['modelName'] ?? json['model_name'];
    if (name == null && json['product'] is Map) {
      name = json['product']['name'] ?? json['product']['title'] ?? json['product']['modelName'];
    }

    // ২. আইডি খুঁজে বের করা
    String id = json['id']?.toString() ?? json['productId']?.toString() ?? '';

    // ৩. দাম খুঁজে বের করা (একাধিক কী চেক করা হচ্ছে)
    double? parsedPrice = _findPriceInJson(json);
    
    // যদি টপ লেভেলে না থাকে, তবে 'product' অবজেক্টের ভেতর খোঁজা
    if ((parsedPrice == null || parsedPrice == 0) && json['product'] is Map) {
      parsedPrice = _findPriceInJson(json['product']);
    }

    return DropdownItemModel(
      id: id,
      name: name ?? 'N/A',
      code: json['code']?.toString(),
      price: parsedPrice,
      rawJson: json,
    );
  }

  static double? _findPriceInJson(Map<dynamic, dynamic> json) {
    final priceKeys = ['mrp', 'price', 'regularPrice', 'regular_price', 'sellingPrice', 'salePrice', 'unitPrice'];
    for (var key in priceKeys) {
      if (json[key] != null && json[key].toString().isNotEmpty) {
        // কমা বা কারেন্সি সিম্বল থাকলে তা রিমুভ করা হচ্ছে
        String cleanValue = json[key].toString().replaceAll(RegExp(r'[^0-9.]'), '');
        var value = double.tryParse(cleanValue);
        if (value != null && value > 0) return value;
      }
    }
    return null;
  }
}

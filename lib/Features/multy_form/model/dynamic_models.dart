class DropdownItemModel {
  final String id;
  final String name;
  final double? extraValue; // Like price for products, downpayment for plans

  DropdownItemModel({required this.id, required this.name, this.extraValue});

  factory DropdownItemModel.fromJson(Map<String, dynamic> json) {
    return DropdownItemModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Unknown',
      extraValue: json['price'] != null ? double.tryParse(json['price'].toString()) : null,
    );
  }
}
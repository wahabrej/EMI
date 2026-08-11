// lib/models/EmiPlan.dart
import 'package:flutter/material.dart';

class EmiPlan {
  final String id;
  final String productId;
  final String name;
  final String? note;
  final int months;
  final String downPaymentCalculationType;
  final String displayDownPaymentPercent;
  final String downPaymentCalculationRate;
  final String? downPaymentAmount;
  final String appEmiChargeType;
  final String appEmiChargeRate;
  final String? appEmiChargeAmount;
  final String cashbackRate;
  final String? cashbackAmount;
  final List<DownPaymentComponent>? downPaymentComponents;
  final bool isActive;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Product? product;

  EmiPlan({
    required this.id,
    required this.productId,
    required this.name,
    this.note,
    required this.months,
    required this.downPaymentCalculationType,
    required this.displayDownPaymentPercent,
    required this.downPaymentCalculationRate,
    this.downPaymentAmount,
    required this.appEmiChargeType,
    required this.appEmiChargeRate,
    this.appEmiChargeAmount,
    required this.cashbackRate,
    this.cashbackAmount,
    this.downPaymentComponents,
    required this.isActive,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    this.product,
  });

  factory EmiPlan.fromJson(Map<String, dynamic> json) {
    return EmiPlan(
      id: json['id'] ?? '',
      productId: json['productId'] ?? '',
      name: json['name'] ?? '',
      note: json['note'],
      months: json['months'] ?? 0,
      downPaymentCalculationType: json['downPaymentCalculationType'] ?? 'AMOUNT',
      displayDownPaymentPercent: json['displayDownPaymentPercent'] ?? '0',
      downPaymentCalculationRate: json['downPaymentCalculationRate'] ?? '0',
      downPaymentAmount: json['downPaymentAmount']?.toString(),
      appEmiChargeType: json['appEmiChargeType'] ?? 'RATE',
      appEmiChargeRate: json['appEmiChargeRate'] ?? '0',
      appEmiChargeAmount: json['appEmiChargeAmount']?.toString(),
      cashbackRate: json['cashbackRate'] ?? '0',
      cashbackAmount: json['cashbackAmount']?.toString(),
      downPaymentComponents: json['downPaymentComponents'] != null
          ? (json['downPaymentComponents'] as List)
          .map((e) => DownPaymentComponent.fromJson(e))
          .toList()
          : null,
      isActive: json['isActive'] ?? false,
      sortOrder: json['sortOrder'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      product: json['product'] != null ? Product.fromJson(json['product']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'name': name,
      'note': note,
      'months': months,
      'downPaymentCalculationType': downPaymentCalculationType,
      'displayDownPaymentPercent': displayDownPaymentPercent,
      'downPaymentCalculationRate': downPaymentCalculationRate,
      'downPaymentAmount': downPaymentAmount,
      'appEmiChargeType': appEmiChargeType,
      'appEmiChargeRate': appEmiChargeRate,
      'appEmiChargeAmount': appEmiChargeAmount,
      'cashbackRate': cashbackRate,
      'cashbackAmount': cashbackAmount,
      'downPaymentComponents': downPaymentComponents?.map((e) => e.toJson()).toList(),
      'isActive': isActive,
      'sortOrder': sortOrder,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'product': product?.toJson(),
    };
  }

  // ─── Helper Methods ───
  double getDownPaymentAmount() {
    return double.tryParse(downPaymentAmount ?? '0') ?? 0.0;
  }

  double getDownPaymentPercent() {
    return double.tryParse(displayDownPaymentPercent) ?? 0.0;
  }

  double getAppEmiChargeRate() {
    return double.tryParse(appEmiChargeRate) ?? 0.0;
  }

  double getCashbackRate() {
    return double.tryParse(cashbackRate) ?? 0.0;
  }

  List<DownPaymentComponent> getDownPaymentComponents() {
    return downPaymentComponents ?? [];
  }
}

class DownPaymentComponent {
  final String name;
  final String rate;
  final String type;

  DownPaymentComponent({
    required this.name,
    required this.rate,
    required this.type,
  });

  factory DownPaymentComponent.fromJson(Map<String, dynamic> json) {
    return DownPaymentComponent(
      name: json['name'] ?? '',
      rate: json['rate']?.toString() ?? '0',
      type: json['type'] ?? 'RATE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'rate': rate,
      'type': type,
    };
  }
}

class Product {
  final String id;
  final String code;
  final String name;
  final String? model;
  final String? sellingPrice;
  final String status;
  final Brand? brand;

  Product({
    required this.id,
    required this.code,
    required this.name,
    this.model,
    this.sellingPrice,
    required this.status,
    this.brand,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      model: json['model'],
      sellingPrice: json['sellingPrice']?.toString(),
      status: json['status'] ?? 'ACTIVE',
      brand: json['brand'] != null ? Brand.fromJson(json['brand']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'model': model,
      'sellingPrice': sellingPrice,
      'status': status,
      'brand': brand?.toJson(),
    };
  }

  double getSellingPrice() {
    return double.tryParse(sellingPrice ?? '0') ?? 0.0;
  }
}

class Brand {
  final String id;
  final String code;
  final String name;

  Brand({
    required this.id,
    required this.code,
    required this.name,
  });

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
    };
  }
}

class PhoneProductModel {
  final bool success;
  final List<Data> data;

  PhoneProductModel({
    required this.success,
    required this.data,
  });

  factory PhoneProductModel.fromJson(Map<String, dynamic> json) {
    return PhoneProductModel(
      success: json['success'] ?? false,
      data: json['data'] != null
          ? (json['data'] as List).map((e) => Data.fromJson(e)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

class Data {
  final String? id;
  final String? code;
  final String? name;
  final String? model;
  final String? sellingPrice;
  final String? status;
  final Brand? brand;
  final String? imageUrl;
  final List<EmiPlan>? emiPlans;

  Data({
    this.id,
    this.code,
    this.name,
    this.model,
    this.sellingPrice,
    this.status,
    this.brand,
    this.imageUrl,
    this.emiPlans,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      id: json['id']?.toString(),
      code: json['code']?.toString(),
      name: json['name']?.toString(),
      model: json['model']?.toString(),
      sellingPrice: json['sellingPrice']?.toString(),
      status: json['status']?.toString(),
      brand: json['brand'] != null ? Brand.fromJson(json['brand']) : null,
      imageUrl: json['imageUrl']?.toString(),
      emiPlans: json['emiPlans'] != null
          ? (json['emiPlans'] as List).map((e) => EmiPlan.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'model': model,
      'sellingPrice': sellingPrice,
      'status': status,
      'brand': brand?.toJson(),
      'imageUrl': imageUrl,
      'emiPlans': emiPlans?.map((e) => e.toJson()).toList(),
    };
  }

  double getSellingPrice() {
    return double.tryParse(sellingPrice ?? '0') ?? 0.0;
  }
}
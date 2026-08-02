class CustomerLoanApplicationModel {
  final String? id;
  final String? displayId;
  final String? customerDisplayId;
  final String? status;
  final String? issueDate;
  final ProductMini? product;
  final int? planMonths;
  final num? monthlyEmi;
  final num? regularPrice;
  final num? downPayment;
  final String? downPaymentMethod;
  final String? decisionAt;
  final String? rejectionReason;
  final String? approvalRemarks;

  CustomerLoanApplicationModel({
    this.id,
    this.displayId,
    this.customerDisplayId,
    this.status,
    this.issueDate,
    this.product,
    this.planMonths,
    this.monthlyEmi,
    this.regularPrice,
    this.downPayment,
    this.downPaymentMethod,
    this.decisionAt,
    this.rejectionReason,
    this.approvalRemarks,
  });

  factory CustomerLoanApplicationModel.fromJson(Map<String, dynamic> json) {
    return CustomerLoanApplicationModel(
      id: json['id']?.toString(),
      displayId: json['displayId']?.toString(),
      customerDisplayId: json['customerDisplayId']?.toString(),
      status: json['status']?.toString(),
      issueDate: json['issueDate']?.toString(),
      product: json['product'] != null ? ProductMini.fromJson(json['product']) : null,
      planMonths: _parseInt(json['planMonths']),
      monthlyEmi: _parseNum(json['monthlyEmi']),
      regularPrice: _parseNum(json['regularPrice']),
      downPayment: _parseNum(json['downPayment']),
      downPaymentMethod: json['downPaymentMethod']?.toString(),
      decisionAt: json['decisionAt']?.toString(),
      rejectionReason: json['rejectionReason']?.toString(),
      approvalRemarks: json['approvalRemarks']?.toString(),
    );
  }
}

class ProductMini {
  final String? id;
  final String? code;
  final String? name;

  ProductMini({this.id, this.code, this.name});

  factory ProductMini.fromJson(Map<String, dynamic> json) {
    return ProductMini(
      id: json['id']?.toString(),
      code: json['code']?.toString(),
      name: json['name']?.toString(),
    );
  }
}

int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? (double.tryParse(value)?.toInt());
  return null;
}

num? _parseNum(dynamic value) {
  if (value == null) return null;
  if (value is num) return value;
  if (value is String) return num.tryParse(value);
  return null;
}

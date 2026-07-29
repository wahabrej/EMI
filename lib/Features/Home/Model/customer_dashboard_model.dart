// customer_dashboard_model.dart

class CustomerDashboardModel {
  final bool success;
  final CustomerDashboardData data;

  CustomerDashboardModel({required this.success, required this.data});

  factory CustomerDashboardModel.fromJson(Map<String, dynamic> json) {
    return CustomerDashboardModel(
      success: json['success'] ?? false,
      data: CustomerDashboardData.fromJson(json['data'] ?? {}),
    );
  }
}

class CustomerDashboardData {
  final List<CustomerLoan> loans;

  CustomerDashboardData({required this.loans});

  factory CustomerDashboardData.fromJson(Map<String, dynamic> json) {
    return CustomerDashboardData(
      loans: (json['loans'] as List? ?? [])
          .map((e) => CustomerLoan.fromJson(e))
          .toList(),
    );
  }
}

class CustomerLoan {
  final String id;
  final String displayId;
  final String status;
  final String disbursementDate;
  final ProductNameOnly? product;
  final ProductNameOnly? productModel;
  final CalculationSnapshot? calculationSnapshot;
  final List<Installment> installments;
  final List<CustomerPayment> payments;

  CustomerLoan({
    required this.id,
    required this.displayId,
    required this.status,
    required this.disbursementDate,
    this.product,
    this.productModel,
    this.calculationSnapshot,
    required this.installments,
    required this.payments,
  });

  factory CustomerLoan.fromJson(Map<String, dynamic> json) {
    return CustomerLoan(
      id: json['id'] ?? '',
      displayId: json['displayId'] ?? '',
      status: json['status'] ?? '',
      disbursementDate: json['disbursementDate'] ?? json['disbursement Date'] ?? '',
      product: json['product'] != null ? ProductNameOnly.fromJson(json['product']) : null,
      productModel: json['productModel'] != null ? ProductNameOnly.fromJson(json['productModel']) : null,
      calculationSnapshot: json['calculationSnapshot'] != null
          ? CalculationSnapshot.fromJson(json['calculationSnapshot'])
          : null,
      installments: (json['installments'] as List? ?? [])
          .map((e) => Installment.fromJson(e))
          .toList(),
      payments: (json['payments'] as List? ?? [])
          .map((e) => CustomerPayment.fromJson(e))
          .toList(),
    );
  }
}

class ProductNameOnly {
  final String name;

  ProductNameOnly({required this.name});

  factory ProductNameOnly.fromJson(Map<String, dynamic> json) {
    return ProductNameOnly(name: json['name'] ?? '');
  }
}

class CalculationSnapshot {
  final num regularPrice;
  final num initialPaymentAmount;
  final num monthlyEmi;
  final num totalAfterCashback;

  CalculationSnapshot({
    required this.regularPrice,
    required this.initialPaymentAmount,
    required this.monthlyEmi,
    required this.totalAfterCashback,
  });

  factory CalculationSnapshot.fromJson(Map<String, dynamic> json) {
    return CalculationSnapshot(
      regularPrice: json['regularPrice'] ?? 0,
      initialPaymentAmount: json['initialPaymentAmount'] ?? 0,
      monthlyEmi: json['monthlyEmi'] ?? 0,
      totalAfterCashback: json['totalAfterCashback'] ?? 0,
    );
  }
}

class Installment {
  final String id;
  final int installmentNumber;
  final String dueDate;
  final num originalAmount;
  final num paidAmount;
  final num remainingAmount;
  final String status;
  final String? paidDate;

  Installment({
    required this.id,
    required this.installmentNumber,
    required this.dueDate,
    required this.originalAmount,
    required this.paidAmount,
    required this.remainingAmount,
    required this.status,
    this.paidDate,
  });

  factory Installment.fromJson(Map<String, dynamic> json) {
    return Installment(
      id: json['id'] ?? '',
      installmentNumber: json['installmentNumber'] ?? json['installment Number'] ?? 0,
      dueDate: json['dueDate'] ?? '',
      originalAmount: json['originalAmount'] ?? 0,
      paidAmount: json['paidAmount'] ?? 0,
      remainingAmount: json['remainingAmount'] ?? 0,
      status: json['status'] ?? '',
      paidDate: json['paidDate'],
    );
  }
}

class CustomerPayment {
  final String id;
  final String displayId;
  final num amount;
  final String paymentMethod;
  final String referenceNumber;
  final String collectedAt;

  CustomerPayment({
    required this.id,
    required this.displayId,
    required this.amount,
    required this.paymentMethod,
    required this.referenceNumber,
    required this.collectedAt,
  });

  factory CustomerPayment.fromJson(Map<String, dynamic> json) {
    return CustomerPayment(
      id: json['id'] ?? '',
      displayId: json['displayId'] ?? '',
      amount: json['amount'] ?? 0,
      paymentMethod: json['paymentMethod'] ?? json['payment Method'] ?? '',
      referenceNumber: json['referenceNumber'] ?? '',
      collectedAt: json['collectedAt'] ?? '',
    );
  }
}
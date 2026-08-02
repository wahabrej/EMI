class CustomerPaymentHistoryModel {
  final String? id;
  final String? displayId;
  final String? loanId;
  final num? amount;
  final num? allocatedAmount;
  final num? unappliedAmount;
  final String? paymentMethod;
  final String? referenceNumber;
  final String? receiptUrl;
  final String? remarks;
  final String? collectedAt;
  final LoanShortInfo? loan;
  final List<PaymentAllocation>? allocations;

  CustomerPaymentHistoryModel({
    this.id,
    this.displayId,
    this.loanId,
    this.amount,
    this.allocatedAmount,
    this.unappliedAmount,
    this.paymentMethod,
    this.referenceNumber,
    this.receiptUrl,
    this.remarks,
    this.collectedAt,
    this.loan,
    this.allocations,
  });

  factory CustomerPaymentHistoryModel.fromJson(Map<String, dynamic> json) {
    return CustomerPaymentHistoryModel(
      id: json['id']?.toString(),
      displayId: json['displayId']?.toString(),
      loanId: json['loanId']?.toString(),
      amount: _parseNum(json['amount']),
      allocatedAmount: _parseNum(json['allocatedAmount']),
      unappliedAmount: _parseNum(json['unappliedAmount']),
      paymentMethod: json['paymentMethod']?.toString(),
      referenceNumber: json['referenceNumber']?.toString(),
      receiptUrl: json['receiptUrl']?.toString(),
      remarks: json['remarks']?.toString(),
      collectedAt: json['collectedAt']?.toString(),
      loan: json['loan'] != null ? LoanShortInfo.fromJson(json['loan']) : null,
      allocations: json['allocations'] != null
          ? List<PaymentAllocation>.from(
              json['allocations'].map((x) => PaymentAllocation.fromJson(x)))
          : null,
    );
  }
}

class LoanShortInfo {
  final String? id;
  final String? displayId;
  final String? status;

  LoanShortInfo({this.id, this.displayId, this.status});

  factory LoanShortInfo.fromJson(Map<String, dynamic> json) {
    return LoanShortInfo(
      id: json['id']?.toString(),
      displayId: json['displayId']?.toString(),
      status: json['status']?.toString(),
    );
  }
}

class PaymentAllocation {
  final String? id;
  final String? installmentId;
  final int? installmentNumber;
  final num? amount;
  final num? penaltyAmount;
  final num? installmentAmount;
  final num? cashbackAmount;

  PaymentAllocation({
    this.id,
    this.installmentId,
    this.installmentNumber,
    this.amount,
    this.penaltyAmount,
    this.installmentAmount,
    this.cashbackAmount,
  });

  factory PaymentAllocation.fromJson(Map<String, dynamic> json) {
    return PaymentAllocation(
      id: json['id']?.toString(),
      installmentId: json['installmentId']?.toString(),
      installmentNumber: _parseInt(json['installmentNumber']),
      amount: _parseNum(json['amount']),
      penaltyAmount: _parseNum(json['penaltyAmount']),
      installmentAmount: _parseNum(json['installmentAmount']),
      cashbackAmount: _parseNum(json['cashbackAmount']),
    );
  }
}

num? _parseNum(dynamic value) {
  if (value == null) return null;
  if (value is num) return value;
  if (value is String) return num.tryParse(value);
  return null;
}

int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  return null;
}

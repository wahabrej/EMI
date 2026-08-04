class PaymentHistoryModel {
  bool? success;
  List<Data>? data;

  PaymentHistoryModel({this.success, this.data});

  PaymentHistoryModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? id;
  String? displayId;
  String? loanId;
  String? collectedById;
  String? amount;
  String? allocatedAmount;
  String? unappliedAmount;
  String? paymentMethod;
  String? referenceNumber;
  String? bankAccountName;
  String? bankAccountNumber;
  String? bankName;
  String? receiptFileName;
  String? receiptOriginalName;
  String? receiptMimeType;
  int? receiptSize;
  String? receiptPath;
  String? receiptUrl;
  String? remarks;
  String? collectedAt;
  String? status;
  String? submittedById;
  String? requestedInstallmentId;
  String? decidedById;
  String? decisionAt;
  String? approvalRemarks;
  String? rejectionReason;
  String? createdAt;
  String? updatedAt;
  Loan? loan;
  String? collectedBy;
  List<dynamic>? allocations;

  Data({
    this.id,
    this.displayId,
    this.loanId,
    this.collectedById,
    this.amount,
    this.allocatedAmount,
    this.unappliedAmount,
    this.paymentMethod,
    this.referenceNumber,
    this.bankAccountName,
    this.bankAccountNumber,
    this.bankName,
    this.receiptFileName,
    this.receiptOriginalName,
    this.receiptMimeType,
    this.receiptSize,
    this.receiptPath,
    this.receiptUrl,
    this.remarks,
    this.collectedAt,
    this.status,
    this.submittedById,
    this.requestedInstallmentId,
    this.decidedById,
    this.decisionAt,
    this.approvalRemarks,
    this.rejectionReason,
    this.createdAt,
    this.updatedAt,
    this.loan,
    this.collectedBy,
    this.allocations,
  });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    displayId = json['displayId'];
    loanId = json['loanId'];
    collectedById = json['collectedById']?.toString();
    amount = json['amount'];
    allocatedAmount = json['allocatedAmount'];
    unappliedAmount = json['unappliedAmount'];
    paymentMethod = json['paymentMethod'];
    referenceNumber = json['referenceNumber'];
    bankAccountName = json['bankAccountName'];
    bankAccountNumber = json['bankAccountNumber'];
    bankName = json['bankName'];
    receiptFileName = json['receiptFileName'];
    receiptOriginalName = json['receiptOriginalName'];
    receiptMimeType = json['receiptMimeType'];
    receiptSize = json['receiptSize'];
    receiptPath = json['receiptPath'];
    receiptUrl = json['receiptUrl'];
    remarks = json['remarks'];
    collectedAt = json['collectedAt'];
    status = json['status'];
    submittedById = json['submittedById'];
    requestedInstallmentId = json['requestedInstallmentId'];
    decidedById = json['decidedById']?.toString();
    decisionAt = json['decisionAt']?.toString();
    approvalRemarks = json['approvalRemarks']?.toString();
    rejectionReason = json['rejectionReason']?.toString();
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    loan = json['loan'] != null ? Loan.fromJson(json['loan']) : null;
    collectedBy = json['collectedBy']?.toString();
    allocations = json['allocations'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['displayId'] = displayId;
    data['loanId'] = loanId;
    data['collectedById'] = collectedById;
    data['amount'] = amount;
    data['allocatedAmount'] = allocatedAmount;
    data['unappliedAmount'] = unappliedAmount;
    data['paymentMethod'] = paymentMethod;
    data['referenceNumber'] = referenceNumber;
    data['bankAccountName'] = bankAccountName;
    data['bankAccountNumber'] = bankAccountNumber;
    data['bankName'] = bankName;
    data['receiptFileName'] = receiptFileName;
    data['receiptOriginalName'] = receiptOriginalName;
    data['receiptMimeType'] = receiptMimeType;
    data['receiptSize'] = receiptSize;
    data['receiptPath'] = receiptPath;
    data['receiptUrl'] = receiptUrl;
    data['remarks'] = remarks;
    data['collectedAt'] = collectedAt;
    data['status'] = status;
    data['submittedById'] = submittedById;
    data['requestedInstallmentId'] = requestedInstallmentId;
    data['decidedById'] = decidedById;
    data['decisionAt'] = decisionAt;
    data['approvalRemarks'] = approvalRemarks;
    data['rejectionReason'] = rejectionReason;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    if (loan != null) {
      data['loan'] = loan!.toJson();
    }
    data['collectedBy'] = collectedBy;
    data['allocations'] = allocations;
    return data;
  }
}

class Loan {
  String? id;
  String? displayId;
  String? status;
  Customer? customer;

  Loan({this.id, this.displayId, this.status, this.customer});

  Loan.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    displayId = json['displayId'];
    status = json['status'];
    customer = json['customer'] != null
        ? Customer.fromJson(json['customer'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['displayId'] = displayId;
    data['status'] = status;
    if (customer != null) {
      data['customer'] = customer!.toJson();
    }
    return data;
  }
}

class Customer {
  String? id;
  String? displayId;
  String? name;
  String? phone;

  Customer({this.id, this.displayId, this.name, this.phone});

  Customer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    displayId = json['displayId'];
    name = json['name'];
    phone = json['phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['displayId'] = displayId;
    data['name'] = name;
    data['phone'] = phone;
    return data;
  }
}
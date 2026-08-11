class LoanApplicationDetailModel {
  bool? success;
  LoanDetailData? data;

  LoanApplicationDetailModel({this.success, this.data});

  LoanApplicationDetailModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? LoanDetailData.fromJson(json['data']) : null;
  }
}

class LoanDetailData {
  String? id;
  String? displayId;
  String? name;
  String? phone;
  String? presentAddress;
  String? permanentAddress;
  String? idType;
  String? nidPassportNumber;
  String? sourceOfIncome;
  num? monthlyIncome;
  String? status;
  String? issueDate;
  String? customerImage;
  String? customerNidFront;
  String? customerNidBack;
  String? incomeProofDocument;
  String? incomeProofDocumentType;

  ProductInfo? product;
  num? mrp;
  num? downPayment;
  String? downPaymentMethod;
  int? planMonths;
  num? monthlyEmi;
  num? emiCharge;
  num? financedAmount;
  num? totalPayable;

  List<GuarantorDetail>? guarantors;

  String? rejectionReason;
  String? approvalRemarks;
  String? createdAt;

  LoanDetailData({
    this.id,
    this.displayId,
    this.name,
    this.phone,
    this.presentAddress,
    this.permanentAddress,
    this.idType,
    this.nidPassportNumber,
    this.sourceOfIncome,
    this.monthlyIncome,
    this.status,
    this.issueDate,
    this.customerImage,
    this.customerNidFront,
    this.customerNidBack,
    this.incomeProofDocument,
    this.incomeProofDocumentType,
    this.product,
    this.mrp,
    this.downPayment,
    this.downPaymentMethod,
    this.planMonths,
    this.monthlyEmi,
    this.emiCharge,
    this.financedAmount,
    this.totalPayable,
    this.guarantors,
    this.rejectionReason,
    this.approvalRemarks,
    this.createdAt,
  });

  LoanDetailData.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    displayId = json['displayId']?.toString();

    // ─── Customer Data (Active Loan থেকে customer অবজেক্টে থাকে) ───
    final customer = json['customer'];
    if (customer != null) {
      name = customer['name']?.toString();
      phone = customer['phone']?.toString();
      presentAddress = customer['presentAddress']?.toString();
      permanentAddress = customer['permanentAddress']?.toString();
      nidPassportNumber = customer['nidPassportNumber']?.toString();
      sourceOfIncome = customer['sourceOfIncome']?.toString();
      monthlyIncome = _parseNum(customer['monthlyIncome']);
      customerImage = customer['customerImageUrl']?.toString();
    } else {
      // Loan Application থেকে direct fields
      name = json['name']?.toString();
      phone = json['phone']?.toString();
      presentAddress = json['presentAddress']?.toString();
      permanentAddress = json['permanentAddress']?.toString();
      nidPassportNumber = json['nidPassportNumber']?.toString();
      sourceOfIncome = json['sourceOfIncome']?.toString();
      monthlyIncome = _parseNum(json['monthlyIncome']);
      customerImage = json['customerImage']?.toString();
      customerNidFront = json['customerNidFront']?.toString();
      customerNidBack = json['customerNidBack']?.toString();
    }

    idType = json['idType']?.toString() ?? 'NID';
    status = json['status']?.toString();
    issueDate = json['issueDate']?.toString();
    incomeProofDocument = json['incomeProofDocument']?.toString();
    incomeProofDocumentType = json['incomeProofDocumentType']?.toString();
    createdAt = json['createdAt']?.toString();

    // ─── Product Data ───
    if (json['product'] != null) {
      product = ProductInfo.fromJson(json['product']);
    } else if (json['productModel'] != null) {
      // Active Loan থেকে productModel
      final productModel = json['productModel'];
      product = ProductInfo(
        id: productModel['id']?.toString(),
        name: productModel['name']?.toString(),
        code: productModel['code']?.toString(),
      );
    }

    // ─── Calculation Data ───
    final snapshot = json['calculationSnapshot'];
    if (snapshot != null) {
      // Active Loan থেকে calculationSnapshot
      mrp = _parseNum(snapshot['regularPrice']);
      downPayment = _parseNum(snapshot['downPaymentAmount']) ?? _parseNum(snapshot['initialPaymentAmount']);
      monthlyEmi = _parseNum(snapshot['monthlyEmi']) ?? _parseNum(snapshot['monthlyInstallment']);
      planMonths = _parseInt(snapshot['planMonths']);
      emiCharge = _parseNum(snapshot['appEmiChargeAmount']);
      financedAmount = _parseNum(snapshot['financedAmount']);
      totalPayable = _parseNum(snapshot['totalAfterCashback']) ?? _parseNum(snapshot['totalScheduledPayable']);
      downPaymentMethod = json['downPaymentMethod']?.toString();
    } else {
      // Loan Application থেকে direct fields
      mrp = _parseNum(json['mrp']);
      downPayment = _parseNum(json['downPayment']);
      monthlyEmi = _parseNum(json['monthlyEmi']);
      planMonths = _parseInt(json['planMonths']);
      emiCharge = _parseNum(json['emiCharge']);
      financedAmount = _parseNum(json['financedAmount']);
      totalPayable = _parseNum(json['totalPayable']);
      downPaymentMethod = json['downPaymentMethod']?.toString();
    }

    // ─── Guarantors ───
    if (json['guarantors'] != null) {
      guarantors = <GuarantorDetail>[];
      final guarantorsList = json['guarantors'] as List;
      for (var g in guarantorsList) {
        final guarantor = GuarantorDetail(
          name: g['name']?.toString(),
          phone: g['phone']?.toString(),
          relationship: g['relationship']?.toString(),
          idType: g['idType']?.toString() ?? g['documentType']?.toString() ?? 'NID',
          nidPassportNumber: g['nidPassportNumber']?.toString(),
        );

        // ─── Guarantor Documents ───
        if (g['documents'] != null && (g['documents'] as List).isNotEmpty) {
          final docs = g['documents'] as List;
          for (var doc in docs) {
            final docType = doc['documentType']?.toString() ?? '';
            final url = doc['url']?.toString();
            if (docType.contains('FRONT') || docType == 'PASSPORT') {
              guarantor.nidFront = url;
            } else if (docType.contains('BACK')) {
              guarantor.nidBack = url;
            }
          }
        } else {
          // Fallback: direct fields
          guarantor.nidFront = g['nidFront']?.toString() ?? g['documentImageUrl']?.toString();
          guarantor.nidBack = g['nidBack']?.toString();
        }

        guarantors!.add(guarantor);
      }
    }

    rejectionReason = json['rejectionReason']?.toString();
    approvalRemarks = json['approvalRemarks']?.toString();
  }
}

class ProductInfo {
  String? id;
  String? name;
  String? code;

  ProductInfo({this.id, this.name, this.code});

  ProductInfo.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    name = json['name']?.toString();
    code = json['code']?.toString();
  }
}

class GuarantorDetail {
  String? name;
  String? phone;
  String? relationship;
  String? idType;
  String? nidPassportNumber;
  String? nidFront;
  String? nidBack;

  GuarantorDetail({
    this.name,
    this.phone,
    this.relationship,
    this.idType,
    this.nidPassportNumber,
    this.nidFront,
    this.nidBack,
  });

  GuarantorDetail.fromJson(Map<String, dynamic> json) {
    name = json['name']?.toString();
    phone = json['phone']?.toString();
    relationship = json['relationship']?.toString();
    idType = json['idType']?.toString() ?? 'NID';
    nidPassportNumber = json['nidPassportNumber']?.toString();
    nidFront = json['nidFront']?.toString();
    nidBack = json['nidBack']?.toString();
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
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? (double.tryParse(value)?.toInt());
  return null;
}
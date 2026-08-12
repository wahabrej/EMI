class SingleLoanModel {
  bool? success;
  Data? data;

  SingleLoanModel({this.success, this.data});

  SingleLoanModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? id;
  String? displayId;
  String? customerId;
  String? productModelId;
  String? productId;
  String? shopId;
  String? agentId;
  String? managerId;
  String? salesPersonId;
  String? emiPlanId;
  String? productEmiPlanId;
  String? status;
  String? approvalDate;
  String? disbursementDate;
  String? completionDate;
  String? rejectionReason;
  String? createdAt;
  String? updatedAt;
  Customer? customer;
  ProductModel? productModel;
  Brand? product;
  Brand? shop;
  Brand? agent;
  Brand? manager;
  Brand? salesPerson;
  ProductEmiPlan? productEmiPlan;
  CalculationSnapshot? calculationSnapshot;
  List<DecisionHistory>? decisionHistory;
  List<Installments>? installments;

  Data({
    this.id,
    this.displayId,
    this.customerId,
    this.productModelId,
    this.productId,
    this.shopId,
    this.agentId,
    this.managerId,
    this.salesPersonId,
    this.emiPlanId,
    this.productEmiPlanId,
    this.status,
    this.approvalDate,
    this.disbursementDate,
    this.completionDate,
    this.rejectionReason,
    this.createdAt,
    this.updatedAt,
    this.customer,
    this.productModel,
    this.product,
    this.shop,
    this.agent,
    this.manager,
    this.salesPerson,
    this.productEmiPlan,
    this.calculationSnapshot,
    this.decisionHistory,
    this.installments,
  });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String?;
    displayId = json['displayId'] as String?;
    customerId = json['customerId'] as String?;
    productModelId = json['productModelId'] as String?;
    productId = json['productId'] as String?;
    shopId = json['shopId'] as String?;
    agentId = json['agentId'] as String?;
    managerId = json['managerId'] as String?;
    salesPersonId = json['salesPersonId'] as String?;
    emiPlanId = json['emiPlanId'] as String?;
    productEmiPlanId = json['productEmiPlanId'] as String?;
    status = json['status'] as String?;
    approvalDate = json['approvalDate'] as String?;
    disbursementDate = json['disbursementDate'] as String?;
    completionDate = json['completionDate'] as String?;
    rejectionReason = json['rejectionReason'] as String?;
    createdAt = json['createdAt'] as String?;
    updatedAt = json['updatedAt'] as String?;
    customer = json['customer'] != null ? Customer.fromJson(json['customer']) : null;
    productModel = json['productModel'] != null ? ProductModel.fromJson(json['productModel']) : null;
    product = json['product'] != null ? Brand.fromJson(json['product']) : null;
    shop = json['shop'] != null ? Brand.fromJson(json['shop']) : null;
    agent = json['agent'] != null ? Brand.fromJson(json['agent']) : null;
    manager = json['manager'] != null ? Brand.fromJson(json['manager']) : null;
    salesPerson = json['salesPerson'] != null ? Brand.fromJson(json['salesPerson']) : null;
    productEmiPlan = json['productEmiPlan'] != null ? ProductEmiPlan.fromJson(json['productEmiPlan']) : null;
    calculationSnapshot = json['calculationSnapshot'] != null ? CalculationSnapshot.fromJson(json['calculationSnapshot']) : null;
    if (json['decisionHistory'] != null) {
      decisionHistory = <DecisionHistory>[];
      json['decisionHistory'].forEach((v) {
        decisionHistory!.add(DecisionHistory.fromJson(v));
      });
    }
    if (json['installments'] != null) {
      installments = <Installments>[];
      json['installments'].forEach((v) {
        installments!.add(Installments.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['displayId'] = displayId;
    data['customerId'] = customerId;
    data['productModelId'] = productModelId;
    data['productId'] = productId;
    data['shopId'] = shopId;
    data['agentId'] = agentId;
    data['managerId'] = managerId;
    data['salesPersonId'] = salesPersonId;
    data['emiPlanId'] = emiPlanId;
    data['productEmiPlanId'] = productEmiPlanId;
    data['status'] = status;
    data['approvalDate'] = approvalDate;
    data['disbursementDate'] = disbursementDate;
    data['completionDate'] = completionDate;
    data['rejectionReason'] = rejectionReason;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    if (customer != null) {
      data['customer'] = customer!.toJson();
    }
    if (productModel != null) {
      data['productModel'] = productModel!.toJson();
    }
    if (product != null) {
      data['product'] = product!.toJson();
    }
    if (shop != null) {
      data['shop'] = shop!.toJson();
    }
    if (agent != null) {
      data['agent'] = agent!.toJson();
    }
    if (manager != null) {
      data['manager'] = manager!.toJson();
    }
    if (salesPerson != null) {
      data['salesPerson'] = salesPerson!.toJson();
    }
    if (productEmiPlan != null) {
      data['productEmiPlan'] = productEmiPlan!.toJson();
    }
    if (calculationSnapshot != null) {
      data['calculationSnapshot'] = calculationSnapshot!.toJson();
    }
    if (decisionHistory != null) {
      data['decisionHistory'] = decisionHistory!.map((v) => v.toJson()).toList();
    }
    if (installments != null) {
      data['installments'] = installments!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Customer {
  String? id;
  String? displayId;
  String? name;
  String? phone;
  String? presentAddress;
  String? permanentAddress;
  String? nidPassportNumber;
  String? customerImageUrl;
  String? customerImageMimeType;
  String? customerVideoUrl;
  String? customerVideoMimeType;
  String? sourceOfIncome;
  String? monthlyIncome;
  List<Guarantors>? guarantors;
  List<Documents>? documents;

  Customer({
    this.id,
    this.displayId,
    this.name,
    this.phone,
    this.presentAddress,
    this.permanentAddress,
    this.nidPassportNumber,
    this.customerImageUrl,
    this.customerImageMimeType,
    this.customerVideoUrl,
    this.customerVideoMimeType,
    this.sourceOfIncome,
    this.monthlyIncome,
    this.guarantors,
    this.documents,
  });

  Customer.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String?;
    displayId = json['displayId'] as String?;
    name = json['name'] as String?;
    phone = json['phone'] as String?;
    presentAddress = json['presentAddress'] as String?;
    permanentAddress = json['permanentAddress'] as String?;
    nidPassportNumber = json['nidPassportNumber'] as String?;
    customerImageUrl = json['customerImageUrl'] as String?;
    customerImageMimeType = json['customerImageMimeType'] as String?;
    customerVideoUrl = json['customerVideoUrl'] as String?;
    customerVideoMimeType = json['customerVideoMimeType'] as String?;
    sourceOfIncome = json['sourceOfIncome'] as String?;
    monthlyIncome = json['monthlyIncome'] as String?;
    if (json['guarantors'] != null) {
      guarantors = <Guarantors>[];
      json['guarantors'].forEach((v) {
        guarantors!.add(Guarantors.fromJson(v));
      });
    }
    if (json['documents'] != null) {
      documents = <Documents>[];
      json['documents'].forEach((v) {
        documents!.add(Documents.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['displayId'] = displayId;
    data['name'] = name;
    data['phone'] = phone;
    data['presentAddress'] = presentAddress;
    data['permanentAddress'] = permanentAddress;
    data['nidPassportNumber'] = nidPassportNumber;
    data['customerImageUrl'] = customerImageUrl;
    data['customerImageMimeType'] = customerImageMimeType;
    data['customerVideoUrl'] = customerVideoUrl;
    data['customerVideoMimeType'] = customerVideoMimeType;
    data['sourceOfIncome'] = sourceOfIncome;
    data['monthlyIncome'] = monthlyIncome;
    if (guarantors != null) {
      data['guarantors'] = guarantors!.map((v) => v.toJson()).toList();
    }
    if (documents != null) {
      data['documents'] = documents!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Guarantors {
  String? id;
  String? customerId;
  String? type;
  String? name;
  String? phone;
  String? relationship;
  String? nidPassportNumber;
  String? documentType;
  String? documentImageFileName;
  String? documentImageOriginalName;
  String? documentImageMimeType;
  int? documentImageSize;
  String? documentImagePath;
  String? documentImageUrl;
  String? createdAt;
  String? updatedAt;
  List<Documents>? documents;

  Guarantors({
    this.id,
    this.customerId,
    this.type,
    this.name,
    this.phone,
    this.relationship,
    this.nidPassportNumber,
    this.documentType,
    this.documentImageFileName,
    this.documentImageOriginalName,
    this.documentImageMimeType,
    this.documentImageSize,
    this.documentImagePath,
    this.documentImageUrl,
    this.createdAt,
    this.updatedAt,
    this.documents,
  });

  Guarantors.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String?;
    customerId = json['customerId'] as String?;
    type = json['type'] as String?;
    name = json['name'] as String?;
    phone = json['phone'] as String?;
    relationship = json['relationship'] as String?;
    nidPassportNumber = json['nidPassportNumber'] as String?;
    documentType = json['documentType'] as String?;
    documentImageFileName = json['documentImageFileName'] as String?;
    documentImageOriginalName = json['documentImageOriginalName'] as String?;
    documentImageMimeType = json['documentImageMimeType'] as String?;
    documentImageSize = json['documentImageSize'] as int?;
    documentImagePath = json['documentImagePath'] as String?;
    documentImageUrl = json['documentImageUrl'] as String?;
    createdAt = json['createdAt'] as String?;
    updatedAt = json['updatedAt'] as String?;
    if (json['documents'] != null) {
      documents = <Documents>[];
      json['documents'].forEach((v) {
        documents!.add(Documents.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['customerId'] = customerId;
    data['type'] = type;
    data['name'] = name;
    data['phone'] = phone;
    data['relationship'] = relationship;
    data['nidPassportNumber'] = nidPassportNumber;
    data['documentType'] = documentType;
    data['documentImageFileName'] = documentImageFileName;
    data['documentImageOriginalName'] = documentImageOriginalName;
    data['documentImageMimeType'] = documentImageMimeType;
    data['documentImageSize'] = documentImageSize;
    data['documentImagePath'] = documentImagePath;
    data['documentImageUrl'] = documentImageUrl;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    if (documents != null) {
      data['documents'] = documents!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Documents {
  String? id;
  String? guarantorId;
  String? documentType;
  String? fileName;
  String? originalName;
  String? mimeType;
  int? size;
  String? path;
  String? url;
  String? uploadedById;
  String? createdAt;
  String? updatedAt;

  Documents({
    this.id,
    this.guarantorId,
    this.documentType,
    this.fileName,
    this.originalName,
    this.mimeType,
    this.size,
    this.path,
    this.url,
    this.uploadedById,
    this.createdAt,
    this.updatedAt,
  });

  Documents.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String?;
    guarantorId = json['guarantorId'] as String?;
    documentType = json['documentType'] as String?;
    fileName = json['fileName'] as String?;
    originalName = json['originalName'] as String?;
    mimeType = json['mimeType'] as String?;
    size = json['size'] as int?;
    path = json['path'] as String?;
    url = json['url'] as String?;
    uploadedById = json['uploadedById'] as String?;
    createdAt = json['createdAt'] as String?;
    updatedAt = json['updatedAt'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['guarantorId'] = guarantorId;
    data['documentType'] = documentType;
    data['fileName'] = fileName;
    data['originalName'] = originalName;
    data['mimeType'] = mimeType;
    data['size'] = size;
    data['path'] = path;
    data['url'] = url;
    data['uploadedById'] = uploadedById;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}

class ProductModel {
  String? id;
  String? code;
  String? name;
  Brand? brand;
  Brand? product;

  ProductModel({this.id, this.code, this.name, this.brand, this.product});

  ProductModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String?;
    code = json['code'] as String?;
    name = json['name'] as String?;
    brand = json['brand'] != null ? Brand.fromJson(json['brand']) : null;
    product = json['product'] != null ? Brand.fromJson(json['product']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['code'] = code;
    data['name'] = name;
    if (brand != null) {
      data['brand'] = brand!.toJson();
    }
    if (product != null) {
      data['product'] = product!.toJson();
    }
    return data;
  }
}

class Brand {
  String? id;
  String? code;
  String? name;

  Brand({this.id, this.code, this.name});

  Brand.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String?;
    code = json['code'] as String?;
    name = json['name'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['code'] = code;
    data['name'] = name;
    return data;
  }
}

class ProductEmiPlan {
  String? id;
  String? name;
  int? months;
  String? displayDownPaymentPercent;
  String? downPaymentCalculationRate;
  String? appEmiChargeRate;
  String? cashbackRate;
  bool? isActive;

  ProductEmiPlan({
    this.id,
    this.name,
    this.months,
    this.displayDownPaymentPercent,
    this.downPaymentCalculationRate,
    this.appEmiChargeRate,
    this.cashbackRate,
    this.isActive,
  });

  ProductEmiPlan.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String?;
    name = json['name'] as String?;
    months = json['months'] as int?;
    displayDownPaymentPercent = json['displayDownPaymentPercent'] as String?;
    downPaymentCalculationRate = json['downPaymentCalculationRate'] as String?;
    appEmiChargeRate = json['appEmiChargeRate'] as String?;
    cashbackRate = json['cashbackRate'] as String?;
    isActive = json['isActive'] as bool?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['months'] = months;
    data['displayDownPaymentPercent'] = displayDownPaymentPercent;
    data['downPaymentCalculationRate'] = downPaymentCalculationRate;
    data['appEmiChargeRate'] = appEmiChargeRate;
    data['cashbackRate'] = cashbackRate;
    data['isActive'] = isActive;
    return data;
  }
}

class CalculationSnapshot {
  String? id;
  String? loanId;
  String? regularPrice;
  int? planMonths;
  String? downPaymentOption;
  String? initialPaymentRate;
  String? initialPaymentAmount;
  String? appEmiChargeRate;
  String? appEmiChargeAmount;
  String? cashbackRate;
  String? cashbackAmount;
  String? productEmiPlanName;
  String? displayDownPaymentPercent;
  String? downPaymentCalculationRate;
  String? downPaymentAmount;
  String? regularPayEmiChargeAmount;
  String? financedAmount;
  String? monthlyInstallment;
  String? totalScheduledPayable;
  String? effectiveTotalAfterCashback;
  String? monthlyEmi;
  String? totalBeforeCashback;
  String? totalAfterCashback;
  String? createdAt;

  CalculationSnapshot({
    this.id,
    this.loanId,
    this.regularPrice,
    this.planMonths,
    this.downPaymentOption,
    this.initialPaymentRate,
    this.initialPaymentAmount,
    this.appEmiChargeRate,
    this.appEmiChargeAmount,
    this.cashbackRate,
    this.cashbackAmount,
    this.productEmiPlanName,
    this.displayDownPaymentPercent,
    this.downPaymentCalculationRate,
    this.downPaymentAmount,
    this.regularPayEmiChargeAmount,
    this.financedAmount,
    this.monthlyInstallment,
    this.totalScheduledPayable,
    this.effectiveTotalAfterCashback,
    this.monthlyEmi,
    this.totalBeforeCashback,
    this.totalAfterCashback,
    this.createdAt,
  });

  CalculationSnapshot.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String?;
    loanId = json['loanId'] as String?;
    regularPrice = json['regularPrice'] as String?;
    planMonths = json['planMonths'] as int?;
    downPaymentOption = json['downPaymentOption'] as String?;
    initialPaymentRate = json['initialPaymentRate'] as String?;
    initialPaymentAmount = json['initialPaymentAmount'] as String?;
    appEmiChargeRate = json['appEmiChargeRate'] as String?;
    appEmiChargeAmount = json['appEmiChargeAmount'] as String?;
    cashbackRate = json['cashbackRate'] as String?;
    cashbackAmount = json['cashbackAmount'] as String?;
    productEmiPlanName = json['productEmiPlanName'] as String?;
    displayDownPaymentPercent = json['displayDownPaymentPercent'] as String?;
    downPaymentCalculationRate = json['downPaymentCalculationRate'] as String?;
    downPaymentAmount = json['downPaymentAmount'] as String?;
    regularPayEmiChargeAmount = json['regularPayEmiChargeAmount'] as String?;
    financedAmount = json['financedAmount'] as String?;
    monthlyInstallment = json['monthlyInstallment'] as String?;
    totalScheduledPayable = json['totalScheduledPayable'] as String?;
    effectiveTotalAfterCashback = json['effectiveTotalAfterCashback'] as String?;
    monthlyEmi = json['monthlyEmi'] as String?;
    totalBeforeCashback = json['totalBeforeCashback'] as String?;
    totalAfterCashback = json['totalAfterCashback'] as String?;
    createdAt = json['createdAt'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['loanId'] = loanId;
    data['regularPrice'] = regularPrice;
    data['planMonths'] = planMonths;
    data['downPaymentOption'] = downPaymentOption;
    data['initialPaymentRate'] = initialPaymentRate;
    data['initialPaymentAmount'] = initialPaymentAmount;
    data['appEmiChargeRate'] = appEmiChargeRate;
    data['appEmiChargeAmount'] = appEmiChargeAmount;
    data['cashbackRate'] = cashbackRate;
    data['cashbackAmount'] = cashbackAmount;
    data['productEmiPlanName'] = productEmiPlanName;
    data['displayDownPaymentPercent'] = displayDownPaymentPercent;
    data['downPaymentCalculationRate'] = downPaymentCalculationRate;
    data['downPaymentAmount'] = downPaymentAmount;
    data['regularPayEmiChargeAmount'] = regularPayEmiChargeAmount;
    data['financedAmount'] = financedAmount;
    data['monthlyInstallment'] = monthlyInstallment;
    data['totalScheduledPayable'] = totalScheduledPayable;
    data['effectiveTotalAfterCashback'] = effectiveTotalAfterCashback;
    data['monthlyEmi'] = monthlyEmi;
    data['totalBeforeCashback'] = totalBeforeCashback;
    data['totalAfterCashback'] = totalAfterCashback;
    data['createdAt'] = createdAt;
    return data;
  }
}

class DecisionHistory {
  String? id;
  String? loanId;
  String? decisionStatus;
  String? decidedById;
  String? decisionAt;
  String? approvalRemarks;
  String? rejectionReason;
  String? approvedInitialPayment;
  String? approvedMonthlyEmi;
  String? createdAt;
  DecidedBy? decidedBy;

  DecisionHistory({
    this.id,
    this.loanId,
    this.decisionStatus,
    this.decidedById,
    this.decisionAt,
    this.approvalRemarks,
    this.rejectionReason,
    this.approvedInitialPayment,
    this.approvedMonthlyEmi,
    this.createdAt,
    this.decidedBy,
  });

  DecisionHistory.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String?;
    loanId = json['loanId'] as String?;
    decisionStatus = json['decisionStatus'] as String?;
    decidedById = json['decidedById'] as String?;
    decisionAt = json['decisionAt'] as String?;
    approvalRemarks = json['approvalRemarks'] as String?;
    rejectionReason = json['rejectionReason'] as String?;
    approvedInitialPayment = json['approvedInitialPayment'] as String?;
    approvedMonthlyEmi = json['approvedMonthlyEmi'] as String?;
    createdAt = json['createdAt'] as String?;
    decidedBy = json['decidedBy'] != null ? DecidedBy.fromJson(json['decidedBy']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['loanId'] = loanId;
    data['decisionStatus'] = decisionStatus;
    data['decidedById'] = decidedById;
    data['decisionAt'] = decisionAt;
    data['approvalRemarks'] = approvalRemarks;
    data['rejectionReason'] = rejectionReason;
    data['approvedInitialPayment'] = approvedInitialPayment;
    data['approvedMonthlyEmi'] = approvedMonthlyEmi;
    data['createdAt'] = createdAt;
    if (decidedBy != null) {
      data['decidedBy'] = decidedBy!.toJson();
    }
    return data;
  }
}

class DecidedBy {
  String? id;
  String? name;
  String? email;
  String? staffEntityType;

  DecidedBy({this.id, this.name, this.email, this.staffEntityType});

  DecidedBy.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String?;
    name = json['name'] as String?;
    email = json['email'] as String?;
    staffEntityType = json['staffEntityType'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['staffEntityType'] = staffEntityType;
    return data;
  }
}

class Installments {
  String? id;
  String? loanId;
  int? installmentNumber;
  String? dueDate;
  String? originalAmount;
  String? paidAmount;
  String? remainingAmount;
  String? penaltyAmount;
  String? totalDue;
  String? cashbackAmount;
  String? cashbackStatus;
  String? cashbackAppliedAt;
  String? cashbackForfeitedAt;
  String? status;
  String? paidDate;
  String? createdAt;
  String? updatedAt;
  List<PaymentAllocations>? paymentAllocations;

  Installments({
    this.id,
    this.loanId,
    this.installmentNumber,
    this.dueDate,
    this.originalAmount,
    this.paidAmount,
    this.remainingAmount,
    this.penaltyAmount,
    this.totalDue,
    this.cashbackAmount,
    this.cashbackStatus,
    this.cashbackAppliedAt,
    this.cashbackForfeitedAt,
    this.status,
    this.paidDate,
    this.createdAt,
    this.updatedAt,
    this.paymentAllocations,
  });

  Installments.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String?;
    loanId = json['loanId'] as String?;
    installmentNumber = json['installmentNumber'] as int?;
    dueDate = json['dueDate'] as String?;
    originalAmount = json['originalAmount'] as String?;
    paidAmount = json['paidAmount'] as String?;
    remainingAmount = json['remainingAmount'] as String?;
    penaltyAmount = json['penaltyAmount'] as String?;
    totalDue = json['totalDue'] as String?;
    cashbackAmount = json['cashbackAmount'] as String?;
    cashbackStatus = json['cashbackStatus'] as String?;
    cashbackAppliedAt = json['cashbackAppliedAt'] as String?;
    cashbackForfeitedAt = json['cashbackForfeitedAt'] as String?;
    status = json['status'] as String?;
    paidDate = json['paidDate'] as String?;
    createdAt = json['createdAt'] as String?;
    updatedAt = json['updatedAt'] as String?;
    if (json['paymentAllocations'] != null) {
      paymentAllocations = <PaymentAllocations>[];
      json['paymentAllocations'].forEach((v) {
        paymentAllocations!.add(PaymentAllocations.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['loanId'] = loanId;
    data['installmentNumber'] = installmentNumber;
    data['dueDate'] = dueDate;
    data['originalAmount'] = originalAmount;
    data['paidAmount'] = paidAmount;
    data['remainingAmount'] = remainingAmount;
    data['penaltyAmount'] = penaltyAmount;
    data['totalDue'] = totalDue;
    data['cashbackAmount'] = cashbackAmount;
    data['cashbackStatus'] = cashbackStatus;
    data['cashbackAppliedAt'] = cashbackAppliedAt;
    data['cashbackForfeitedAt'] = cashbackForfeitedAt;
    data['status'] = status;
    data['paidDate'] = paidDate;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    if (paymentAllocations != null) {
      data['paymentAllocations'] = paymentAllocations!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PaymentAllocations {
  String? id;
  String? paymentId;
  String? installmentId;
  int? installmentNumber;
  String? amount;
  String? penaltyAmount;
  String? installmentAmount;
  String? cashbackAmount;
  String? createdAt;
  Payment? payment;

  PaymentAllocations({
    this.id,
    this.paymentId,
    this.installmentId,
    this.installmentNumber,
    this.amount,
    this.penaltyAmount,
    this.installmentAmount,
    this.cashbackAmount,
    this.createdAt,
    this.payment,
  });

  PaymentAllocations.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String?;
    paymentId = json['paymentId'] as String?;
    installmentId = json['installmentId'] as String?;
    installmentNumber = json['installmentNumber'] as int?;
    amount = json['amount'] as String?;
    penaltyAmount = json['penaltyAmount'] as String?;
    installmentAmount = json['installmentAmount'] as String?;
    cashbackAmount = json['cashbackAmount'] as String?;
    createdAt = json['createdAt'] as String?;
    payment = json['payment'] != null ? Payment.fromJson(json['payment']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['paymentId'] = paymentId;
    data['installmentId'] = installmentId;
    data['installmentNumber'] = installmentNumber;
    data['amount'] = amount;
    data['penaltyAmount'] = penaltyAmount;
    data['installmentAmount'] = installmentAmount;
    data['cashbackAmount'] = cashbackAmount;
    data['createdAt'] = createdAt;
    if (payment != null) {
      data['payment'] = payment!.toJson();
    }
    return data;
  }
}

class Payment {
  String? paymentMethod;
  String? collectedAt;

  Payment({this.paymentMethod, this.collectedAt});

  Payment.fromJson(Map<String, dynamic> json) {
    paymentMethod = json['paymentMethod'] as String?;
    collectedAt = json['collectedAt'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['paymentMethod'] = paymentMethod;
    data['collectedAt'] = collectedAt;
    return data;
  }
}
class CustomerLoanModel {
  bool? success;
  List<Data>? data;

  CustomerLoanModel({this.success, this.data});

  CustomerLoanModel.fromJson(Map<String, dynamic> json) {
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
  dynamic emiPlan;
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
    this.emiPlan,
    this.productEmiPlan,
    this.calculationSnapshot,
    this.decisionHistory,
    this.installments,
  });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    displayId = json['displayId'];
    customerId = json['customerId'];
    productModelId = json['productModelId'];
    productId = json['productId'];
    shopId = json['shopId'];
    agentId = json['agentId'];
    managerId = json['managerId'];
    salesPersonId = json['salesPersonId'];
    emiPlanId = json['emiPlanId'];
    productEmiPlanId = json['productEmiPlanId'];
    status = json['status'];
    approvalDate = json['approvalDate'];
    disbursementDate = json['disbursementDate'];
    completionDate = json['completionDate'];
    rejectionReason = json['rejectionReason'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    customer = json['customer'] != null ? Customer.fromJson(json['customer']) : null;
    productModel = json['productModel'] != null ? ProductModel.fromJson(json['productModel']) : null;
    product = json['product'] != null ? Brand.fromJson(json['product']) : null;
    shop = json['shop'] != null ? Brand.fromJson(json['shop']) : null;
    agent = json['agent'] != null ? Brand.fromJson(json['agent']) : null;
    manager = json['manager'] != null ? Brand.fromJson(json['manager']) : null;
    salesPerson = json['salesPerson'] != null ? Brand.fromJson(json['salesPerson']) : null;
    emiPlan = json['emiPlan'];
    productEmiPlan = json['productEmiPlan'] != null ? ProductEmiPlan.fromJson(json['productEmiPlan']) : null;
    calculationSnapshot = json['calculationSnapshot'] != null
        ? CalculationSnapshot.fromJson(json['calculationSnapshot'])
        : null;
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
    if (customer != null) data['customer'] = customer!.toJson();
    if (productModel != null) data['productModel'] = productModel!.toJson();
    if (product != null) data['product'] = product!.toJson();
    if (shop != null) data['shop'] = shop!.toJson();
    if (agent != null) data['agent'] = agent!.toJson();
    if (manager != null) data['manager'] = manager!.toJson();
    if (salesPerson != null) data['salesPerson'] = salesPerson!.toJson();
    data['emiPlan'] = emiPlan;
    if (productEmiPlan != null) data['productEmiPlan'] = productEmiPlan!.toJson();
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
  String? sourceOfIncome;
  String? monthlyIncome;

  Customer({
    this.id,
    this.displayId,
    this.name,
    this.phone,
    this.presentAddress,
    this.permanentAddress,
    this.nidPassportNumber,
    this.customerImageUrl,
    this.sourceOfIncome,
    this.monthlyIncome,
  });

  Customer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    displayId = json['displayId'];
    name = json['name'];
    phone = json['phone'];
    presentAddress = json['presentAddress'];
    permanentAddress = json['permanentAddress'];
    nidPassportNumber = json['nidPassportNumber'];
    customerImageUrl = json['customerImageUrl'];
    sourceOfIncome = json['sourceOfIncome'];
    monthlyIncome = json['monthlyIncome'];
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
    data['sourceOfIncome'] = sourceOfIncome;
    data['monthlyIncome'] = monthlyIncome;
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
    id = json['id'];
    code = json['code'];
    name = json['name'];
    brand = json['brand'] != null ? Brand.fromJson(json['brand']) : null;
    product = json['product'] != null ? Brand.fromJson(json['product']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['code'] = code;
    data['name'] = name;
    if (brand != null) data['brand'] = brand!.toJson();
    if (product != null) data['product'] = product!.toJson();
    return data;
  }
}

class Brand {
  String? id;
  String? code;
  String? name;

  Brand({this.id, this.code, this.name});

  Brand.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    name = json['name'];
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
    id = json['id'];
    name = json['name'];
    months = json['months'];
    displayDownPaymentPercent = json['displayDownPaymentPercent'];
    downPaymentCalculationRate = json['downPaymentCalculationRate'];
    appEmiChargeRate = json['appEmiChargeRate'];
    cashbackRate = json['cashbackRate'];
    isActive = json['isActive'];
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
    id = json['id'];
    loanId = json['loanId'];
    regularPrice = json['regularPrice'];
    planMonths = json['planMonths'];
    downPaymentOption = json['downPaymentOption'];
    initialPaymentRate = json['initialPaymentRate'];
    initialPaymentAmount = json['initialPaymentAmount'];
    appEmiChargeRate = json['appEmiChargeRate'];
    appEmiChargeAmount = json['appEmiChargeAmount'];
    cashbackRate = json['cashbackRate'];
    cashbackAmount = json['cashbackAmount'];
    productEmiPlanName = json['productEmiPlanName'];
    displayDownPaymentPercent = json['displayDownPaymentPercent'];
    downPaymentCalculationRate = json['downPaymentCalculationRate'];
    downPaymentAmount = json['downPaymentAmount'];
    regularPayEmiChargeAmount = json['regularPayEmiChargeAmount'];
    financedAmount = json['financedAmount'];
    monthlyInstallment = json['monthlyInstallment'];
    totalScheduledPayable = json['totalScheduledPayable'];
    effectiveTotalAfterCashback = json['effectiveTotalAfterCashback'];
    monthlyEmi = json['monthlyEmi'];
    totalBeforeCashback = json['totalBeforeCashback'];
    totalAfterCashback = json['totalAfterCashback'];
    createdAt = json['createdAt'];
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
    id = json['id'];
    loanId = json['loanId'];
    decisionStatus = json['decisionStatus'];
    decidedById = json['decidedById'];
    decisionAt = json['decisionAt'];
    approvalRemarks = json['approvalRemarks'];
    rejectionReason = json['rejectionReason'];
    approvedInitialPayment = json['approvedInitialPayment'];
    approvedMonthlyEmi = json['approvedMonthlyEmi'];
    createdAt = json['createdAt'];
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
    if (decidedBy != null) data['decidedBy'] = decidedBy!.toJson();
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
    id = json['id'];
    name = json['name'];
    email = json['email'];
    staffEntityType = json['staffEntityType'];
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
  List<dynamic>? paymentAllocations;

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
    id = json['id'];
    loanId = json['loanId'];
    installmentNumber = json['installmentNumber'];
    dueDate = json['dueDate'];
    originalAmount = json['originalAmount'];
    paidAmount = json['paidAmount'];
    remainingAmount = json['remainingAmount'];
    penaltyAmount = json['penaltyAmount'];
    totalDue = json['totalDue'];
    cashbackAmount = json['cashbackAmount'];
    cashbackStatus = json['cashbackStatus'];
    cashbackAppliedAt = json['cashbackAppliedAt'];
    cashbackForfeitedAt = json['cashbackForfeitedAt'];
    status = json['status'];
    paidDate = json['paidDate'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    if (json['paymentAllocations'] != null) {
      paymentAllocations = List<dynamic>.from(json['paymentAllocations']);
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
      data['paymentAllocations'] = paymentAllocations;
    }
    return data;
  }
}
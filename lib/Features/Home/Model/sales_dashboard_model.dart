// sales_dashboard_model.dart

class SalesDashboardModel {
  bool? success;
  Data? data;

  SalesDashboardModel({this.success, this.data});

  SalesDashboardModel.fromJson(Map<String, dynamic> json) {
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
  Stats? stats;
  List<LoanStatusDistribution>? loanStatusDistribution;
  List<RecentPayments>? recentPayments;
  List<RecentApplications>? recentApplications;
  List<Products>? products;

  Data({
    this.stats,
    this.loanStatusDistribution,
    this.recentPayments,
    this.recentApplications,
    this.products,
  });

  Data.fromJson(Map<String, dynamic> json) {
    stats = json['stats'] != null ? Stats.fromJson(json['stats']) : null;

    if (json['loanStatusDistribution'] != null) {
      loanStatusDistribution = <LoanStatusDistribution>[];
      json['loanStatusDistribution'].forEach((v) {
        loanStatusDistribution!.add(LoanStatusDistribution.fromJson(v));
      });
    }

    if (json['recentPayments'] != null) {
      recentPayments = <RecentPayments>[];
      json['recentPayments'].forEach((v) {
        recentPayments!.add(RecentPayments.fromJson(v));
      });
    }

    // API Payload e 'recentApplications' kinba 'applications' jekono ekta asle catch korbe
    final rawApps = json['recentApplications'] ?? json['applications'];
    if (rawApps != null && rawApps is List) {
      recentApplications = <RecentApplications>[];
      for (var v in rawApps) {
        recentApplications!.add(RecentApplications.fromJson(v));
      }
    }

    if (json['products'] != null) {
      products = <Products>[];
      json['products'].forEach((v) {
        products!.add(Products.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (stats != null) {
      data['stats'] = stats!.toJson();
    }
    if (loanStatusDistribution != null) {
      data['loanStatusDistribution'] =
          loanStatusDistribution!.map((v) => v.toJson()).toList();
    }
    if (recentPayments != null) {
      data['recentPayments'] =
          recentPayments!.map((v) => v.toJson()).toList();
    }
    if (recentApplications != null) {
      data['recentApplications'] =
          recentApplications!.map((v) => v.toJson()).toList();
    }
    if (products != null) {
      data['products'] = products!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Stats {
  int? totalCustomers;
  int? activeLoans;
  int? pendingApplications;
  num? totalCollections; // Safe Type: num
  int? overdueLoans;

  Stats({
    this.totalCustomers,
    this.activeLoans,
    this.pendingApplications,
    this.totalCollections,
    this.overdueLoans,
  });

  Stats.fromJson(Map<String, dynamic> json) {
    totalCustomers = _parseInt(json['totalCustomers']);
    activeLoans = _parseInt(json['activeLoans']);
    pendingApplications = _parseInt(json['pendingApplications']);
    totalCollections = _parseNum(json['totalCollections']);
    overdueLoans = _parseInt(json['overdueLoans']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['totalCustomers'] = totalCustomers;
    data['activeLoans'] = activeLoans;
    data['pendingApplications'] = pendingApplications;
    data['totalCollections'] = totalCollections;
    data['overdueLoans'] = overdueLoans;
    return data;
  }
}

class LoanStatusDistribution {
  String? status;
  int? count;

  LoanStatusDistribution({this.status, this.count});

  LoanStatusDistribution.fromJson(Map<String, dynamic> json) {
    status = json['status']?.toString();
    count = _parseInt(json['count']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['count'] = count;
    return data;
  }
}

class RecentPayments {
  String? id;
  String? displayId;
  num? amount; // Safe Type: num
  String? paymentMethod;
  String? referenceNumber;
  String? collectedAt;
  Loan? loan;

  RecentPayments({
    this.id,
    this.displayId,
    this.amount,
    this.paymentMethod,
    this.referenceNumber,
    this.collectedAt,
    this.loan,
  });

  RecentPayments.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    displayId = json['displayId']?.toString();
    amount = _parseNum(json['amount']);
    paymentMethod = (json['paymentMethod'] ?? json['payment Method'])?.toString();
    referenceNumber = json['referenceNumber']?.toString();
    collectedAt = json['collectedAt']?.toString();
    loan = json['loan'] != null ? Loan.fromJson(json['loan']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['displayId'] = displayId;
    data['amount'] = amount;
    data['paymentMethod'] = paymentMethod;
    data['referenceNumber'] = referenceNumber;
    data['collectedAt'] = collectedAt;
    if (loan != null) {
      data['loan'] = loan!.toJson();
    }
    return data;
  }
}

class Loan {
  String? displayId;
  Customer? customer;

  Loan({this.displayId, this.customer});

  Loan.fromJson(Map<String, dynamic> json) {
    displayId = json['displayId']?.toString();
    customer = json['customer'] != null ? Customer.fromJson(json['customer']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['displayId'] = displayId;
    if (customer != null) {
      data['customer'] = customer!.toJson();
    }
    return data;
  }
}

class Customer {
  String? name;
  String? phone;

  Customer({this.name, this.phone});

  Customer.fromJson(Map<String, dynamic> json) {
    name = json['name']?.toString();
    phone = json['phone']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['phone'] = phone;
    return data;
  }
}

class RecentApplications {
  String? id;
  String? displayId;
  String? name;
  String? phone;
  String? status;
  num? mrp; // Safe Type: num
  num? monthlyEmi; // Safe Type: num

  RecentApplications({
    this.id,
    this.displayId,
    this.name,
    this.phone,
    this.status,
    this.mrp,
    this.monthlyEmi,
  });

  RecentApplications.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    displayId = json['displayId']?.toString();
    name = json['name']?.toString();
    phone = json['phone']?.toString();
    status = json['status']?.toString();
    mrp = _parseNum(json['mrp']);
    monthlyEmi = _parseNum(json['monthlyEmi']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['displayId'] = displayId;
    data['name'] = name;
    data['phone'] = phone;
    data['status'] = status;
    data['mrp'] = mrp;
    data['monthlyEmi'] = monthlyEmi;
    return data;
  }
}

class Products {
  String? id;
  String? code;
  String? name;
  num? sellingPrice; // Safe Type: num
  List<ProductModels>? productModels;

  Products({this.id, this.code, this.name, this.sellingPrice, this.productModels});

  Products.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    code = json['code']?.toString();
    name = json['name']?.toString();
    sellingPrice = _parseNum(json['sellingPrice']);
    if (json['productModels'] != null) {
      productModels = <ProductModels>[];
      json['productModels'].forEach((v) {
        productModels!.add(ProductModels.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['code'] = code;
    data['name'] = name;
    data['sellingPrice'] = sellingPrice;
    if (productModels != null) {
      data['productModels'] = productModels!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ProductModels {
  String? id;
  String? code;
  String? name;

  ProductModels({this.id, this.code, this.name});

  ProductModels.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    code = json['code']?.toString();
    name = json['name']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['code'] = code;
    data['name'] = name;
    return data;
  }
}

// ── GLOBAL HELPER FUNCTIONS FOR SAFE PARSING ──────────────────────────────────
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
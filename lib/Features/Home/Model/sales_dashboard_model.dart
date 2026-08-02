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
  int? customers;
  List<Loans>? loans;
  List<Applications>? applications;
  List<dynamic>? payments;
  List<Products>? products;


  Data.fromJson(Map<String, dynamic> json) {
    customers = json['customers'];
    if (json['loans'] != null) {
      loans = <Loans>[];
      json['loans'].forEach((v) {
        loans!.add(Loans.fromJson(v));
      });
    }
    if (json['applications'] != null) {
      applications = <Applications>[];
      json['applications'].forEach((v) {
        applications!.add(Applications.fromJson(v));
      });
    }
    if (json['payments'] != null) {
      payments = List<dynamic>.from(json['payments']);
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
    data['customers'] = customers;
    if (loans != null) {
      data['loans'] = loans!.map((v) => v.toJson()).toList();
    }
    if (applications != null) {
      data['applications'] = applications!.map((v) => v.toJson()).toList();
    }
    if (payments != null) {
      data['payments'] = payments;
    }
    if (products != null) {
      data['products'] = products!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Loans {
  String? id;
  String? displayId;
  String? status;
  String? createdAt;
  Customer? customer;
  ProductModel? productModel;
  Brand? product;
  CalculationSnapshot? calculationSnapshot;
  List<Installments>? installments;


  Loans.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    displayId = json['displayId'];
    status = json['status'];
    createdAt = json['createdAt'];
    customer = json['customer'] != null ? Customer.fromJson(json['customer']) : null;
    productModel = json['productModel'] != null ? ProductModel.fromJson(json['productModel']) : null;
    product = json['product'] != null ? Brand.fromJson(json['product']) : null;
    calculationSnapshot = json['calculationSnapshot'] != null
        ? CalculationSnapshot.fromJson(json['calculationSnapshot'])
        : null;
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
    data['status'] = status;
    data['createdAt'] = createdAt;
    if (customer != null) data['customer'] = customer!.toJson();
    if (productModel != null) data['productModel'] = productModel!.toJson();
    if (product != null) data['product'] = product!.toJson();
    if (calculationSnapshot != null) {
      data['calculationSnapshot'] = calculationSnapshot!.toJson();
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


  Customer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    displayId = json['displayId'];
    name = json['name'];
    phone = json['phone'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayId': displayId,
      'name': name,
      'phone': phone,
    };
  }
}

class ProductModel {
  String? name;
  String? code;
  Brand? brand;


  ProductModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    code = json['code'];
    brand = json['brand'] != null ? Brand.fromJson(json['brand']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['code'] = code;
    if (brand != null) data['brand'] = brand!.toJson();
    return data;
  }
}

class Brand {
  String? name;

  Brand({this.name});

  Brand.fromJson(Map<String, dynamic> json) {
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    return {'name': name};
  }
}

class CalculationSnapshot {
  String? totalAfterCashback;
  String? regularPrice;
  String? initialPaymentAmount;
  int? planMonths;
  String? monthlyEmi;



  CalculationSnapshot.fromJson(Map<String, dynamic> json) {
    totalAfterCashback = json['totalAfterCashback'];
    regularPrice = json['regularPrice'];
    initialPaymentAmount = json['initialPaymentAmount'];
    planMonths = json['planMonths'];
    monthlyEmi = json['monthlyEmi'];
  }

  Map<String, dynamic> toJson() {
    return {
      'totalAfterCashback': totalAfterCashback,
      'regularPrice': regularPrice,
      'initialPaymentAmount': initialPaymentAmount,
      'planMonths': planMonths,
      'monthlyEmi': monthlyEmi,
    };
  }
}

class Installments {
  String? status;
  String? totalDue;
  String? remainingAmount;
  String? originalAmount;
  String? dueDate;

  Installments({
    this.status,
    this.totalDue,
    this.remainingAmount,
    this.originalAmount,
    this.dueDate,
  });

  Installments.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    totalDue = json['totalDue'];
    remainingAmount = json['remainingAmount'];
    originalAmount = json['originalAmount'];
    dueDate = json['dueDate'];
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'totalDue': totalDue,
      'remainingAmount': remainingAmount,
      'originalAmount': originalAmount,
      'dueDate': dueDate,
    };
  }
}

class Applications {
  String? id;
  String? displayId;
  String? customerId;
  Customer? customer;
  String? name;
  String? phone;
  String? mrp;
  int? planMonths;
  String? status;
  String? createdAt;
  String? productModel;
  Brand? product;
  Brand? productModelRelation;

  Applications({
    this.id,
    this.displayId,
    this.customerId,
    this.customer,
    this.name,
    this.phone,
    this.mrp,
    this.planMonths,
    this.status,
    this.createdAt,
    this.productModel,
    this.product,
    this.productModelRelation,
  });

  Applications.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    displayId = json['displayId'];
    customerId = json['customerId'];
    customer = json['customer'] != null ? Customer.fromJson(json['customer']) : null;
    name = json['name'];
    phone = json['phone'];
    mrp = json['mrp'];
    planMonths = json['planMonths'];
    status = json['status'];
    createdAt = json['createdAt'];
    productModel = json['productModel'];
    product = json['product'] != null ? Brand.fromJson(json['product']) : null;
    productModelRelation = json['productModelRelation'] != null
        ? Brand.fromJson(json['productModelRelation'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['displayId'] = displayId;
    data['customerId'] = customerId;
    if (customer != null) data['customer'] = customer!.toJson();
    data['name'] = name;
    data['phone'] = phone;
    data['mrp'] = mrp;
    data['planMonths'] = planMonths;
    data['status'] = status;
    data['createdAt'] = createdAt;
    data['productModel'] = productModel;
    if (product != null) data['product'] = product!.toJson();
    if (productModelRelation != null) {
      data['productModelRelation'] = productModelRelation!.toJson();
    }
    return data;
  }
}

class Products {
  String? name;
  Brand? brand;

  Products({this.name, this.brand});

  Products.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    brand = json['brand'] != null ? Brand.fromJson(json['brand']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    if (brand != null) data['brand'] = brand!.toJson();
    return data;
  }
}
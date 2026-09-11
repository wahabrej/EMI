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

  Data({
    this.customers,
    this.loans,
    this.applications,
    this.payments,
    this.products,
  });

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
  String? id, displayId, status, createdAt;
  Customer? customer;
  ProductModel? productModel;
  Brand? product;
  CalculationSnapshot? calculationSnapshot;
  List<Installments>? installments;

  Loans({this.id, this.displayId, this.status, this.createdAt, this.customer, this.productModel, this.product, this.calculationSnapshot, this.installments});

  Loans.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    displayId = json['displayId'];
    status = json['status'];
    createdAt = json['createdAt'];
    customer = json['customer'] != null ? Customer.fromJson(json['customer']) : null;
    productModel = json['productModel'] != null ? ProductModel.fromJson(json['productModel']) : null;
    product = json['product'] != null ? Brand.fromJson(json['product']) : null;
    calculationSnapshot = json['calculationSnapshot'] != null ? CalculationSnapshot.fromJson(json['calculationSnapshot']) : null;
    if (json['installments'] != null) {
      installments = <Installments>[];
      json['installments'].forEach((v) => installments!.add(Installments.fromJson(v)));
    }
    
    // 📌 লোন লেভেলে থাকা ইমেজ কাস্টমারে কপি করা
    String? backupImg = json['profileImage']?.toString() ?? 
                        json['customerImageUrl']?.toString() ?? 
                        json['customerImage']?.toString() ?? 
                        json['photo']?.toString();
    if (customer != null && (customer!.profileImage == null || customer!.profileImage!.isEmpty)) {
      if (backupImg != null && backupImg != "null") customer!.profileImage = backupImg;
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
    if (calculationSnapshot != null) data['calculationSnapshot'] = calculationSnapshot!.toJson();
    if (installments != null) data['installments'] = installments!.map((v) => v.toJson()).toList();
    return data;
  }
}

class Customer {
  String? id, displayId, name, phone, createdAt, profileImage;

  Customer({this.id, this.displayId, this.name, this.phone, this.createdAt, this.profileImage});

  Customer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    displayId = json['displayId'];
    name = json['name'];
    phone = json['phone'];
    createdAt = json['createdAt'];
    
    String? img = json['profileImage']?.toString() ?? 
                  json['customerImageUrl']?.toString() ?? 
                  json['customerImage']?.toString() ??
                  json['photo']?.toString() ??
                  json['image']?.toString();
    if (img != null && img != "null") profileImage = img;
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'displayId': displayId, 'name': name, 'phone': phone, 'createdAt': createdAt, 'profileImage': profileImage};
  }
}

class ProductModel {
  String? name, code;
  Brand? brand;
  ProductModel({this.name, this.code, this.brand});
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
  Brand.fromJson(Map<String, dynamic> json) { name = json['name']; }
  Map<String, dynamic> toJson() { return {'name': name}; }
}

class CalculationSnapshot {
  String? totalAfterCashback, regularPrice, initialPaymentAmount, monthlyEmi;
  int? planMonths;
  CalculationSnapshot({this.totalAfterCashback, this.regularPrice, this.initialPaymentAmount, this.planMonths, this.monthlyEmi});
  CalculationSnapshot.fromJson(Map<String, dynamic> json) {
    totalAfterCashback = json['totalAfterCashback'];
    regularPrice = json['regularPrice'];
    initialPaymentAmount = json['initialPaymentAmount'];
    planMonths = json['planMonths'];
    monthlyEmi = json['monthlyEmi'];
  }
  Map<String, dynamic> toJson() { return {'totalAfterCashback': totalAfterCashback, 'regularPrice': regularPrice, 'initialPaymentAmount': initialPaymentAmount, 'planMonths': planMonths, 'monthlyEmi': monthlyEmi}; }
}

class Installments {
  String? status, totalDue, remainingAmount, originalAmount, dueDate;
  Installments({this.status, this.totalDue, this.remainingAmount, this.originalAmount, this.dueDate});
  Installments.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    totalDue = json['totalDue'];
    remainingAmount = json['remainingAmount'];
    originalAmount = json['originalAmount'];
    dueDate = json['dueDate'];
  }
  Map<String, dynamic> toJson() { return {'status': status, 'totalDue': totalDue, 'remainingAmount': remainingAmount, 'originalAmount': originalAmount, 'dueDate': dueDate}; }
}

class Applications {
  String? id, displayId, customerId, name, phone, mrp, status, createdAt, productModel, profileImage;
  Customer? customer;
  Brand? product, productModelRelation;

  Applications.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    displayId = json['displayId'];
    customerId = json['customerId'];
    customer = json['customer'] != null ? Customer.fromJson(json['customer']) : null;
    name = json['name'];
    phone = json['phone'];
    mrp = json['mrp'];
    status = json['status'];
    createdAt = json['createdAt'];
    productModel = json['productModel'];
    product = json['product'] != null ? Brand.fromJson(json['product']) : null;
    productModelRelation = json['productModelRelation'] != null ? Brand.fromJson(json['productModelRelation']) : null;
        
    profileImage = json['profileImage']?.toString() ?? 
                   json['customerImageUrl']?.toString() ?? 
                   json['customerImage']?.toString() ??
                   json['photo']?.toString();
                   
    if (customer != null && (customer!.profileImage == null || customer!.profileImage!.isEmpty)) {
       if (profileImage != null && profileImage != "null") customer!.profileImage = profileImage;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['displayId'] = displayId;
    if (customer != null) data['customer'] = customer!.toJson();
    data['name'] = name;
    data['phone'] = phone;
    data['status'] = status;
    data['profileImage'] = profileImage;
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

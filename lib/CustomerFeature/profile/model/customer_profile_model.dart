class CustomerProfileModel {
  bool? success;
  Data? data;

  CustomerProfileModel({this.success, this.data});

  CustomerProfileModel.fromJson(Map<String, dynamic> json) {
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
  String? issueDate;
  String? name;
  String? phone;
  String? presentAddress;
  String? permanentAddress;
  String? nidPassportNumber;
  String? customerImageFileName;
  String? customerImageOriginalName;
  String? customerImageMimeType;
  int? customerImageSize;
  String? customerImagePath;
  String? customerImageUrl;
  String? sourceOfIncome;
  String? monthlyIncome;
  String? productModel;
  String? productModelId;
  String? productId;
  String? mrp;
  String? downPayment;
  String? emiCharge;
  int? emiTenureMonths;
  String? monthlyEmi;
  String? monthlyPaymentDate;
  String? refundNote;
  String? downPaymentMethod;
  String? downPaymentReferenceNumber;
  String? bankAccountName;
  String? bankAccountNumber;
  String? bankName;
  String? bankReceiptFileName;
  String? bankReceiptOriginalName;
  String? bankReceiptMimeType;
  int? bankReceiptSize;
  String? bankReceiptPath;
  String? bankReceiptUrl;
  String? shopId;
  String? agentId;
  String? managerId;
  String? salesPersonId;
  String? createdAt;
  String? updatedAt;
  Shop? shop;
  Agent? agent;
  Agent? manager;
  SalesPerson? salesPerson;
  Product? product;
  AssignedProductModel? assignedProductModel;
  List<Guarantors>? guarantors;
  List<Documents>? documents;

  // Helper for masked NID
  String get maskedNidPassportNumber {
    if (nidPassportNumber == null || nidPassportNumber!.length < 4) {
      return nidPassportNumber ?? 'N/A';
    }
    return '****${nidPassportNumber!.substring(nidPassportNumber!.length - 4)}';
  }

  Data({
    this.id,
    this.displayId,
    this.issueDate,
    this.name,
    this.phone,
    this.presentAddress,
    this.permanentAddress,
    this.nidPassportNumber,
    this.customerImageFileName,
    this.customerImageOriginalName,
    this.customerImageMimeType,
    this.customerImageSize,
    this.customerImagePath,
    this.customerImageUrl,
    this.sourceOfIncome,
    this.monthlyIncome,
    this.productModel,
    this.productModelId,
    this.productId,
    this.mrp,
    this.downPayment,
    this.emiCharge,
    this.emiTenureMonths,
    this.monthlyEmi,
    this.monthlyPaymentDate,
    this.refundNote,
    this.downPaymentMethod,
    this.downPaymentReferenceNumber,
    this.bankAccountName,
    this.bankAccountNumber,
    this.bankName,
    this.bankReceiptFileName,
    this.bankReceiptOriginalName,
    this.bankReceiptMimeType,
    this.bankReceiptSize,
    this.bankReceiptPath,
    this.bankReceiptUrl,
    this.shopId,
    this.agentId,
    this.managerId,
    this.salesPersonId,
    this.createdAt,
    this.updatedAt,
    this.shop,
    this.agent,
    this.manager,
    this.salesPerson,
    this.product,
    this.assignedProductModel,
    this.guarantors,
    this.documents,
  });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    displayId = json['displayId'];
    issueDate = json['issueDate'];
    name = json['name'];
    phone = json['phone'];
    presentAddress = json['presentAddress'];
    permanentAddress = json['permanentAddress'];
    nidPassportNumber = json['nidPassportNumber'];
    customerImageFileName = json['customerImageFileName'];
    customerImageOriginalName = json['customerImageOriginalName'];
    customerImageMimeType = json['customerImageMimeType'];
    customerImageSize = json['customerImageSize'];
    customerImagePath = json['customerImagePath'];
    customerImageUrl = json['customerImageUrl'];
    sourceOfIncome = json['sourceOfIncome'];
    monthlyIncome = json['monthlyIncome'];
    productModel = json['productModel'];
    productModelId = json['productModelId'];
    productId = json['productId'];
    mrp = json['mrp'];
    downPayment = json['downPayment'];
    emiCharge = json['emiCharge'];
    emiTenureMonths = json['emiTenureMonths'];
    monthlyEmi = json['monthlyEmi'];
    monthlyPaymentDate = json['monthlyPaymentDate'];
    refundNote = json['refundNote'];
    downPaymentMethod = json['downPaymentMethod'];
    downPaymentReferenceNumber = json['downPaymentReferenceNumber'];
    bankAccountName = json['bankAccountName'];
    bankAccountNumber = json['bankAccountNumber'];
    bankName = json['bankName'];
    bankReceiptFileName = json['bankReceiptFileName'];
    bankReceiptOriginalName = json['bankReceiptOriginalName'];
    bankReceiptMimeType = json['bankReceiptMimeType'];
    bankReceiptSize = json['bankReceiptSize'];
    bankReceiptPath = json['bankReceiptPath'];
    bankReceiptUrl = json['bankReceiptUrl'];
    shopId = json['shopId'];
    agentId = json['agentId'];
    managerId = json['managerId'];
    salesPersonId = json['salesPersonId'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    shop = json['shop'] != null ? Shop.fromJson(json['shop']) : null;
    agent = json['agent'] != null ? Agent.fromJson(json['agent']) : null;
    manager = json['manager'] != null ? Agent.fromJson(json['manager']) : null;
    salesPerson = json['salesPerson'] != null ? SalesPerson.fromJson(json['salesPerson']) : null;
    product = json['product'] != null ? Product.fromJson(json['product']) : null;
    assignedProductModel = json['assignedProductModel'] != null
        ? AssignedProductModel.fromJson(json['assignedProductModel'])
        : null;
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
    data['issueDate'] = issueDate;
    data['name'] = name;
    data['phone'] = phone;
    data['presentAddress'] = presentAddress;
    data['permanentAddress'] = permanentAddress;
    data['nidPassportNumber'] = nidPassportNumber;
    data['customerImageUrl'] = customerImageUrl;
    data['sourceOfIncome'] = sourceOfIncome;
    data['monthlyIncome'] = monthlyIncome;
    data['mrp'] = mrp;
    data['downPayment'] = downPayment;
    data['emiCharge'] = emiCharge;
    data['emiTenureMonths'] = emiTenureMonths;
    data['monthlyEmi'] = monthlyEmi;
    data['downPaymentMethod'] = downPaymentMethod;
    data['shopId'] = shopId;
    data['agentId'] = agentId;
    data['managerId'] = managerId;
    data['salesPersonId'] = salesPersonId;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    if (shop != null) data['shop'] = shop!.toJson();
    if (agent != null) data['agent'] = agent!.toJson();
    if (manager != null) data['manager'] = manager!.toJson();
    if (salesPerson != null) data['salesPerson'] = salesPerson!.toJson();
    if (product != null) data['product'] = product!.toJson();
    if (assignedProductModel != null) data['assignedProductModel'] = assignedProductModel!.toJson();
    if (guarantors != null) data['guarantors'] = guarantors!.map((v) => v.toJson()).toList();
    if (documents != null) data['documents'] = documents!.map((v) => v.toJson()).toList();
    return data;
  }
}

class Shop {
  String? id;
  String? name;
  String? code;
  String? contactPerson;
  String? mobileNumber;
  String? email;
  String? address;

  Shop({this.id, this.name, this.code, this.contactPerson, this.mobileNumber, this.email, this.address});

  Shop.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    code = json['code'];
    contactPerson = json['contactPerson'];
    mobileNumber = json['mobileNumber'];
    email = json['email'];
    address = json['address'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'contactPerson': contactPerson,
      'mobileNumber': mobileNumber,
      'email': email,
      'address': address,
    };
  }
}

class Agent {
  String? id;
  String? name;
  String? code;

  Agent({this.id, this.name, this.code});

  Agent.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    code = json['code'];
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'code': code};
}

class SalesPerson {
  String? id;
  String? name;
  String? code;
  String? phone;
  String? email;

  SalesPerson({this.id, this.name, this.code, this.phone, this.email});

  SalesPerson.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    code = json['code'];
    phone = json['phone'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'code': code,
    'phone': phone,
    'email': email,
  };
}

class Product {
  String? id;
  String? code;
  String? name;
  String? model;
  String? categoryId;
  String? seriesId;
  String? buyingPrice;
  String? sellingPrice;
  String? description;
  String? status;
  String? imageUrl;
  String? brandId;
  String? createdAt;
  String? updatedAt;
  Brand? brand;
  Brand? category;
  Series? series;

  Product({
    this.id,
    this.code,
    this.name,
    this.model,
    this.categoryId,
    this.seriesId,
    this.buyingPrice,
    this.sellingPrice,
    this.description,
    this.status,
    this.imageUrl,
    this.brandId,
    this.createdAt,
    this.updatedAt,
    this.brand,
    this.category,
    this.series,
  });

  Product.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    name = json['name'];
    model = json['model'];
    categoryId = json['categoryId'];
    seriesId = json['seriesId'];
    buyingPrice = json['buyingPrice'];
    sellingPrice = json['sellingPrice'];
    description = json['description'];
    status = json['status'];
    imageUrl = json['imageUrl'];
    brandId = json['brandId'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    brand = json['brand'] != null ? Brand.fromJson(json['brand']) : null;
    category = json['category'] != null ? Brand.fromJson(json['category']) : null;
    series = json['series'] != null ? Series.fromJson(json['series']) : null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'sellingPrice': sellingPrice,
      'status': status,
      'imageUrl': imageUrl,
      if (brand != null) 'brand': brand!.toJson(),
    };
  }
}

class Brand {
  String? id;
  String? code;
  String? name;
  String? description;
  String? status;
  String? createdAt;
  String? updatedAt;

  Brand({this.id, this.code, this.name, this.description, this.status, this.createdAt, this.updatedAt});

  Brand.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    name = json['name'];
    description = json['description'];
    status = json['status'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'name': name,
    'status': status,
  };
}

class Series {
  String? id;
  String? code;
  String? name;
  String? description;
  String? status;
  String? brandId;
  String? createdAt;
  String? updatedAt;

  Series({this.id, this.code, this.name, this.description, this.status, this.brandId, this.createdAt, this.updatedAt});

  Series.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    name = json['name'];
    description = json['description'];
    status = json['status'];
    brandId = json['brandId'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'name': name,
    'status': status,
  };
}

class AssignedProductModel {
  String? id;
  String? code;
  String? name;
  String? description;
  String? status;
  String? brandId;
  String? productId;
  String? createdAt;
  String? updatedAt;
  Brand? brand;
  Product? product;

  AssignedProductModel({
    this.id,
    this.code,
    this.name,
    this.description,
    this.status,
    this.brandId,
    this.productId,
    this.createdAt,
    this.updatedAt,
    this.brand,
    this.product,
  });

  AssignedProductModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    name = json['name'];
    description = json['description'];
    status = json['status'];
    brandId = json['brandId'];
    productId = json['productId'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    brand = json['brand'] != null ? Brand.fromJson(json['brand']) : null;
    product = json['product'] != null ? Product.fromJson(json['product']) : null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'status': status,
      if (brand != null) 'brand': brand!.toJson(),
      if (product != null) 'product': product!.toJson(),
    };
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
    this.documentImageUrl,
    this.createdAt,
    this.updatedAt,
    this.documents,
  });

  Guarantors.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    customerId = json['customerId'];
    type = json['type'];
    name = json['name'];
    phone = json['phone'];
    relationship = json['relationship'];
    nidPassportNumber = json['nidPassportNumber'];
    documentType = json['documentType'];
    documentImageUrl = json['documentImageUrl'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    if (json['documents'] != null) {
      documents = <Documents>[];
      json['documents'].forEach((v) {
        documents!.add(Documents.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'relationship': relationship,
      'type': type,
      if (documents != null) 'documents': documents!.map((v) => v.toJson()).toList(),
    };
  }
}

class Documents {
  String? id;
  String? customerId;
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
    this.customerId,
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
    id = json['id'];
    customerId = json['customerId'];
    guarantorId = json['guarantorId'];
    documentType = json['documentType'];
    fileName = json['fileName'];
    originalName = json['originalName'];
    mimeType = json['mimeType'];
    size = json['size'];
    path = json['path'];
    url = json['url'];
    uploadedById = json['uploadedById'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'documentType': documentType,
      'url': url,
      'originalName': originalName,
    };
  }
}
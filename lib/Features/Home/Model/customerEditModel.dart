// lib/models/customer_detail_model.dart

class CustomerEditModel {
  bool? success;
  EditData? data;

  CustomerEditModel({this.success, this.data});

  factory CustomerEditModel.fromJson(Map<String, dynamic> json) {
    return CustomerEditModel(
      success: json['success'],
      data: json['data'] != null ? EditData.fromJson(json['data']) : null,
    );
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

class EditData {
  String? id;
  String? displayId;
  String? issueDate;
  String? name;
  String? phone;
  String? email;
  String? presentAddress;
  String? permanentAddress;
  String? nidPassportNumber;
  String? idType;
  String? status;
  String? profileImage;
  String? customerImageFileName;
  String? customerImageOriginalName;
  String? customerImageMimeType;
  int? customerImageSize;
  String? customerImagePath;
  String? customerImageUrl;
  String? customerVideoFileName;
  String? customerVideoOriginalName;
  String? customerVideoMimeType;
  int? customerVideoSize;
  String? customerVideoPath;
  String? customerVideoUrl;
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
  List<Guarantor>? guarantors;
  List<Document>? documents;
  Shop? shop;
  Shop? agent;
  Shop? manager;
  Shop? salesPerson;
  AssignedProductModel? assignedProductModel;
  Product? product;
  List<ActiveLoan>? activeLoans;
  String? nidFront;
  String? nidBack;
  String? incomeProof;

  EditData({
    this.id,
    this.displayId,
    this.issueDate,
    this.name,
    this.phone,
    this.email,
    this.presentAddress,
    this.permanentAddress,
    this.nidPassportNumber,
    this.idType,
    this.status,
    this.profileImage,
    this.customerImageFileName,
    this.customerImageOriginalName,
    this.customerImageMimeType,
    this.customerImageSize,
    this.customerImagePath,
    this.customerImageUrl,
    this.customerVideoFileName,
    this.customerVideoOriginalName,
    this.customerVideoMimeType,
    this.customerVideoSize,
    this.customerVideoPath,
    this.customerVideoUrl,
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
    this.guarantors,
    this.documents,
    this.shop,
    this.agent,
    this.manager,
    this.salesPerson,
    this.assignedProductModel,
    this.product,
    this.activeLoans,
    this.nidFront,
    this.nidBack,
    this.incomeProof,
  });

  factory EditData.fromJson(Map<String, dynamic> json) {
    return EditData(
      id: json['id']?.toString(),
      displayId: json['displayId']?.toString(),
      issueDate: json['issueDate']?.toString(),
      name: json['name']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      presentAddress: json['presentAddress']?.toString(),
      permanentAddress: json['permanentAddress']?.toString(),
      nidPassportNumber: json['nidPassportNumber']?.toString(),
      idType: json['idType']?.toString(),
      status: json['status']?.toString(),
      profileImage: json['profileImage']?.toString(),
      customerImageFileName: json['customerImageFileName']?.toString(),
      customerImageOriginalName: json['customerImageOriginalName']?.toString(),
      customerImageMimeType: json['customerImageMimeType']?.toString(),
      customerImageSize: json['customerImageSize'] as int?,
      customerImagePath: json['customerImagePath']?.toString(),
      customerImageUrl: json['customerImageUrl']?.toString(),
      customerVideoFileName: json['customerVideoFileName']?.toString(),
      customerVideoOriginalName: json['customerVideoOriginalName']?.toString(),
      customerVideoMimeType: json['customerVideoMimeType']?.toString(),
      customerVideoSize: json['customerVideoSize'] as int?,
      customerVideoPath: json['customerVideoPath']?.toString(),
      customerVideoUrl: json['customerVideoUrl']?.toString(),
      sourceOfIncome: json['sourceOfIncome']?.toString(),
      monthlyIncome: json['monthlyIncome']?.toString(),
      productModel: json['productModel']?.toString(),
      productModelId: json['productModelId']?.toString(),
      productId: json['productId']?.toString(),
      mrp: json['mrp']?.toString(),
      downPayment: json['downPayment']?.toString(),
      emiCharge: json['emiCharge']?.toString(),
      emiTenureMonths: json['emiTenureMonths'] as int?,
      monthlyEmi: json['monthlyEmi']?.toString(),
      monthlyPaymentDate: json['monthlyPaymentDate']?.toString(),
      refundNote: json['refundNote']?.toString(),
      downPaymentMethod: json['downPaymentMethod']?.toString(),
      downPaymentReferenceNumber: json['downPaymentReferenceNumber']?.toString(),
      bankAccountName: json['bankAccountName']?.toString(),
      bankAccountNumber: json['bankAccountNumber']?.toString(),
      bankName: json['bankName']?.toString(),
      bankReceiptFileName: json['bankReceiptFileName']?.toString(),
      bankReceiptOriginalName: json['bankReceiptOriginalName']?.toString(),
      bankReceiptMimeType: json['bankReceiptMimeType']?.toString(),
      bankReceiptSize: json['bankReceiptSize'] as int?,
      bankReceiptPath: json['bankReceiptPath']?.toString(),
      bankReceiptUrl: json['bankReceiptUrl']?.toString(),
      shopId: json['shopId']?.toString(),
      agentId: json['agentId']?.toString(),
      managerId: json['managerId']?.toString(),
      salesPersonId: json['salesPersonId']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      guarantors: json['guarantors'] != null
          ? (json['guarantors'] as List).map((e) => Guarantor.fromJson(e)).toList()
          : null,
      documents: json['documents'] != null
          ? (json['documents'] as List).map((e) => Document.fromJson(e)).toList()
          : null,
      shop: json['shop'] != null ? Shop.fromJson(json['shop']) : null,
      agent: json['agent'] != null ? Shop.fromJson(json['agent']) : null,
      manager: json['manager'] != null ? Shop.fromJson(json['manager']) : null,
      salesPerson: json['salesPerson'] != null ? Shop.fromJson(json['salesPerson']) : null,
      assignedProductModel: json['assignedProductModel'] != null
          ? AssignedProductModel.fromJson(json['assignedProductModel'])
          : null,
      product: json['product'] != null ? Product.fromJson(json['product']) : null,
      activeLoans: json['activeLoans'] != null
          ? (json['activeLoans'] as List).map((e) => ActiveLoan.fromJson(e)).toList()
          : null,
      nidFront: json['nidFront']?.toString(),
      nidBack: json['nidBack']?.toString(),
      incomeProof: json['incomeProof']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['displayId'] = displayId;
    data['issueDate'] = issueDate;
    data['name'] = name;
    data['phone'] = phone;
    data['email'] = email;
    data['presentAddress'] = presentAddress;
    data['permanentAddress'] = permanentAddress;
    data['nidPassportNumber'] = nidPassportNumber;
    data['idType'] = idType;
    data['status'] = status;
    data['profileImage'] = profileImage;
    data['customerImageFileName'] = customerImageFileName;
    data['customerImageOriginalName'] = customerImageOriginalName;
    data['customerImageMimeType'] = customerImageMimeType;
    data['customerImageSize'] = customerImageSize;
    data['customerImagePath'] = customerImagePath;
    data['customerImageUrl'] = customerImageUrl;
    data['customerVideoFileName'] = customerVideoFileName;
    data['customerVideoOriginalName'] = customerVideoOriginalName;
    data['customerVideoMimeType'] = customerVideoMimeType;
    data['customerVideoSize'] = customerVideoSize;
    data['customerVideoPath'] = customerVideoPath;
    data['customerVideoUrl'] = customerVideoUrl;
    data['sourceOfIncome'] = sourceOfIncome;
    data['monthlyIncome'] = monthlyIncome;
    data['productModel'] = productModel;
    data['productModelId'] = productModelId;
    data['productId'] = productId;
    data['mrp'] = mrp;
    data['downPayment'] = downPayment;
    data['emiCharge'] = emiCharge;
    data['emiTenureMonths'] = emiTenureMonths;
    data['monthlyEmi'] = monthlyEmi;
    data['monthlyPaymentDate'] = monthlyPaymentDate;
    data['refundNote'] = refundNote;
    data['downPaymentMethod'] = downPaymentMethod;
    data['downPaymentReferenceNumber'] = downPaymentReferenceNumber;
    data['bankAccountName'] = bankAccountName;
    data['bankAccountNumber'] = bankAccountNumber;
    data['bankName'] = bankName;
    data['bankReceiptFileName'] = bankReceiptFileName;
    data['bankReceiptOriginalName'] = bankReceiptOriginalName;
    data['bankReceiptMimeType'] = bankReceiptMimeType;
    data['bankReceiptSize'] = bankReceiptSize;
    data['bankReceiptPath'] = bankReceiptPath;
    data['bankReceiptUrl'] = bankReceiptUrl;
    data['shopId'] = shopId;
    data['agentId'] = agentId;
    data['managerId'] = managerId;
    data['salesPersonId'] = salesPersonId;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    if (guarantors != null) {
      data['guarantors'] = guarantors!.map((v) => v.toJson()).toList();
    }
    if (documents != null) {
      data['documents'] = documents!.map((v) => v.toJson()).toList();
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
    if (assignedProductModel != null) {
      data['assignedProductModel'] = assignedProductModel!.toJson();
    }
    if (product != null) {
      data['product'] = product!.toJson();
    }
    if (activeLoans != null) {
      data['activeLoans'] = activeLoans!.map((v) => v.toJson()).toList();
    }
    data['nidFront'] = nidFront;
    data['nidBack'] = nidBack;
    data['incomeProof'] = incomeProof;
    return data;
  }
}

// ─── Guarantor ───
class Guarantor {
  String? id;
  String? customerId;
  String? type;
  String? name;
  String? phone;
  String? relationship;
  String? idType;
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
  String? nidFront;
  String? nidBack;
  List<Document>? documents;

  Guarantor({
    this.id,
    this.customerId,
    this.type,
    this.name,
    this.phone,
    this.relationship,
    this.idType,
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
    this.nidFront,
    this.nidBack,
    this.documents,
  });

  factory Guarantor.fromJson(Map<String, dynamic> json) {
    return Guarantor(
      id: json['id']?.toString(),
      customerId: json['customerId']?.toString(),
      type: json['type']?.toString(),
      name: json['name']?.toString(),
      phone: json['phone']?.toString(),
      relationship: json['relationship']?.toString(),
      idType: json['idType']?.toString(),
      nidPassportNumber: json['nidPassportNumber']?.toString(),
      documentType: json['documentType']?.toString(),
      documentImageFileName: json['documentImageFileName']?.toString(),
      documentImageOriginalName: json['documentImageOriginalName']?.toString(),
      documentImageMimeType: json['documentImageMimeType']?.toString(),
      documentImageSize: json['documentImageSize'] as int?,
      documentImagePath: json['documentImagePath']?.toString(),
      documentImageUrl: json['documentImageUrl']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      nidFront: json['nidFront']?.toString(),
      nidBack: json['nidBack']?.toString(),
      documents: json['documents'] != null
          ? (json['documents'] as List).map((e) => Document.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (id != null && id!.isNotEmpty) {
      data['id'] = id;
    }
    data['customerId'] = customerId;
    data['type'] = type;
    data['name'] = name;
    data['phone'] = phone;
    data['relationship'] = relationship;
    data['idType'] = idType;
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
    data['nidFront'] = nidFront;
    data['nidBack'] = nidBack;
    if (documents != null) {
      data['documents'] = documents!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

// ─── Document ───
class Document {
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

  Document({
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

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id']?.toString(),
      customerId: json['customerId']?.toString(),
      guarantorId: json['guarantorId']?.toString(),
      documentType: json['documentType']?.toString(),
      fileName: json['fileName']?.toString(),
      originalName: json['originalName']?.toString(),
      mimeType: json['mimeType']?.toString(),
      size: json['size'] as int?,
      path: json['path']?.toString(),
      url: json['url']?.toString(),
      uploadedById: json['uploadedById']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['customerId'] = customerId;
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

// ─── Shop ───
class Shop {
  String? id;
  String? name;
  String? code;
  Shop({this.id, this.name, this.code});
  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      code: json['code']?.toString(),
    );
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['code'] = code;
    return data;
  }
}

// ─── AssignedProductModel ───
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
  Shop? brand;
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
  factory AssignedProductModel.fromJson(Map<String, dynamic> json) {
    return AssignedProductModel(
      id: json['id']?.toString(),
      code: json['code']?.toString(),
      name: json['name']?.toString(),
      description: json['description']?.toString(),
      status: json['status']?.toString(),
      brandId: json['brandId']?.toString(),
      productId: json['productId']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      brand: json['brand'] != null ? Shop.fromJson(json['brand']) : null,
      product: json['product'] != null ? Product.fromJson(json['product']) : null,
    );
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['code'] = code;
    data['name'] = name;
    data['description'] = description;
    data['status'] = status;
    data['brandId'] = brandId;
    data['productId'] = productId;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    if (brand != null) {
      data['brand'] = brand!.toJson();
    }
    if (product != null) {
      data['product'] = product!.toJson();
    }
    return data;
  }
}

// ─── Product ───
class Product {
  String? id;
  String? name;
  String? code;
  String? brandId;
  String? sellingPrice;
  Product({this.id, this.name, this.code, this.brandId, this.sellingPrice});
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      code: json['code']?.toString(),
      brandId: json['brandId']?.toString(),
      sellingPrice: json['sellingPrice']?.toString(),
    );
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['code'] = code;
    data['brandId'] = brandId;
    data['sellingPrice'] = sellingPrice;
    return data;
  }
}

// ─── ActiveLoan ───
class ActiveLoan {
  String? id;
  String? displayId;
  String? productName;
  String? status;
  double? totalAmount;
  double? paidAmount;
  double? remainingAmount;
  ActiveLoan({
    this.id,
    this.displayId,
    this.productName,
    this.status,
    this.totalAmount,
    this.paidAmount,
    this.remainingAmount,
  });
  factory ActiveLoan.fromJson(Map<String, dynamic> json) {
    return ActiveLoan(
      id: json['id']?.toString(),
      displayId: json['displayId']?.toString(),
      productName: json['productName']?.toString(),
      status: json['status']?.toString(),
      totalAmount: double.tryParse(json['totalAmount']?.toString() ?? '0'),
      paidAmount: double.tryParse(json['paidAmount']?.toString() ?? '0'),
      remainingAmount: double.tryParse(json['remainingAmount']?.toString() ?? '0'),
    );
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['displayId'] = displayId;
    data['productName'] = productName;
    data['status'] = status;
    data['totalAmount'] = totalAmount;
    data['paidAmount'] = paidAmount;
    data['remainingAmount'] = remainingAmount;
    return data;
  }
}
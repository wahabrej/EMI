class PhoneProductModel {
  bool? success;
  List<Data>? data;

  PhoneProductModel({this.success, this.data});

  PhoneProductModel.fromJson(Map<String, dynamic> json) {
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
  String? code;
  String? name;
  String? model;
  String? modelCode; // ✅ এই লাইন যোগ করুন
  String? categoryId;
  String? seriesId;
  String? buyingPrice;
  String? sellingPrice;
  String? description;
  String? status;
  String? imageFileName;
  String? imageOriginalName;
  String? imageMimeType;
  dynamic imageSize;
  String? imagePath;
  String? imageUrl;
  String? brandId;
  String? createdAt;
  String? updatedAt;
  Brand? brand;
  Category? category;
  Series? series;
  List<EmiPlans>? emiPlans;
  List<ProductModels>? productModels;

  Data({
    this.id,
    this.code,
    this.name,
    this.model,
    this.modelCode, // ✅ এই লাইন যোগ করুন
    this.categoryId,
    this.seriesId,
    this.buyingPrice,
    this.sellingPrice,
    this.description,
    this.status,
    this.imageFileName,
    this.imageOriginalName,
    this.imageMimeType,
    this.imageSize,
    this.imagePath,
    this.imageUrl,
    this.brandId,
    this.createdAt,
    this.updatedAt,
    this.brand,
    this.category,
    this.series,
    this.emiPlans,
    this.productModels,
  });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    code = json['code']?.toString();
    name = json['name']?.toString();
    model = json['model']?.toString();
    modelCode = json['modelCode']?.toString() ?? json['model_code']?.toString() ?? json['model']?.toString(); // ✅ এই লাইন যোগ করুন
    categoryId = json['categoryId']?.toString();
    seriesId = json['seriesId']?.toString();
    buyingPrice = json['buyingPrice']?.toString();
    sellingPrice = json['sellingPrice']?.toString();
    description = json['description']?.toString();
    status = json['status']?.toString();
    imageFileName = json['imageFileName']?.toString();
    imageOriginalName = json['imageOriginalName']?.toString();
    imageMimeType = json['imageMimeType']?.toString();
    imageSize = json['imageSize'];
    imagePath = json['imagePath']?.toString();
    imageUrl = json['imageUrl']?.toString();
    brandId = json['brandId']?.toString();
    createdAt = json['createdAt']?.toString();
    updatedAt = json['updatedAt']?.toString();
    brand = json['brand'] != null ? Brand.fromJson(json['brand']) : null;
    category = json['category'] != null ? Category.fromJson(json['category']) : null;
    series = json['series'] != null ? Series.fromJson(json['series']) : null;
    if (json['emiPlans'] != null) {
      emiPlans = <EmiPlans>[];
      json['emiPlans'].forEach((v) {
        emiPlans!.add(EmiPlans.fromJson(v));
      });
    }
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
    data['model'] = model;
    data['modelCode'] = modelCode; // ✅ এই লাইন যোগ করুন
    data['categoryId'] = categoryId;
    data['seriesId'] = seriesId;
    data['buyingPrice'] = buyingPrice;
    data['sellingPrice'] = sellingPrice;
    data['description'] = description;
    data['status'] = status;
    data['imageFileName'] = imageFileName;
    data['imageOriginalName'] = imageOriginalName;
    data['imageMimeType'] = imageMimeType;
    data['imageSize'] = imageSize;
    data['imagePath'] = imagePath;
    data['imageUrl'] = imageUrl;
    data['brandId'] = brandId;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    if (brand != null) {
      data['brand'] = brand!.toJson();
    }
    if (category != null) {
      data['category'] = category!.toJson();
    }
    if (series != null) {
      data['series'] = series!.toJson();
    }
    if (emiPlans != null) {
      data['emiPlans'] = emiPlans!.map((v) => v.toJson()).toList();
    }
    if (productModels != null) {
      data['productModels'] = productModels!.map((v) => v.toJson()).toList();
    }
    return data;
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

  Brand({
    this.id,
    this.code,
    this.name,
    this.description,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  Brand.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    code = json['code']?.toString();
    name = json['name']?.toString();
    description = json['description']?.toString();
    status = json['status']?.toString();
    createdAt = json['createdAt']?.toString();
    updatedAt = json['updatedAt']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['code'] = code;
    data['name'] = name;
    data['description'] = description;
    data['status'] = status;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}

class Category {
  String? id;
  String? name;
  String? code;

  Category({this.id, this.name, this.code});

  Category.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    name = json['name']?.toString();
    code = json['code']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['code'] = code;
    return data;
  }
}

class Series {
  String? id;
  String? name;
  String? code;
  String? brandId;

  Series({this.id, this.name, this.code, this.brandId});

  Series.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    name = json['name']?.toString();
    code = json['code']?.toString();
    brandId = json['brandId']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['code'] = code;
    data['brandId'] = brandId;
    return data;
  }
}

class EmiPlans {
  String? id;
  String? productId;
  String? name;
  String? note; // 💡 Fixed from Null? to String?
  int? months;
  String? downPaymentCalculationType;
  String? displayDownPaymentPercent;
  String? downPaymentCalculationRate;
  dynamic downPaymentAmount; // 💡 Fixed from Null? to dynamic
  String? appEmiChargeType;
  String? appEmiChargeRate;
  dynamic appEmiChargeAmount; // 💡 Fixed from Null? to dynamic
  String? cashbackRate;
  dynamic cashbackAmount; // 💡 Fixed from Null? to dynamic
  List<DownPaymentComponents>? downPaymentComponents;
  bool? isActive;
  int? sortOrder;
  String? createdAt;
  String? updatedAt;

  EmiPlans({
    this.id,
    this.productId,
    this.name,
    this.note,
    this.months,
    this.downPaymentCalculationType,
    this.displayDownPaymentPercent,
    this.downPaymentCalculationRate,
    this.downPaymentAmount,
    this.appEmiChargeType,
    this.appEmiChargeRate,
    this.appEmiChargeAmount,
    this.cashbackRate,
    this.cashbackAmount,
    this.downPaymentComponents,
    this.isActive,
    this.sortOrder,
    this.createdAt,
    this.updatedAt,
  });

  EmiPlans.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    productId = json['productId']?.toString();
    name = json['name']?.toString();
    note = json['note']?.toString();
    months = json['months'] != null ? int.tryParse(json['months'].toString()) : null;
    downPaymentCalculationType = json['downPaymentCalculationType']?.toString();
    displayDownPaymentPercent = json['displayDownPaymentPercent']?.toString();
    downPaymentCalculationRate = json['downPaymentCalculationRate']?.toString();
    downPaymentAmount = json['downPaymentAmount'];
    appEmiChargeType = json['appEmiChargeType']?.toString();
    appEmiChargeRate = json['appEmiChargeRate']?.toString();
    appEmiChargeAmount = json['appEmiChargeAmount'];
    cashbackRate = json['cashbackRate']?.toString();
    cashbackAmount = json['cashbackAmount'];
    if (json['downPaymentComponents'] != null) {
      downPaymentComponents = <DownPaymentComponents>[];
      json['downPaymentComponents'].forEach((v) {
        downPaymentComponents!.add(DownPaymentComponents.fromJson(v));
      });
    }
    isActive = json['isActive'];
    sortOrder = json['sortOrder'] != null ? int.tryParse(json['sortOrder'].toString()) : null;
    createdAt = json['createdAt']?.toString();
    updatedAt = json['updatedAt']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['productId'] = productId;
    data['name'] = name;
    data['note'] = note;
    data['months'] = months;
    data['downPaymentCalculationType'] = downPaymentCalculationType;
    data['displayDownPaymentPercent'] = displayDownPaymentPercent;
    data['downPaymentCalculationRate'] = downPaymentCalculationRate;
    data['downPaymentAmount'] = downPaymentAmount;
    data['appEmiChargeType'] = appEmiChargeType;
    data['appEmiChargeRate'] = appEmiChargeRate;
    data['appEmiChargeAmount'] = appEmiChargeAmount;
    data['cashbackRate'] = cashbackRate;
    data['cashbackAmount'] = cashbackAmount;
    if (downPaymentComponents != null) {
      data['downPaymentComponents'] = downPaymentComponents!.map((v) => v.toJson()).toList();
    }
    data['isActive'] = isActive;
    data['sortOrder'] = sortOrder;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}

class DownPaymentComponents {
  String? name;
  String? rate;
  String? type;

  DownPaymentComponents({this.name, this.rate, this.type});

  DownPaymentComponents.fromJson(Map<String, dynamic> json) {
    name = json['name']?.toString();
    rate = json['rate']?.toString();
    type = json['type']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['rate'] = rate;
    data['type'] = type;
    return data;
  }
}

class ProductModels {
  String? id;
  String? code;
  String? name;
  String? description;
  String? status;
  String? brandId;
  String? productId;
  String? createdAt;
  String? updatedAt;
  List<Assignments>? assignments;

  ProductModels({
    this.id,
    this.code,
    this.name,
    this.description,
    this.status,
    this.brandId,
    this.productId,
    this.createdAt,
    this.updatedAt,
    this.assignments,
  });

  ProductModels.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    code = json['code']?.toString();
    name = json['name']?.toString();
    description = json['description']?.toString();
    status = json['status']?.toString();
    brandId = json['brandId']?.toString();
    productId = json['productId']?.toString();
    createdAt = json['createdAt']?.toString();
    updatedAt = json['updatedAt']?.toString();
    if (json['assignments'] != null) {
      assignments = <Assignments>[];
      json['assignments'].forEach((v) {
        assignments!.add(Assignments.fromJson(v));
      });
    }
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
    if (assignments != null) {
      data['assignments'] = assignments!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Assignments {
  String? salesPersonId;

  Assignments({this.salesPersonId});

  Assignments.fromJson(Map<String, dynamic> json) {
    salesPersonId = json['salesPersonId']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['salesPersonId'] = salesPersonId;
    return data;
  }
}
class CustomerDetailModel {
  bool? success;
  CustomerData? data;

  CustomerDetailModel({this.success, this.data});

  CustomerDetailModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? CustomerData.fromJson(json['data']) : null;
  }
}

class CustomerData {
  String? id;
  String? displayId;
  String? name;
  String? phone;
  String? email;
  String? presentAddress;
  String? permanentAddress;
  String? nidPassportNumber;
  String? sourceOfIncome;
  num? monthlyIncome;
  String? profileImage;
  String? nidFront;
  String? nidBack;
  String? incomeProof;
  String? status;
  String? createdAt;
  
  List<ActiveLoan>? activeLoans;
  List<Guarantor>? guarantors;

  CustomerData({
    this.id,
    this.displayId,
    this.name,
    this.phone,
    this.email,
    this.presentAddress,
    this.permanentAddress,
    this.nidPassportNumber,
    this.sourceOfIncome,
    this.monthlyIncome,
    this.profileImage,
    this.nidFront,
    this.nidBack,
    this.incomeProof,
    this.status,
    this.createdAt,
    this.activeLoans,
    this.guarantors,
  });

  CustomerData.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    displayId = json['displayId']?.toString();
    name = json['name']?.toString();
    phone = json['phone']?.toString();
    email = json['email']?.toString();
    presentAddress = json['presentAddress']?.toString();
    permanentAddress = json['permanentAddress']?.toString();
    nidPassportNumber = json['nidPassportNumber']?.toString();
    sourceOfIncome = json['sourceOfIncome']?.toString();
    monthlyIncome = _parseNum(json['monthlyIncome']);
    profileImage = json['profileImage']?.toString();
    nidFront = json['nidFront']?.toString();
    nidBack = json['nidBack']?.toString();
    incomeProof = json['incomeProof']?.toString();
    status = json['status']?.toString();
    createdAt = json['createdAt']?.toString();
    
    if (json['activeLoans'] != null) {
      activeLoans = <ActiveLoan>[];
      json['activeLoans'].forEach((v) {
        activeLoans!.add(ActiveLoan.fromJson(v));
      });
    }
    if (json['guarantors'] != null) {
      guarantors = <Guarantor>[];
      json['guarantors'].forEach((v) {
        guarantors!.add(Guarantor.fromJson(v));
      });
    }
  }

  num? _parseNum(dynamic value) {
    if (value == null) return null;
    if (value is num) return value;
    if (value is String) return num.tryParse(value);
    return null;
  }
}

class ActiveLoan {
  String? id;
  String? displayId;
  String? productName;
  num? totalAmount;
  num? paidAmount;
  num? remainingAmount;
  String? status;

  ActiveLoan({this.id, this.displayId, this.productName, this.totalAmount, this.paidAmount, this.remainingAmount, this.status});

  ActiveLoan.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    displayId = json['displayId']?.toString();
    productName = json['productName']?.toString();
    totalAmount = _parseNum(json['totalAmount']);
    paidAmount = _parseNum(json['paidAmount']);
    remainingAmount = _parseNum(json['remainingAmount']);
    status = json['status']?.toString();
  }

  num? _parseNum(dynamic value) {
    if (value == null) return null;
    if (value is num) return value;
    if (value is String) return num.tryParse(value);
    return null;
  }
}

class Guarantor {
  String? name;
  String? phone;
  String? relationship;
  String? nidFront;
  String? nidBack;

  Guarantor({this.name, this.phone, this.relationship, this.nidFront, this.nidBack});

  Guarantor.fromJson(Map<String, dynamic> json) {
    name = json['name']?.toString();
    phone = json['phone']?.toString();
    relationship = json['relationship']?.toString();
    nidFront = json['nidFront']?.toString();
    nidBack = json['nidBack']?.toString();
  }
}

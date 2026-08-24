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

  // 📌 ভিডিও ফিল্ড
  String? customerVideo;
  String? customerVideoUrl;

  // 📌 customerDocuments অ্যারে সাপোর্ট
  List<Document>? customerDocuments;

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
    this.customerVideo,
    this.customerVideoUrl,
    this.customerDocuments,
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

    // 📌 ভিডিও URL গুলো পার্স করা
    customerVideo = json['customerVideo']?.toString() ?? json['customerVideoUrl']?.toString();
    customerVideoUrl = json['customerVideoUrl']?.toString();

    // 📌 customerDocuments পার্স করা
    if (json['customerDocuments'] != null) {
      customerDocuments = <Document>[];
      json['customerDocuments'].forEach((v) {
        customerDocuments!.add(Document.fromJson(v));
      });
    }

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

// 📌 Document ক্লাস (ভিডিও সাপোর্ট সহ)
class Document {
  String? id;
  String? url;
  String? fileUrl;
  String? path;
  String? documentType;
  String? type;
  String? name;
  int? guarantorIndex;

  // 📌 ভিডিও স্পেসিফিক ফিল্ড
  bool? isVideo;
  String? thumbnailUrl;
  String? videoDuration;

  Document({
    this.id,
    this.url,
    this.fileUrl,
    this.path,
    this.documentType,
    this.type,
    this.name,
    this.guarantorIndex,
    this.isVideo,
    this.thumbnailUrl,
    this.videoDuration,
  });

  Document.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    url = json['url']?.toString();
    fileUrl = json['fileUrl']?.toString();
    path = json['path']?.toString();
    documentType = json['documentType']?.toString();
    type = json['type']?.toString();
    name = json['name']?.toString();
    guarantorIndex = json['guarantorIndex'] as int?;

    // 📌 ভিডিও চেক করা
    String? docType = documentType ?? type ?? name ?? '';
    isVideo = _isVideoDocument(docType, url ?? fileUrl ?? path ?? '');

    thumbnailUrl = json['thumbnailUrl']?.toString();
    videoDuration = json['videoDuration']?.toString();
  }

  // 📌 ভিডিও ডকুমেন্ট চেক করার ফাংশন
  bool _isVideoDocument(String docType, String url) {
    // ডকুমেন্ট টাইপ চেক
    String typeUpper = docType.toUpperCase();
    if (typeUpper.contains('VIDEO')) return true;

    // URL এক্সটেনশন চেক
    String urlLower = url.toLowerCase();
    if (urlLower.endsWith('.mp4') ||
        urlLower.endsWith('.mov') ||
        urlLower.endsWith('.avi') ||
        urlLower.endsWith('.mkv') ||
        urlLower.endsWith('.webm') ||
        urlLower.endsWith('.3gp')) {
      return true;
    }

    // MIME টাইপ চেক (যদি থাকে)
    if (urlLower.contains('video/')) return true;

    return false;
  }

  // 📌 URL বের করার ফাংশন
  String? get validUrl {
    if (url != null && url!.isNotEmpty) return url;
    if (fileUrl != null && fileUrl!.isNotEmpty) return fileUrl;
    if (path != null && path!.isNotEmpty) return path;
    return null;
  }

  // 📌 ডকুমেন্ট টাইপ বের করার ফাংশন
  String get displayType {
    String typeStr = documentType ?? type ?? name ?? 'DOCUMENT';
    return typeStr.toUpperCase();
  }

  // 📌 ডকুমেন্ট লেবেল (ভিডিও সহ)
  String get displayLabel {
    if (isVideo == true) return 'VIDEO';
    return _getDocumentLabel(displayType);
  }

  String _getDocumentLabel(String docType) {
    final type = docType.toUpperCase();
    if (type.contains('NID_FRONT') || type.contains('NIDFRONT')) return 'NID FRONT';
    if (type.contains('NID_BACK') || type.contains('NIDBACK')) return 'NID BACK';
    if (type.contains('INCOME') || type.contains('SALARY')) return 'INCOME PROOF';
    if (type.contains('PHOTO')) return 'PHOTO';
    if (type.contains('VIDEO')) return 'VIDEO';
    if (type.contains('BANK')) return 'BANK RECEIPT';
    if (type.contains('PASSPORT')) return 'PASSPORT';
    if (type.contains('TRADE')) return 'TRADE LICENSE';
    if (type.contains('PROFILE')) return 'PROFILE PHOTO';
    return docType.replaceAll('_', ' ').toUpperCase();
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

  ActiveLoan({
    this.id,
    this.displayId,
    this.productName,
    this.totalAmount,
    this.paidAmount,
    this.remainingAmount,
    this.status
  });

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
  String? idType;
  String? nidPassportNumber;
  String? nidFront;
  String? nidBack;
  String? profileImage;

  // 📌 গ্যারান্টরের ভিডিও ফিল্ড
  String? guarantorVideo;
  String? guarantorVideoUrl;

  // 📌 গ্যারান্টরের ডকুমেন্ট লিস্ট
  List<Document>? documents;

  Guarantor({
    this.name,
    this.phone,
    this.relationship,
    this.idType,
    this.nidPassportNumber,
    this.nidFront,
    this.nidBack,
    this.profileImage,
    this.guarantorVideo,
    this.guarantorVideoUrl,
    this.documents,
  });

  Guarantor.fromJson(Map<String, dynamic> json) {
    name = json['name']?.toString();
    phone = json['phone']?.toString();
    relationship = json['relationship']?.toString();
    idType = json['idType']?.toString();
    nidPassportNumber = json['nidPassportNumber']?.toString();
    nidFront = json['nidFront']?.toString();
    nidBack = json['nidBack']?.toString();
    profileImage = json['profileImage']?.toString();

    // 📌 ভিডিও URL গুলো পার্স করা
    guarantorVideo = json['guarantorVideo']?.toString() ?? json['guarantorVideoUrl']?.toString();
    guarantorVideoUrl = json['guarantorVideoUrl']?.toString();

    // 📌 documents অ্যারে পার্স করা
    if (json['documents'] != null) {
      documents = <Document>[];
      json['documents'].forEach((v) {
        documents!.add(Document.fromJson(v));
      });
    }

    // 📌 guarantorDocuments থেকেও ডকুমেন্ট নেওয়া
    if (json['guarantorDocuments'] != null) {
      if (documents == null) documents = <Document>[];
      json['guarantorDocuments'].forEach((v) {
        documents!.add(Document.fromJson(v));
      });
    }
  }
}
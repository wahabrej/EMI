class SellerNotificationModel {
  bool? success;
  NotificationData? data;

  SellerNotificationModel({this.success, this.data});

  SellerNotificationModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? NotificationData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['success'] = success;
    if (data != null) {
      map['data'] = data!.toJson();
    }
    return map;
  }
}

class NotificationData {
  List<Items>? items;
  int? unreadCount;
  Pagination? pagination;

  NotificationData({this.items, this.unreadCount, this.pagination});

  NotificationData.fromJson(Map<String, dynamic> json) {
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items!.add(Items.fromJson(v));
      });
    }
    unreadCount = json['unreadCount'];
    pagination = json['pagination'] != null
        ? Pagination.fromJson(json['pagination'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    if (items != null) {
      map['items'] = items!.map((v) => v.toJson()).toList();
    }
    map['unreadCount'] = unreadCount;
    if (pagination != null) {
      map['pagination'] = pagination!.toJson();
    }
    return map;
  }
}

class Items {
  String? id;
  String? type;
  String? category;
  String? severity;
  String? title;
  String? body;
  String? createdAt;
  bool? pinned;
  Action? action;
  NotificationPayload? data;
  bool? read;

  Items({
    this.id,
    this.type,
    this.category,
    this.severity,
    this.title,
    this.body,
    this.createdAt,
    this.pinned,
    this.action,
    this.data,
    this.read,
  });

  Items.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    category = json['category'];
    severity = json['severity'];
    title = json['title'];
    body = json['body'];
    createdAt = json['createdAt'];
    pinned = json['pinned'];
    action = json['action'] != null ? Action.fromJson(json['action']) : null;
    data = json['data'] != null ? NotificationPayload.fromJson(json['data']) : null;
    read = json['read'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['id'] = id;
    map['type'] = type;
    map['category'] = category;
    map['severity'] = severity;
    map['title'] = title;
    map['body'] = body;
    map['createdAt'] = createdAt;
    map['pinned'] = pinned;
    if (action != null) {
      map['action'] = action!.toJson();
    }
    if (data != null) {
      map['data'] = data!.toJson();
    }
    map['read'] = read;
    return map;
  }
}

class Action {
  String? type;
  String? id;

  Action({this.type, this.id});

  Action.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['type'] = type;
    map['id'] = id;
    return map;
  }
}

class NotificationPayload {
  String? applicationId;
  String? applicationDisplayId;
  String? customerId;
  String? customerName;
  String? customerPhone;
  String? productName;
  String? mrp;
  int? planMonths;
  String? monthlyEmi;
  String? loanId;
  String? loanDisplayId;
  String? loanStatus;

  NotificationPayload({
    this.applicationId,
    this.applicationDisplayId,
    this.customerId,
    this.customerName,
    this.customerPhone,
    this.productName,
    this.mrp,
    this.planMonths,
    this.monthlyEmi,
    this.loanId,
    this.loanDisplayId,
    this.loanStatus,
  });

  NotificationPayload.fromJson(Map<String, dynamic> json) {
    applicationId = json['applicationId'];
    applicationDisplayId = json['applicationDisplayId'];
    customerId = json['customerId'];
    customerName = json['customerName'];
    customerPhone = json['customerPhone'];
    productName = json['productName'];
    mrp = json['mrp'];
    planMonths = json['planMonths'];
    monthlyEmi = json['monthlyEmi'];
    loanId = json['loanId'];
    loanDisplayId = json['loanDisplayId'];
    loanStatus = json['loanStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['applicationId'] = applicationId;
    map['applicationDisplayId'] = applicationDisplayId;
    map['customerId'] = customerId;
    map['customerName'] = customerName;
    map['customerPhone'] = customerPhone;
    map['productName'] = productName;
    map['mrp'] = mrp;
    map['planMonths'] = planMonths;
    map['monthlyEmi'] = monthlyEmi;
    map['loanId'] = loanId;
    map['loanDisplayId'] = loanDisplayId;
    map['loanStatus'] = loanStatus;
    return map;
  }
}

class Pagination {
  int? page;
  int? limit;
  int? total;
  int? totalPages;

  Pagination({this.page, this.limit, this.total, this.totalPages});

  Pagination.fromJson(Map<String, dynamic> json) {
    page = json['page'];
    limit = json['limit'];
    total = json['total'];
    totalPages = json['totalPages'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['page'] = page;
    map['limit'] = limit;
    map['total'] = total;
    map['totalPages'] = totalPages;
    return map;
  }
}

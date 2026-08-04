class OrderSummaryModel {
  bool? success;
  Data? data;

  OrderSummaryModel({this.success, this.data});

  OrderSummaryModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  Range? range;
  int? totalProductsSold;
  StatusBreakdown? statusBreakdown;
  String? totalSalesValue;
  String? totalCollected;
  String? totalOutstanding;
  List<TopProducts>? topProducts;

  Data(
      {this.range,
        this.totalProductsSold,
        this.statusBreakdown,
        this.totalSalesValue,
        this.totalCollected,
        this.totalOutstanding,
        this.topProducts});

  Data.fromJson(Map<String, dynamic> json) {
    range = json['range'] != null ? new Range.fromJson(json['range']) : null;
    totalProductsSold = json['totalProductsSold'];
    statusBreakdown = json['statusBreakdown'] != null
        ? new StatusBreakdown.fromJson(json['statusBreakdown'])
        : null;
    totalSalesValue = json['totalSalesValue'];
    totalCollected = json['totalCollected'];
    totalOutstanding = json['totalOutstanding'];
    if (json['topProducts'] != null) {
      topProducts = <TopProducts>[];
      json['topProducts'].forEach((v) {
        topProducts!.add(new TopProducts.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.range != null) {
      data['range'] = this.range!.toJson();
    }
    data['totalProductsSold'] = this.totalProductsSold;
    if (this.statusBreakdown != null) {
      data['statusBreakdown'] = this.statusBreakdown!.toJson();
    }
    data['totalSalesValue'] = this.totalSalesValue;
    data['totalCollected'] = this.totalCollected;
    data['totalOutstanding'] = this.totalOutstanding;
    if (this.topProducts != null) {
      data['topProducts'] = this.topProducts!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Range {
  Null? from;
  Null? to;

  Range({this.from, this.to});

  Range.fromJson(Map<String, dynamic> json) {
    from = json['from'];
    to = json['to'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['from'] = this.from;
    data['to'] = this.to;
    return data;
  }
}

class StatusBreakdown {
  int? aPPROVED;

  StatusBreakdown({this.aPPROVED});

  StatusBreakdown.fromJson(Map<String, dynamic> json) {
    aPPROVED = json['APPROVED'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['APPROVED'] = this.aPPROVED;
    return data;
  }
}

class TopProducts {
  String? productName;
  String? brand;
  int? unitsSold;

  TopProducts({this.productName, this.brand, this.unitsSold});

  TopProducts.fromJson(Map<String, dynamic> json) {
    productName = json['productName'];
    brand = json['brand'];
    unitsSold = json['unitsSold'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['productName'] = this.productName;
    data['brand'] = this.brand;
    data['unitsSold'] = this.unitsSold;
    return data;
  }
}

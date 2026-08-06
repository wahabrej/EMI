class ProfileResponse {
  bool? success;
  ProfileData? data;

  ProfileResponse({this.success, this.data});

  ProfileResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? ProfileData.fromJson(json['data']) : null;
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

class ProfileData {
  String? id;
  String? email;
  String? name;
  bool? isStaff;
  String? staffEntityType;
  String? shopId;
  String? agentId;
  String? managerId;
  String? salesPersonId;
  String? customerId;
  String? createdAt;
  String? updatedAt;
  List<Roles>? roles;
  List<dynamic>? permissions;
  String? roleSlug;

  ProfileData({
    this.id,
    this.email,
    this.name,
    this.isStaff,
    this.staffEntityType,
    this.shopId,
    this.agentId,
    this.managerId,
    this.salesPersonId,
    this.customerId,
    this.createdAt,
    this.updatedAt,
    this.roles,
    this.permissions,
    this.roleSlug,
  });

  ProfileData.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String?;
    email = json['email'] as String?;
    name = json['name'] as String?;
    isStaff = json['isStaff'] as bool?;
    staffEntityType = json['staffEntityType'] as String?;
    shopId = json['shopId'] as String?;
    agentId = json['agentId'] as String?;
    managerId = json['managerId'] as String?;
    salesPersonId = json['salesPersonId'] as String?;
    customerId = json['customerId'] as String?;
    createdAt = json['createdAt'] as String?;
    updatedAt = json['updatedAt'] as String?;

    if (json['roles'] != null) {
      roles = <Roles>[];
      (json['roles'] as List).forEach((v) {
        roles!.add(Roles.fromJson(v));
      });
    }

    if (json['permissions'] != null) {
      permissions = json['permissions'] as List<dynamic>;
    }

    roleSlug = json['roleSlug'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['email'] = email;
    data['name'] = name;
    data['isStaff'] = isStaff;
    data['staffEntityType'] = staffEntityType;
    data['shopId'] = shopId;
    data['agentId'] = agentId;
    data['managerId'] = managerId;
    data['salesPersonId'] = salesPersonId;
    data['customerId'] = customerId;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;

    if (roles != null) {
      data['roles'] = roles!.map((v) => v.toJson()).toList();
    }

    if (permissions != null) {
      data['permissions'] = permissions!;
    }

    data['roleSlug'] = roleSlug;
    return data;
  }
}

class Roles {
  Role? role;

  Roles({this.role});

  Roles.fromJson(Map<String, dynamic> json) {
    role = json['role'] != null ? Role.fromJson(json['role']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (role != null) {
      data['role'] = role!.toJson();
    }
    return data;
  }
}

class Role {
  String? id;
  String? name;
  String? displayName;
  List<Permissions>? permissions;

  Role({this.id, this.name, this.displayName, this.permissions});

  Role.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String?;
    name = json['name'] as String?;
    displayName = json['displayName'] as String?;

    if (json['permissions'] != null) {
      permissions = <Permissions>[];
      (json['permissions'] as List).forEach((v) {
        permissions!.add(Permissions.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['displayName'] = displayName;

    if (permissions != null) {
      data['permissions'] = permissions!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Permissions {
  Permission? permission;

  Permissions({this.permission});

  Permissions.fromJson(Map<String, dynamic> json) {
    permission = json['permission'] != null
        ? Permission.fromJson(json['permission'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (permission != null) {
      data['permission'] = permission!.toJson();
    }
    return data;
  }
}

class Permission {
  String? resource;
  String? action;

  Permission({this.resource, this.action});

  Permission.fromJson(Map<String, dynamic> json) {
    resource = json['resource'] as String?;
    action = json['action'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['resource'] = resource;
    data['action'] = action;
    return data;
  }
}
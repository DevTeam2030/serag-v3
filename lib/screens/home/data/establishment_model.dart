// class EstablishmentModel {
//   final int id;
//   final String name;
//   final String status;
//
//   EstablishmentModel({
//     required this.id,
//     required this.name,
//     required this.status,
//   });
//
//   factory EstablishmentModel.fromJson(Map<String, dynamic> json) {
//     return EstablishmentModel(
//       id: json['id'] as int? ?? 0,
//       name: json['name'] as String? ?? '',
//       status: json['status'] as String? ?? '',
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'status': status,
//     };
//   }
// }
//
// class EstablishmentResponse {
//   final int status;
//   final String message;
//   final List<EstablishmentModel> data;
//
//   EstablishmentResponse({
//     required this.status,
//     required this.message,
//     required this.data,
//   });
//
//   factory EstablishmentResponse.fromJson(Map<String, dynamic> json) {
//     return EstablishmentResponse(
//       status: json['status'] as int? ?? 0,
//       message: json['message'] as String? ?? '',
//       data: (json['data'] as List<dynamic>?)
//           ?.map((item) => EstablishmentModel.fromJson(item as Map<String, dynamic>))
//           .toList() ??
//           [],
//     );
//   }
// }
//
// class AssignEstablishmentResponse {
//   final int status;
//   final String message;
//   final EstablishmentUserData? data;
//
//   AssignEstablishmentResponse({
//     required this.status,
//     required this.message,
//     this.data,
//   });
//
//   factory AssignEstablishmentResponse.fromJson(Map<String, dynamic> json) {
//     return AssignEstablishmentResponse(
//       status: json['status'] as int? ?? 0,
//       message: json['message'] as String? ?? '',
//       data: json['data'] != null
//           ? EstablishmentUserData.fromJson(json['data'] as Map<String, dynamic>)
//           : null,
//     );
//   }
// }
//
// class EstablishmentUserData {
//   final String accessToken;
//   final String tokenType;
//   final int expiresIn;
//   final int id;
//   final String type;
//   final String? name;
//   final String? tenantName;
//   final String? email;
//   final String phone;
//   final bool emailVerifiedAt;
//   final String? buildingType;
//   final int? buildingTypeId;
//   final String? technicalCondition;
//   final int? technicalConditionId;
//   final String? heatingSystem;
//   final int? heatingSystemId;
//   final String? waterSource;
//   final int? waterSourceId;
//   final String? powerSource;
//   final int? powerSourceId;
//   final String? supervisingDoctor;
//   final String? licenseNumber;
//   final String? licenseDate;
//   final String? area;
//   final int? areaId;
//   final String? numberFloors;
//   final String longitude;
//   final String latitude;
//   final String cityId;
//   final String city;
//   final String userArea;
//   final String establishmentTypeId;
//   final String? establishmentName;
//   final bool isActive;
//   final int machinesCount;
//   final String? machineType;
//   final int cagesCount;
//   final double feedEggAvg;
//   final double feedBroilerAvg;
//   final double cartonBundleAvg;
//   final String? other;
//
//   EstablishmentUserData({
//     required this.accessToken,
//     required this.tokenType,
//     required this.expiresIn,
//     required this.id,
//     required this.type,
//     this.name,
//     this.tenantName,
//     this.email,
//     required this.phone,
//     required this.emailVerifiedAt,
//     this.buildingType,
//     this.buildingTypeId,
//     this.technicalCondition,
//     this.technicalConditionId,
//     this.heatingSystem,
//     this.heatingSystemId,
//     this.waterSource,
//     this.waterSourceId,
//     this.powerSource,
//     this.powerSourceId,
//     this.supervisingDoctor,
//     this.licenseNumber,
//     this.licenseDate,
//     this.area,
//     this.areaId,
//     this.numberFloors,
//     required this.longitude,
//     required this.latitude,
//     required this.cityId,
//     required this.city,
//     required this.userArea,
//     required this.establishmentTypeId,
//     this.establishmentName,
//     required this.isActive,
//     required this.machinesCount,
//     this.machineType,
//     required this.cagesCount,
//     required this.feedEggAvg,
//     required this.feedBroilerAvg,
//     required this.cartonBundleAvg,
//     this.other,
//   });
//
//   factory EstablishmentUserData.fromJson(Map<String, dynamic> json) {
//     String _safeString(dynamic value, [String defaultValue = '']) {
//       if (value == null) return defaultValue;
//       return value.toString();
//     }
//
//     int _safeInt(dynamic value, [int defaultValue = 0]) {
//       if (value == null) return defaultValue;
//       if (value is int) return value;
//       if (value is String) return int.tryParse(value) ?? defaultValue;
//       if (value is num) return value.toInt();
//       return defaultValue;
//     }
//
//     // Helper function to safely convert to double
//     double _safeDouble(dynamic value, [double defaultValue = 0.0]) {
//       if (value == null) return defaultValue;
//       if (value is double) return value;
//       if (value is int) return value.toDouble();
//       if (value is String) return double.tryParse(value) ?? defaultValue;
//       if (value is num) return value.toDouble();
//       return defaultValue;
//     }
//
//     // Helper function to safely convert to bool
//     bool _safeBool(dynamic value) {
//       if (value == null) return false;
//       if (value is bool) return value;
//       if (value is int) return value == 1;
//       if (value is String) return value.toLowerCase() == 'true' || value == '1';
//       return false;
//     }
//
//     return EstablishmentUserData(
//       accessToken: _safeString(json['access_token']),
//       tokenType: _safeString(json['token_type'], 'Bearer'),
//       expiresIn: _safeInt(json['expires_in']),
//       id: _safeInt(json['id']),
//       type: _safeString(json['type']),
//       name: json['name'] as String?,
//       tenantName: json['tenant_name'] as String?,
//       email: json['email'] as String?,
//       phone: _safeString(json['phone']),
//       emailVerifiedAt: _safeBool(json['email_verified_at']),
//       buildingType: json['building_type'] as String?,
//       buildingTypeId: json['building_type_id'] as int?,
//       technicalCondition: json['technical_condition'] as String?,
//       technicalConditionId: json['technical_condition_id'] as int?,
//       heatingSystem: json['heating_system'] as String?,
//       heatingSystemId: json['heating_system_id'] as int?,
//       waterSource: json['water_source'] as String?,
//       waterSourceId: json['water_source_id'] as int?,
//       powerSource: json['power_source'] as String?,
//       powerSourceId: json['power_source_id'] as int?,
//       supervisingDoctor: json['supervising_doctor'] as String?,
//       licenseNumber: json['license_number'] as String?,
//       licenseDate: json['license_date'] as String?,
//       area: json['area'] as String?,
//       areaId: json['area_id'] as int?,
//       numberFloors: json['number_floors']?.toString(),
//       longitude: _safeString(json['longitude'], '0.0'),
//       latitude: _safeString(json['latitude'], '0.0'),
//       cityId: _safeString(json['city_id']),
//       city: _safeString(json['city']),
//       userArea: _safeString(json['user_area']),
//       establishmentTypeId: _safeString(json['establishment_type_id']),
//       establishmentName: json['establishment_name'] as String?,
//       isActive: _safeBool(json['is_active']),
//       machinesCount: _safeInt(json['machines_count']),
//       machineType: json['machine_type'] as String?,
//       cagesCount: _safeInt(json['cages_count']),
//       feedEggAvg: _safeDouble(json['feed_egg_avg']),
//       feedBroilerAvg: _safeDouble(json['feed_broiler_avg']),
//       cartonBundleAvg: _safeDouble(json['carton_bundle_avg']),
//       other: json['other'] as String?,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'access_token': accessToken,
//       'token_type': tokenType,
//       'expires_in': expiresIn,
//       'id': id,
//       'type': type,
//       'name': name,
//       'tenant_name': tenantName,
//       'email': email,
//       'phone': phone,
//       'email_verified_at': emailVerifiedAt,
//       'building_type': buildingType,
//       'building_type_id': buildingTypeId,
//       'technical_condition': technicalCondition,
//       'technical_condition_id': technicalConditionId,
//       'heating_system': heatingSystem,
//       'heating_system_id': heatingSystemId,
//       'water_source': waterSource,
//       'water_source_id': waterSourceId,
//       'power_source': powerSource,
//       'power_source_id': powerSourceId,
//       'supervising_doctor': supervisingDoctor,
//       'license_number': licenseNumber,
//       'license_date': licenseDate,
//       'area': area,
//       'area_id': areaId,
//       'number_floors': numberFloors,
//       'longitude': longitude,
//       'latitude': latitude,
//       'city_id': cityId,
//       'city': city,
//       'user_area': userArea,
//       'establishment_type_id': establishmentTypeId,
//       'establishment_name': establishmentName,
//       'is_active': isActive,
//       'machines_count': machinesCount,
//       'machine_type': machineType,
//       'cages_count': cagesCount,
//       'feed_egg_avg': feedEggAvg,
//       'feed_broiler_avg': feedBroilerAvg,
//       'carton_bundle_avg': cartonBundleAvg,
//       'other': other,
//     };
//   }
// }


class EstablishmentModel {
  final int id;
  final String name;
  final String status;

  EstablishmentModel({
    required this.id,
    required this.name,
    required this.status,
  });

  factory EstablishmentModel.fromJson(Map<String, dynamic> json) {
    return EstablishmentModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      status: json['status'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status,
    };
  }
}

class EstablishmentResponse {
  final int status;
  final String message;
  final List<EstablishmentModel> data;

  EstablishmentResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory EstablishmentResponse.fromJson(Map<String, dynamic> json) {
    return EstablishmentResponse(
      status: json['status'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => EstablishmentModel.fromJson(item as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }
}

class AssignEstablishmentResponse {
  final int status;
  final String message;
  final EstablishmentUserData? data;

  AssignEstablishmentResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory AssignEstablishmentResponse.fromJson(Map<String, dynamic> json) {
    return AssignEstablishmentResponse(
      status: json['status'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? EstablishmentUserData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class EstablishmentUserData {
  final String? accessToken; // Made nullable - API returns null
  final String tokenType;
  final int expiresIn;
  final int id;
  final String type;
  final String? name;
  final String? tenantName;
  final String? email;
  final String phone;
  final bool emailVerifiedAt;
  final String? buildingType;
  final int? buildingTypeId;
  final String? technicalCondition;
  final int? technicalConditionId;
  final String? heatingSystem;
  final int? heatingSystemId;
  final String? waterSource;
  final int? waterSourceId;
  final String? powerSource;
  final int? powerSourceId;
  final String? supervisingDoctor;
  final String? licenseNumber;
  final String? licenseDate;
  final String? area;
  final int? areaId;
  final String? numberFloors;
  final String longitude;
  final String latitude;
  final String cityId;
  final String city;
  final String userArea;
  final String establishmentTypeId;
  final String? establishmentName;
  final bool isActive;
  final int machinesCount;
  final String? machineType;
  final int cagesCount;
  final double feedEggAvg;
  final double feedBroilerAvg;
  final double cartonBundleAvg;
  final String? other;

  EstablishmentUserData({
    this.accessToken, // Now optional
    required this.tokenType,
    required this.expiresIn,
    required this.id,
    required this.type,
    this.name,
    this.tenantName,
    this.email,
    required this.phone,
    required this.emailVerifiedAt,
    this.buildingType,
    this.buildingTypeId,
    this.technicalCondition,
    this.technicalConditionId,
    this.heatingSystem,
    this.heatingSystemId,
    this.waterSource,
    this.waterSourceId,
    this.powerSource,
    this.powerSourceId,
    this.supervisingDoctor,
    this.licenseNumber,
    this.licenseDate,
    this.area,
    this.areaId,
    this.numberFloors,
    required this.longitude,
    required this.latitude,
    required this.cityId,
    required this.city,
    required this.userArea,
    required this.establishmentTypeId,
    this.establishmentName,
    required this.isActive,
    required this.machinesCount,
    this.machineType,
    required this.cagesCount,
    required this.feedEggAvg,
    required this.feedBroilerAvg,
    required this.cartonBundleAvg,
    this.other,
  });

  factory EstablishmentUserData.fromJson(Map<String, dynamic> json) {
    String _safeString(dynamic value, [String defaultValue = '']) {
      if (value == null) return defaultValue;
      if (value is String && value.trim().isEmpty) return defaultValue;
      return value.toString();
    }

    int _safeInt(dynamic value, [int defaultValue = 0]) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is String) {
        if (value.trim().isEmpty) return defaultValue;
        return int.tryParse(value) ?? defaultValue;
      }
      if (value is num) return value.toInt();
      return defaultValue;
    }

    double _safeDouble(dynamic value, [double defaultValue = 0.0]) {
      if (value == null) return defaultValue;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        if (value.trim().isEmpty) return defaultValue;
        return double.tryParse(value) ?? defaultValue;
      }
      if (value is num) return value.toDouble();
      return defaultValue;
    }

    bool _safeBool(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) {
        final lower = value.toLowerCase().trim();
        return lower == 'true' || lower == '1';
      }
      return false;
    }

    return EstablishmentUserData(
      accessToken: json['access_token'] as String?, // Allow null
      tokenType: _safeString(json['token_type'], 'bearer'),
      expiresIn: _safeInt(json['expires_in']),
      id: _safeInt(json['id']),
      type: _safeString(json['type'], 'doctor'),
      name: json['name'] as String?,
      tenantName: json['tenant_name'] as String?,
      email: json['email'] as String?,
      phone: _safeString(json['phone']),
      emailVerifiedAt: _safeBool(json['email_verified_at']),
      buildingType: json['building_type'] as String?,
      buildingTypeId: _safeInt(json['building_type_id']),
      technicalCondition: json['technical_condition'] as String?,
      technicalConditionId: _safeInt(json['technical_condition_id']),
      heatingSystem: json['heating_system'] as String?,
      heatingSystemId: _safeInt(json['heating_system_id']),
      waterSource: json['water_source'] as String?,
      waterSourceId: _safeInt(json['water_source_id']),
      powerSource: json['power_source'] as String?,
      powerSourceId: _safeInt(json['power_source_id']),
      supervisingDoctor: json['supervising_doctor'] as String?,
      licenseNumber: json['license_number'] as String?,
      licenseDate: json['license_date'] as String?,
      area: json['area'] as String?,
      areaId: json['area_id'] as int?,
      numberFloors: json['number_floors']?.toString(),
      longitude: _safeString(json['longitude'], '0.0'),
      latitude: _safeString(json['latitude'], '0.0'),
      cityId: _safeString(json['city_id']),
      city: _safeString(json['city']),
      userArea: _safeString(json['user_area']),
      establishmentTypeId: _safeString(json['establishment_type_id']),
      establishmentName: json['establishment_name'] as String?,
      isActive: _safeBool(json['is_active']),
      machinesCount: _safeInt(json['machines_count']),
      machineType: json['machine_type'] as String?,
      cagesCount: _safeInt(json['cages_count']),
      feedEggAvg: _safeDouble(json['feed_egg_avg']),
      feedBroilerAvg: _safeDouble(json['feed_broiler_avg']),
      cartonBundleAvg: _safeDouble(json['carton_bundle_avg']),
      other: json['other'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'token_type': tokenType,
      'expires_in': expiresIn,
      'id': id,
      'type': type,
      'name': name,
      'tenant_name': tenantName,
      'email': email,
      'phone': phone,
      'email_verified_at': emailVerifiedAt,
      'building_type': buildingType,
      'building_type_id': buildingTypeId,
      'technical_condition': technicalCondition,
      'technical_condition_id': technicalConditionId,
      'heating_system': heatingSystem,
      'heating_system_id': heatingSystemId,
      'water_source': waterSource,
      'water_source_id': waterSourceId,
      'power_source': powerSource,
      'power_source_id': powerSourceId,
      'supervising_doctor': supervisingDoctor,
      'license_number': licenseNumber,
      'license_date': licenseDate,
      'area': area,
      'area_id': areaId,
      'number_floors': numberFloors,
      'longitude': longitude,
      'latitude': latitude,
      'city_id': cityId,
      'city': city,
      'user_area': userArea,
      'establishment_type_id': establishmentTypeId,
      'establishment_name': establishmentName,
      'is_active': isActive,
      'machines_count': machinesCount,
      'machine_type': machineType,
      'cages_count': cagesCount,
      'feed_egg_avg': feedEggAvg,
      'feed_broiler_avg': feedBroilerAvg,
      'carton_bundle_avg': cartonBundleAvg,
      'other': other,
    };
  }

  // Helper method to create a copy with a new access token
  EstablishmentUserData copyWithToken(String token) {
    return EstablishmentUserData(
      accessToken: token,
      tokenType: tokenType,
      expiresIn: expiresIn,
      id: id,
      type: type,
      name: name,
      tenantName: tenantName,
      email: email,
      phone: phone,
      emailVerifiedAt: emailVerifiedAt,
      buildingType: buildingType,
      buildingTypeId: buildingTypeId,
      technicalCondition: technicalCondition,
      technicalConditionId: technicalConditionId,
      heatingSystem: heatingSystem,
      heatingSystemId: heatingSystemId,
      waterSource: waterSource,
      waterSourceId: waterSourceId,
      powerSource: powerSource,
      powerSourceId: powerSourceId,
      supervisingDoctor: supervisingDoctor,
      licenseNumber: licenseNumber,
      licenseDate: licenseDate,
      area: area,
      areaId: areaId,
      numberFloors: numberFloors,
      longitude: longitude,
      latitude: latitude,
      cityId: cityId,
      city: city,
      userArea: userArea,
      establishmentTypeId: establishmentTypeId,
      establishmentName: establishmentName,
      isActive: isActive,
      machinesCount: machinesCount,
      machineType: machineType,
      cagesCount: cagesCount,
      feedEggAvg: feedEggAvg,
      feedBroilerAvg: feedBroilerAvg,
      cartonBundleAvg: cartonBundleAvg,
      other: other,
    );
  }
}
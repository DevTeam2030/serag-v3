// models/section_request_model.dart

class SectionRequestModel {
  final String name;
  final bool isWorking;
  final String longitude;
  final String latitude;
  final int categoryId;

  SectionRequestModel({
    required this.name,
    required this.isWorking,
    required this.longitude,
    required this.latitude,
    required this.categoryId,
  });

  Map<String, dynamic> toJson() => {
    "name": name,
    "is_working": isWorking,
    "longitude": longitude,
    "latitude": latitude,
    "category_id": categoryId,
  };
}

class SectionRequestResponse {
  final int status;
  final String message;
  final dynamic data;

  SectionRequestResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory SectionRequestResponse.fromJson(Map<String, dynamic> json) =>
      SectionRequestResponse(
        status: json["status"],
        message: json["message"],
        data: json["data"],
      );
}
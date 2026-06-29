import 'package:flutter/foundation.dart';

enum ProjectStatus { open, closed }

@immutable
class ProjectModel {
  final String id;
  final String name; // e.g. "1 مشروع"
  final String species; // دجاج / فروج / بيض مائدة ...
  final String subCategory;
  final DateTime startDate;
  final DateTime endDate;
  final String image; // asset path
  final ProjectStatus status;

  // Financial snapshot shown on details screen
  final String chicksSource;
  final int chicksCount;
  final String distributionChannel;
  final String feedSource;
  final String feedAmount; // "100 كج"
  final String conversionRate; // "30%"
  final int deadBirds;
  final String diseaseType;
  final String vaccinationProgram;

  const ProjectModel({
    required this.id,
    required this.name,
    required this.species,
    required this.subCategory,
    required this.startDate,
    required this.endDate,
    required this.image,
    required this.status,
    required this.chicksSource,
    required this.chicksCount,
    required this.distributionChannel,
    required this.feedSource,
    required this.feedAmount,
    required this.conversionRate,
    required this.deadBirds,
    required this.diseaseType,
    required this.vaccinationProgram,
  });
  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'].toString(),
      name: json['name'] ?? "",
      species: json['category'] ?? "",
      subCategory: json['sub_category'] ?? "",
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['expected_end_date']),
      image: "", // API does not provide image
      status: json['status'] == 'open' ? ProjectStatus.open : ProjectStatus.closed,
      chicksSource: json['chick_source'] ?? "",
      chicksCount: json['number_of_chicks'] ?? 0,
      distributionChannel: json['distribution_channel'] ?? "",
      feedSource: json['feed_source'] ?? "",
      feedAmount: json['feed_quantity'] ?? "",
      conversionRate: json['conversion_rate'] ?? "",
      deadBirds: json['dead_birds'] ?? 0,
      diseaseType: json['disease_type'] ?? "",
      vaccinationProgram: json['vaccination_program'] ?? "",
    );
  }

  ProjectModel copyWith({
    ProjectStatus? status,  String? chicksSource,
  }) {
    return ProjectModel(
      id: id,
      name: name,
      species: species,
      startDate: startDate,
      endDate: endDate,
      image: image,
      status: status ?? this.status,
      chicksSource: chicksSource?? this.chicksSource,
      chicksCount: chicksCount,
      distributionChannel: distributionChannel,
      feedSource: feedSource,
      feedAmount: feedAmount,
      conversionRate: conversionRate,
      deadBirds: deadBirds,
      diseaseType: diseaseType,
      vaccinationProgram: vaccinationProgram, subCategory: subCategory,
    );
  }
}

class ProjectDetailsModel {
  final String id;
  final String userId;
  final String user;
  final String name;
  final String species;
  final int categoryId;
  final String subCategory;
  final int subCategoryId;
  final DateTime startDate;
  final DateTime endDate;
  final ProjectStatus status;
  final String meatQuantity;
  final String chicksSource;
  final int chicksCount;
  final String distributionChannel;
  final int distributionChannelId;
  final String feedSource;
  final String feedAmount;
  final String conversionRate;
  final int deadBirds;
  final int diseaseTypeId;
  final String diseaseType;
  final int vaccinationProgramId;
  final String vaccinationProgram;
  final String? diseaseTypeName;
  final String? vaccinationProgramName;
  const ProjectDetailsModel({
    required this.id,
    required this.userId,
    required this.user,
    required this.name,
    required this.species,
    required this.categoryId,
    required this.subCategory,
    required this.subCategoryId,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.chicksSource,
    required this.chicksCount,
    required this.distributionChannel,
    required this.distributionChannelId,
    required this.feedSource,
    required this.feedAmount,
    required this.conversionRate,
    required this.deadBirds,
    required this.diseaseTypeId,
    required this.diseaseType,
    required this.vaccinationProgramId,
    required this.vaccinationProgram,
      required this.meatQuantity,
    this.diseaseTypeName,
    this.vaccinationProgramName,
  });

  // factory ProjectDetailsModel.fromJson(Map<String, dynamic> json) {
  //   return ProjectDetailsModel(
  //     id: json['id'].toString(),
  //     userId: json['user_id'].toString(),
  //     user: json['user'] ?? "",
  //     name: json['name'] ?? "",
  //     species: json['category'] ?? "",
  //     categoryId: json['category_id'] ?? 0,
  //     subCategory: json['sub_category'] ?? "",
  //     subCategoryId: json['sub_category_id'] ?? 0,
  //     startDate: DateTime.parse(json['start_date']),
  //     endDate: DateTime.parse(json['expected_end_date']),
  //     status: json['status'] == 'open' ? ProjectStatus.open : ProjectStatus.closed,
  //     chicksSource: json['chick_source'] ?? "لا يوجد",
  //     chicksCount: json['number_of_chicks'] ?? 0,
  //     distributionChannel: json['distribution_channel'] ?? "لا يوجد",
  //     distributionChannelId: json['distribution_channel_id'] ?? 0,
  //     feedSource: json['feed_source'] ?? "",
  //     feedAmount: json['feed_quantity'] ?? "",
  //     conversionRate: json['conversion_rate'] ?? "",
  //     deadBirds: json['dead_birds'] ?? 0,
  //     diseaseTypeId: json['disease_type_id'] ?? 0,
  //     diseaseType: json['disease_type'] ?? "",
  //     vaccinationProgramId: json['vaccination_program_id'] ?? 0,
  //     vaccinationProgram: json['vaccination_program'] ?? "",
  //     meatQuantity: json['quantity_sold_meat']?.toString() ?? "",
  //     diseaseTypeName: json['disease_type']?? "",  // ✅
  //     vaccinationProgramName: json['vaccination_program']??"", // ✅
  //   );
  // }
  factory ProjectDetailsModel.fromJson(Map<String, dynamic> json) {
    int _toInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return ProjectDetailsModel(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      user: json['user'] ?? "",
      name: json['name'] ?? "",
      species: json['category'] ?? "",
      categoryId: _toInt(json['category_id']),
      subCategory: json['sub_category'] ?? "",
      subCategoryId: _toInt(json['sub_category_id']),
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['expected_end_date']),
      status: json['status'] == 'open' ? ProjectStatus.open : ProjectStatus.closed,
      chicksSource: json['chick_source'] ?? "لا يوجد",
      chicksCount: _toInt(json['number_of_chicks']),
      distributionChannel: json['distribution_channel'] ?? "لا يوجد",
      distributionChannelId: _toInt(json['distribution_channel_id']),
      feedSource: json['feed_source'] ?? "",
      feedAmount: json['feed_quantity'] ?? "",
      conversionRate: json['conversion_rate'] ?? "",
      deadBirds: _toInt(json['dead_birds']),
      diseaseTypeId: _toInt(json['disease_type_id']),
      diseaseType: json['disease_type'] ?? "",
      vaccinationProgramId: _toInt(json['vaccination_program_id']),
      vaccinationProgram: json['vaccination_program'] ?? "",
      meatQuantity: json['quantity_sold_meat']?.toString() ?? "",
      diseaseTypeName: json['disease_type'] ?? "",
      vaccinationProgramName: json['vaccination_program'] ?? "",
    );
  }


}
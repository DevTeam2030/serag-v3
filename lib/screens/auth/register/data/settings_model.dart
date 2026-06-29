// models/settings_response.dart
import 'dart:convert';

SettingsResponse settingsResponseFromJson(String str) =>
    SettingsResponse.fromJson(json.decode(str));

class SettingsResponse {
  final int status;
  final String message;
  final SettingsData data;

  SettingsResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory SettingsResponse.fromJson(Map<String, dynamic> json) =>
      SettingsResponse(
        status: json["status"],
        message: json["message"],
        data: SettingsData.fromJson(json["data"]),
      );
}

class SettingsData {
  final List<GeneralItem> cities;
  final List<Area> areas; // ✅ NEW: Changed from GeneralItem to Area
  final List<Category> categories;
  final List<OnboardPage> onboardPages;
  final List<GeneralItem> buildingTypes;
  final List<GeneralItem> technicalConditions;
  final List<GeneralItem> heatingSystems;
  final List<GeneralItem> waterSources;
  final List<GeneralItem> powerSources;
  final List<GeneralItem> diseaseTypes;
  final List<GeneralItem> vaccinationPrograms;
  final List<GeneralItem> distributionChannels;
  final List<GeneralItem> establishmentTypes;
  final List<CurrencyModel> currencies;
  final String terms;
  final String inactivityDays;

  SettingsData({
    required this.cities,
    required this.areas, // ✅ NEW
    required this.categories,
    required this.onboardPages,
    required this.buildingTypes,
    required this.technicalConditions,
    required this.heatingSystems,
    required this.waterSources,
    required this.powerSources,
    required this.diseaseTypes,
    required this.vaccinationPrograms,
    required this.distributionChannels,
    required this.establishmentTypes,
    required this.currencies,
    required this.terms,
    required this.inactivityDays,
  });

  factory SettingsData.fromJson(Map<String, dynamic> json) => SettingsData(
    cities: _mapGeneral(json["cities"]),
    areas: List<Area>.from(json["areas"].map((x) => Area.fromJson(x))), // ✅ NEW
    categories: List<Category>.from(
        json["categories"].map((x) => Category.fromJson(x))),
    onboardPages: List<OnboardPage>.from(
        json["onborad_pages"].map((x) => OnboardPage.fromJson(x))),
    buildingTypes: _mapGeneral(json["building_types"]),
    technicalConditions: _mapGeneral(json["technical_conditions"]),
    heatingSystems: _mapGeneral(json["heating_systems"]),
    waterSources: _mapGeneral(json["water_sources"]),
    powerSources: _mapGeneral(json["power_sources"]),
    diseaseTypes: _mapGeneral(json["disease_types"]),
    vaccinationPrograms: _mapGeneral(json["vaccination_programs"]),
    distributionChannels: _mapGeneral(json["distribution_Channels"]),
    establishmentTypes: _mapGeneral(json["establishment_types"]),
    currencies: List<CurrencyModel>.from(
      json["currencies"].map(
            (x) => CurrencyModel.fromJson(x),
      ),
    ),
    terms: json["terms"],
    inactivityDays: json["inactivity_days"],
  );

  static List<GeneralItem> _mapGeneral(dynamic list) =>
      List<GeneralItem>.from(list.map((x) => GeneralItem.fromJson(x)));

  // ✅ NEW: Helper method to get areas for a specific city
  List<Area> getAreasForCity(int cityId) {
    return areas.where((area) => area.cityId == cityId.toString()).toList();
  }
}

// ✅ NEW: Area model with city_id
class Area {
  final int id;
  final String name;
  final String cityId;

  Area({
    required this.id,
    required this.name,
    required this.cityId,
  });

  factory Area.fromJson(Map<String, dynamic> json) => Area(
    id: json["id"],
    name: json["name"],
    cityId: json["city_id"].toString(),
  );
}

class Category {
  final int id;
  final String name;
  final String image;
  final List<SubCategory> subCategories;

  Category({
    required this.id,
    required this.name,
    required this.image,
    required this.subCategories,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json["id"],
    name: json["name"],
    image: json["image"],
    subCategories: List<SubCategory>.from(
        json["sub_categories"].map((x) => SubCategory.fromJson(x))),
  );
}

class SubCategory {
  final int id;
  final String name;
  final String image;

  SubCategory({
    required this.id,
    required this.name,
    required this.image,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) => SubCategory(
    id: json["id"],
    name: json["name"],
    image: json["image"],
  );
}

class OnboardPage {
  final String mainTitle;
  final String subTitle;
  final String image;

  OnboardPage({
    required this.mainTitle,
    required this.subTitle,
    required this.image,
  });

  factory OnboardPage.fromJson(Map<String, dynamic> json) => OnboardPage(
    mainTitle: json["main_title"],
    subTitle: json["sub_title"],
    image: json["image"],
  );
}

class GeneralItem {
  final int id;
  final String name;

  GeneralItem({
    required this.id,
    required this.name,
  });

  factory GeneralItem.fromJson(Map<String, dynamic> json) => GeneralItem(
    id: json["id"],
    name: json["name"],
  );
}
class CurrencyModel {

  final String key;

  final String value;

  CurrencyModel({
    required this.key,
    required this.value,
  });

  factory CurrencyModel.fromJson(
      Map<String,dynamic> json,
      ) {

    return CurrencyModel(
      key: json['key'],

      value: json['value'],
    );
  }
}
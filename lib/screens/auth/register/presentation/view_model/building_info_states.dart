import '../../data/settings_model.dart';

abstract class ProjectDataState {}

class BuildingInfoInitial extends ProjectDataState {}

class BuildingInfoLoading extends ProjectDataState {}

class BuildingInfoLoaded extends ProjectDataState {
  final SettingsData settingsData;
  BuildingInfoLoaded(this.settingsData);
}

class BuildingInfoValidationError extends ProjectDataState {
  final String message;
  BuildingInfoValidationError(this.message);
}

class BuildingInfoSuccess extends ProjectDataState {}

class BuildingInfoError extends ProjectDataState {
  final String message;
  BuildingInfoError(this.message);
}
class ProjectAreaSelected extends ProjectDataState {
  final String areaName;
  ProjectAreaSelected(this.areaName);
}
class ProjectCitySelected extends ProjectDataState {
  final int cityId;
  ProjectCitySelected(this.cityId);
}

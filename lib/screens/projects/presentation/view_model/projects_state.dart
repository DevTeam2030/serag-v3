import 'package:mine/screens/projects/data/projects_model.dart';

abstract class ProjectsState {}

class ProjectsInitial extends ProjectsState {}

class ProjectsLoading extends ProjectsState {}

// class ProjectsLoaded extends ProjectsState {
//   final List<ProjectModel> projects;
//   final bool canAddNew;
//
//   ProjectsLoaded(this.projects, this.canAddNew);
// }

// class ProjectActionInProgress extends ProjectsState {
//   final List<ProjectModel> projects;
//   final bool canAddNew;
//
//   ProjectActionInProgress(this.projects, this.canAddNew);
// }

class ProjectsFailure extends ProjectsState {
  final String message;

  ProjectsFailure(this.message);
}

class ProjectLoadingDetails extends ProjectsState {
  final List<ProjectModel> projects;
  final bool canAddNew;
  ProjectLoadingDetails(
      {
      required this.projects,
      required this.canAddNew});
}

class ProjectDetailsLoaded extends ProjectsState {
  final ProjectDetailsModel project;
  final List<ProjectModel> projects;
  final bool canAddNew;

  ProjectDetailsLoaded({
    required this.project,
    required this.projects,
    required this.canAddNew,
  });
}

class ProjectDetailsFailure extends ProjectsState {
  final String message;
  final List<ProjectModel> projects;
  final bool canAddNew;

  ProjectDetailsFailure(this.message,
      {
      required this.projects,
      required this.canAddNew});
}

class ProjectEditLoading extends ProjectsState {}

class ProjectEditSuccess extends ProjectsState {
  final String message;

  ProjectEditSuccess(this.message);
}

class ProjectEditFailure extends ProjectsState {
  final String message;

  ProjectEditFailure(this.message);
}
class ProjectCloseLoading extends ProjectsState {}

class ProjectCloseSuccess extends ProjectsState {
  final String message;
  ProjectCloseSuccess(this.message);
}

class ProjectCloseFailure extends ProjectsState {
  final String message;
  ProjectCloseFailure(this.message);
}
class ProjectReportLoading extends ProjectsState {}

class ProjectReportSuccess extends ProjectsState {
  final String message;
  ProjectReportSuccess(this.message);
}

class ProjectReportFailure extends ProjectsState {
  final String message;
  ProjectReportFailure(this.message);
}
class ProjectAddLoading extends ProjectsState {}
class ProjectAddSuccess extends ProjectsState {
  final String message;
  ProjectAddSuccess(this.message);
}
class ProjectAddFailure extends ProjectsState {
  final String message;
  ProjectAddFailure(this.message);
}
abstract class ProjectsListState extends ProjectsState {
  final List<ProjectModel> projects;
  final bool canAddNew;
   ProjectsListState(this.projects, this.canAddNew);
}

class ProjectsLoaded extends ProjectsListState {
   ProjectsLoaded(List<ProjectModel> projects, bool canAddNew)
      : super(projects, canAddNew);
}

class ProjectActionInProgress extends ProjectsListState {
   ProjectActionInProgress(List<ProjectModel> projects, bool canAddNew)
      : super(projects, canAddNew);
}
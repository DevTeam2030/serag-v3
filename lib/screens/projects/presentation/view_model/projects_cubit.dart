import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mine/screens/projects/presentation/view_model/projects_repo.dart';
import '../../data/projects_model.dart';
import 'projects_state.dart';

class ProjectsCubit extends Cubit<ProjectsState> {
  final ProjectsRepository repository;
  bool needsCleaning = false;

  ProjectsCubit({required this.repository}) : super(ProjectsInitial());
  List<ProjectModel> _projects = [];
  bool _canAddNew = true;
  Future<void> load() async {
    emit(ProjectsLoading());
    try {
      final list = await repository.getProjects();
      final hasOpen = list.any((p) => p.status == ProjectStatus.open);

      _projects = list;
      _canAddNew = !hasOpen;

      emit(ProjectsLoaded(_projects, _canAddNew));
    }
    on SocketException {
      emit(ProjectsFailure("no_internet"));
    } on TimeoutException {
      emit(ProjectsFailure("timeout"));
    }

    catch (e) {
      emit(ProjectsFailure(e.toString()));
    }

  }

  List<ProjectModel> get projects => _projects;
  bool get canAddNew => _canAddNew;


  // Future<ProjectDetailsModel> fetchProjectDetails(String id) async {
  //   emit(ProjectLoadingDetails());
  //   try {
  //     final project = await repository.getProjectDetails(id);
  //     final currentState = state;
  //     final projects = currentState is ProjectsLoaded
  //         ? currentState.projects
  //         : currentState is ProjectActionInProgress
  //         ? currentState.projects
  //         : currentState is ProjectDetailsLoaded
  //         ? currentState.projects
  //         : <ProjectModel>[];
  //     final canAddNew = currentState is ProjectsLoaded
  //         ? currentState.canAddNew
  //         : currentState is ProjectActionInProgress
  //         ? currentState.canAddNew
  //         : currentState is ProjectDetailsLoaded
  //         ? currentState.canAddNew
  //         : true;
  //     emit(ProjectDetailsLoaded(
  //         project: project, projects: projects, canAddNew: canAddNew));
  //     return project;
  //   } catch (e) {
  //     emit(ProjectDetailsFailure(e.toString()));
  //     rethrow;
  //   }
  // }
  Future<ProjectDetailsModel> fetchProjectDetails(String id) async {
    emit(ProjectLoadingDetails(projects: _projects, canAddNew: _canAddNew));
    try {
      final project = await repository.getProjectDetails(id);
      emit(ProjectDetailsLoaded(
        project: project,
        projects: _projects,
        canAddNew: _canAddNew,
      ));
      return project;
    } catch (e) {
      emit(ProjectDetailsFailure(e.toString(),
          projects: _projects, canAddNew: _canAddNew));
      rethrow;
    }
  }

  Future<void> editProject(Map<String, dynamic> data) async {
    emit(ProjectEditLoading());
    try {
      await repository.editProject(data);
      emit(ProjectEditSuccess("تم تعديل الفوج بنجاح ✅"));
      await load();
    } catch (e) {
      emit(ProjectEditFailure("فشل تعديل الفوج ❌: ${e.toString()}"));
    }
  }

  Future<void> closeProject({
    required String id,
    required String sellingPrice,
    required String currency,
  }) async {

    emit(
      ProjectCloseLoading(),
    );

    try {

      await repository.closeProject(
        id: id,

        sellingPrice:
        sellingPrice,

        currency: currency,
      );

      needsCleaning = true;

      emit(
        ProjectCloseSuccess(
          "تم غلق الفوج بنجاح ✅",
        ),
      );

      await load();

    } catch (e) {

      emit(
        ProjectCloseFailure(
          "فشل غلق الفوج ❌ : ${e.toString()}",
        ),
      );
    }
  }

  Future<void> reportOutbreak(String id, String message) async {
    emit(ProjectReportLoading());
    try {
      await repository.reportOutbreak(id, message);
      emit(ProjectReportSuccess("تم ارسال التبليغ بنجاح ✅"));
    } catch (e) {
      emit(ProjectReportFailure("فشل ارسال التبليغ ❌: ${e.toString()}"));
    }
  }
  Future<void> addProject(Map<String, dynamic> data) async {
    emit(ProjectAddLoading());
    try {
      await repository.createProject(data);
      emit(ProjectAddSuccess("تم إضافة الفوج بنجاح ✅"));
      await load(); // إعادة تحميل المشاريع بعد الإضافة
    } catch (e) {
      emit(ProjectAddFailure("فشل إضافة الفوج ❌: ${e.toString()}"));
    }
  }

}
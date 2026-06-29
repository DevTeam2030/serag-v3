// edit_project_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/projects_model.dart';
import 'edit_project_repo.dart';
import 'edit_project_state.dart';

class EditProjectCubit extends Cubit<EditProjectState> {
  final EditProjectRepository repository;
  EditProjectCubit(this.repository) : super(EditProjectInitial());

  void loadProject(ProjectModel project) {
    emit(EditProjectLoaded(project));
  }

  Future<void> saveChanges(ProjectModel updatedProject) async {
    emit(EditProjectSaving());
    try {
      await repository.updateProject(updatedProject);
      emit(EditProjectSuccess());
    } catch (e) {
      emit(EditProjectFailure(e.toString()));
    }
  }

  Future<void> closeProject(ProjectModel project) async {
    emit(EditProjectSaving());
    try {
      await repository.closeProject(project.id);
      emit(EditProjectSuccess());
    } catch (e) {
      emit(EditProjectFailure(e.toString()));
    }
  }
}

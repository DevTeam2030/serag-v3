// edit_project_repository.dart

import '../../data/edit_project_service.dart';
import '../../data/projects_model.dart';

class EditProjectRepository {
  final EditProjectService service;
  EditProjectRepository({required this.service});

  Future<void> updateProject(ProjectModel project) => service.updateProject(project);
  Future<void> closeProject(String id) => service.closeProject(id);
}

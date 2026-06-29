import '../../data/project_service.dart';
import '../../data/projects_model.dart';

class ProjectsRepository {
  final ProjectsService service;

  ProjectsRepository({
    required this.service,
  });

  Future<List<ProjectModel>> getProjects() =>
      service.fetchProjects();

  Future<ProjectDetailsModel> getProjectDetails(
      String id,
      ) =>
      service.fetchProjectDetails(id);

  Future<void> editProject(
      Map<String, dynamic> data,
      ) =>
      service.editProject(data);

  Future<void> createProject(
      Map<String, dynamic> data,
      ) =>
      service.addProject(data);

  Future<void> closeProject({
    required String id,
    required String sellingPrice,
    required String currency,
  }) =>
      service.closeProject(
        id,
        sellingPrice,
        currency,
      );

  Future<void> reportOutbreak(
      String id,
      String message,
      ) =>
      service.reportOutbreak(
        id,
        message,
      );
}
// edit_project_service.dart
import 'package:mine/screens/projects/data/projects_model.dart';


class EditProjectService {
  Future<void> updateProject(ProjectModel project) async {
    await Future.delayed(Duration(milliseconds: 500)); // mock API
  }

  Future<void> closeProject(String id) async {
    await Future.delayed(Duration(milliseconds: 300));
  }
}

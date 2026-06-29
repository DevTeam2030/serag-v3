// edit_project_state.dart
import 'package:equatable/equatable.dart';
import '../../data/projects_model.dart';

abstract class EditProjectState extends Equatable {
  @override
  List<Object?> get props => [];
}

class EditProjectInitial extends EditProjectState {}

class EditProjectLoading extends EditProjectState {}

class EditProjectLoaded extends EditProjectState {
  final ProjectModel project;
  EditProjectLoaded(this.project);

  @override
  List<Object?> get props => [project];
}

class EditProjectSaving extends EditProjectState {}

class EditProjectSuccess extends EditProjectState {}

class EditProjectFailure extends EditProjectState {
  final String message;
  EditProjectFailure(this.message);

  @override
  List<Object?> get props => [message];
}

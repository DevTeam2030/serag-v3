import '../../data/establishment_model.dart';

abstract class EstablishmentState {}

class EstablishmentInitial extends EstablishmentState {}

class EstablishmentLoading extends EstablishmentState {}

class EstablishmentLoaded extends EstablishmentState {
  final List<EstablishmentModel> establishments;

  EstablishmentLoaded(this.establishments);
}

class EstablishmentError extends EstablishmentState {
  final String message;

  EstablishmentError(this.message);
}

// States for assigning
class EstablishmentAssigning extends EstablishmentState {}

class EstablishmentAssignSuccess extends EstablishmentState {
  final String message;

  EstablishmentAssignSuccess(this.message);
}

class EstablishmentAssignError extends EstablishmentState {
  final String message;

  EstablishmentAssignError(this.message);
}
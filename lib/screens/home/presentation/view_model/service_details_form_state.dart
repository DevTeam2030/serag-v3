abstract class ServiceDetailsFormState {}

class ServiceDetailsFormInitial extends ServiceDetailsFormState {}

class ServiceDetailsFormLoading extends ServiceDetailsFormState {}

class ServiceDetailsFormLoaded extends ServiceDetailsFormState {}

class ServiceDetailsFormSubmitting extends ServiceDetailsFormState {}

class ServiceDetailsFormSuccess extends ServiceDetailsFormState {}

class ServiceDetailsFormFailure extends ServiceDetailsFormState {
  final String message;
  ServiceDetailsFormFailure(this.message);
}

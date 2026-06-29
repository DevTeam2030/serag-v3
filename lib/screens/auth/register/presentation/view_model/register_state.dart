import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;

abstract class RegisterState {}

class RegisterInitial extends RegisterState {}

class RegisterLoading extends RegisterState {}

class RegisterValidation extends RegisterState {
  final String message;
  RegisterValidation(this.message);
}

class RegisterValidationError extends RegisterState {
  final String message;
  RegisterValidationError(this.message);
}

class RegisterFieldUpdated extends RegisterState {} // ✅ NEW for dropdown updates

class RegisterSuccess extends RegisterState {
  final String message;
  RegisterSuccess(this.message);
}

class RegisterError extends RegisterState {
  final String message;
  RegisterError(this.message);
}

class SignupLocationUpdated extends RegisterState {
  final LatLng location;
  SignupLocationUpdated(this.location);
}

class CheckUserExistLoading extends RegisterState {}

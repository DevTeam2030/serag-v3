part of 'update_profile_cubit.dart';

abstract class UpdateProfileState extends Equatable {
  @override
  List<Object?> get props => [];
}

class UpdateProfileInitial extends UpdateProfileState {}

class UpdateProfileLoading extends UpdateProfileState {}

class UpdateProfileSuccess extends UpdateProfileState {
  final String message;
  UpdateProfileSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class UpdateProfileError extends UpdateProfileState {
  final String error;
  UpdateProfileError(this.error);

  @override
  List<Object?> get props => [error];
}

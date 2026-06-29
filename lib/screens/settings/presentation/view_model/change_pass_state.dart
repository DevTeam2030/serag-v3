
import 'package:equatable/equatable.dart';

abstract class ChangePassState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ChangePassInitial extends ChangePassState {}

class ChangePassLoading extends ChangePassState {}

class ChangePassSuccess extends ChangePassState {
  final String message;
  ChangePassSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ChangePassError extends ChangePassState {
  final String error;
  ChangePassError(this.error);

  @override
  List<Object?> get props => [error];
}

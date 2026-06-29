
import 'package:equatable/equatable.dart';

abstract class DeleteAccountState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DeleteAccountInitial extends DeleteAccountState {}

class DeleteAccountLoading extends DeleteAccountState {}

class DeleteAccountSuccess extends DeleteAccountState {
  final String message;
  DeleteAccountSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class DeleteAccountError extends DeleteAccountState {
  final String error;
  DeleteAccountError(this.error);

  @override
  List<Object?> get props => [error];
}
class logoutLoading extends DeleteAccountState {}

class logoutSuccess extends DeleteAccountState {
  final String message;
  logoutSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class logoutError extends DeleteAccountState {
  final String error;
  logoutError(this.error);

  @override
  List<Object?> get props => [error];
}
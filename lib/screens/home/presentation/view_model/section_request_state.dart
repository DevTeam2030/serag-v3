// view_model/section_request_state.dart

abstract class SectionRequestState {}

class SectionRequestInitial extends SectionRequestState {}

class SectionRequestLoading extends SectionRequestState {}

class SectionRequestSuccess extends SectionRequestState {
  final String message;
  SectionRequestSuccess(this.message);
}

class SectionRequestError extends SectionRequestState {
  final String error;
  SectionRequestError(this.error);
}
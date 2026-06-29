import '../../data/ads_model.dart';

abstract class AdDetailsState {}

class AdDetailsInitial extends AdDetailsState {}

class AdDetailsLoading extends AdDetailsState {}

class AdDetailsLoaded extends AdDetailsState {
  final AdModel ad;

  AdDetailsLoaded(this.ad);
}

class AdDetailsFailure extends AdDetailsState {
  final String message;

  AdDetailsFailure(this.message);
}
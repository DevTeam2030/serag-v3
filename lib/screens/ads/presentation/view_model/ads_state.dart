import '../../data/ads_model.dart';

abstract class AdsState {}

class AdsInitial
    extends AdsState{}

class AdsLoading
    extends AdsState{}

class AdsLoaded
    extends AdsState{

  final List<AdModel> ads;

  AdsLoaded(
      this.ads
      );

}

class AdsDetailsLoaded
    extends AdsState{

  final AdModel ad;

  AdsDetailsLoaded(
      this.ad
      );

}

class AdsFailure
    extends AdsState{

  final String message;

  AdsFailure(
      this.message
      );

}
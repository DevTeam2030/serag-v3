import '../../data/home_ads_model.dart';

abstract class HomeAdsState {}

class HomeAdsInitial extends HomeAdsState {}

class HomeAdsLoading extends HomeAdsState {}

class HomeAdsLoaded extends HomeAdsState {

  final List<HomeAdModel> ads;

  HomeAdsLoaded(this.ads);

}

class HomeAdsFailure extends HomeAdsState {

  final String message;

  HomeAdsFailure(this.message);

}
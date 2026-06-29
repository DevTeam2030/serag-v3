import '../../data/prices_model.dart';

abstract class PricesState {}

class PricesInitial extends PricesState {}

class PricesLoading extends PricesState {}

class PricesLoaded extends PricesState {
  final Map<String, PriceCategoryModel> prices;

  PricesLoaded(this.prices);
}

class PricesFailure extends PricesState {
  final String message;

  PricesFailure(this.message);
}
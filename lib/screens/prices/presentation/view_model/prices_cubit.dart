import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'prices_repository.dart';
import 'prices_state.dart';

class PricesCubit extends Cubit<PricesState>{

  final PricesRepository repository;

  PricesCubit({
    required this.repository,
  }) : super(PricesInitial());

  Future<void> loadPrices() async {
    emit(PricesLoading());

    try {
      final prices = await repository.getPrices();

      emit(PricesLoaded(prices));
    } catch (e) {
      emit(PricesFailure(e.toString()));
    }
  }
}
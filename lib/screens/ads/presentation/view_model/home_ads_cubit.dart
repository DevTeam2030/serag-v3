import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'home_ads_repository.dart';
import 'home_ads_state.dart';

class HomeAdsCubit extends Cubit<HomeAdsState> {

  final HomeAdsRepository repository;

  HomeAdsCubit({
    required this.repository,
  }) : super(HomeAdsInitial());

  Future<void> loadAds() async {

    emit(HomeAdsLoading());

    try {

      final ads = await repository.getAds();

      emit(
        HomeAdsLoaded(
          ads,
        ),
      );

    }

    on SocketException {

      emit(
        HomeAdsFailure(
          'لا يوجد اتصال بالانترنت',
        ),
      );

    }

    on TimeoutException {

      emit(
        HomeAdsFailure(
          'انتهت مهلة الاتصال',
        ),
      );

    }

    catch (e) {

      emit(
        HomeAdsFailure(
          e.toString(),
        ),
      );

    }
  }
}
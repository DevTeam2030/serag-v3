import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'ad_details_state.dart';
import 'ads_repository.dart';

class AdDetailsCubit extends Cubit<AdDetailsState> {
  final AdsRepository repository;

  AdDetailsCubit({
    required this.repository,
  }) : super(AdDetailsInitial());

  Future<void> loadDetails(int id) async {
    emit(AdDetailsLoading());

    try {
      final ad = await repository.getAdDetails(
        id,
      );

      emit(
        AdDetailsLoaded(
          ad,
        ),
      );
    }

    on SocketException {
      emit(
        AdDetailsFailure(
          'لا يوجد اتصال بالإنترنت',
        ),
      );
    }

    on TimeoutException {
      emit(
        AdDetailsFailure(
          'انتهت مهلة الاتصال',
        ),
      );
    }

    catch (e) {
      emit(
        AdDetailsFailure(
          e.toString(),
        ),
      );
    }
  }
}
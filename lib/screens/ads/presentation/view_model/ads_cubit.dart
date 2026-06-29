import 'package:bloc/bloc.dart';

import 'ads_repository.dart';
import 'ads_state.dart';

class AdsCubit
    extends Cubit<AdsState>{

  final AdsRepository repository;

  AdsCubit({

    required this.repository,

  })

      :super(
      AdsInitial()
  );

  Future<void>
  loadAds() async{

    emit(
      AdsLoading(),
    );

    try{

      final ads=

      await repository
          .getAds();

      emit(

          AdsLoaded(
            ads,
          )

      );

    }

    catch(e){

      emit(

          AdsFailure(
            e.toString(),
          )

      );

    }

  }

  Future<void>
  loadDetails(
      int id
      ) async{

    emit(
      AdsLoading(),
    );

    try{

      final ad=

      await repository
          .getAdDetails(
        id,
      );

      emit(

          AdsDetailsLoaded(
            ad,
          )

      );

    }

    catch(e){

      emit(

          AdsFailure(
            e.toString(),
          )

      );

    }

  }

}
import '../core/helper/cache_helper.dart';

class AppConstants{
  final establishmentTypeId = CacheHelper.getData('establishment_type_id')?.toString() ?? '1';
  bool get isPoultryFarm => establishmentTypeId == '1';

  final userType = CacheHelper.getData('user_type')?.toString() ?? 'normal';
  bool get isNormalUser => userType == 'normal';
}
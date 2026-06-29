import 'package:dio/dio.dart';
import '../../../../constants/api_constants.dart';
import '../../../../core/helper/cache_helper.dart';
import '../../data/establishment_model.dart';

class EstablishmentService {


  Future<EstablishmentResponse> getEstablishments() async {
    try {
      final response = await Dio().get(
        '${ApiConstants.baseUrl}/get-establishments',
        options: Options(
          headers: {
            "Authorization": "Bearer ${CacheHelper.getToken()}",
            "Accept": "application/json",
          },
        ),
      );

      if (response.statusCode == 200) {
        return EstablishmentResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load establishments');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error loading establishments: $e');
    }
  }

  // Future<AssignEstablishmentResponse> assignEstablishment(int id) async {
  //   try {
  //     final response = await Dio().post(
  //       '${ApiConstants.baseUrl}/assgin-establishment',
  //       data: {'id': id},
  //       options: Options(
  //         headers: {
  //           "Authorization": "Bearer ${CacheHelper.getToken()}",
  //           "Accept": "application/json",
  //         },
  //       ),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       print(response.data);
  //       return AssignEstablishmentResponse.fromJson(response.data);
  //     } else {
  //       throw Exception('Failed to assign establishment');
  //     }
  //   } on DioException catch (e) {
  //     throw Exception('Network error: ${e.message}');
  //   } catch (e) {
  //     throw Exception('Error assigning establishment: $e');
  //   }
  // }

  Future<AssignEstablishmentResponse> assignEstablishment(int id) async {
    try {
      final response = await Dio().post(
        '${ApiConstants.baseUrl}/assgin-establishment',
        data: {'id': id},
        options: Options(
          headers: {
            "Authorization": "Bearer ${CacheHelper.getToken()}",
            "Accept": "application/json",
          },
        ),
      );

      if (response.statusCode == 200) {
        final assignResponse = AssignEstablishmentResponse.fromJson(response.data);

        // If accessToken is null, replace it with the existing token
        if (assignResponse.data != null && assignResponse.data!.accessToken == null) {
          final existingToken = CacheHelper.getToken();
          final updatedData = assignResponse.data!.copyWithToken(existingToken!);
          print("UPDATED DATA IS $updatedData");
          print("UPDATED DATA IS $existingToken");
          return AssignEstablishmentResponse(
            status: assignResponse.status,
            message: assignResponse.message,
            data: updatedData,
          );

        }
        print("ASSIGN RESPONSE IS ${assignResponse}");

        return assignResponse;
      } else {
        print("FAILED TO ASSIGN ESTABLISHMENT");
        throw Exception('Failed to assign establishment');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Network error: ${e.response?.data['message'] ?? e.message}');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print("E IS $e");
      throw Exception('Error assigning establishment: $e');
    }
  }
}
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:mine/core/helper/cache_helper.dart';
import 'package:mine/screens/projects/data/projects_model.dart';
import 'package:mine/widgets/custom_toast.dart';
import 'package:toastification/toastification.dart';

import '../../../constants/api_constants.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';

abstract class ProjectsService {
  Future<List<ProjectModel>> fetchProjects();

  Future<ProjectDetailsModel> fetchProjectDetails(
    String id,
  );

  Future<void> addProject(
    Map<String, dynamic> data,
  );

  Future<void> editProject(
    Map<String, dynamic> data,
  );

  Future<void> closeProject(
    String id,
    String sellingPrice,
    String currency,
  );

  Future<void> reportOutbreak(
    String id,
    String reason,
  );
}

class ProjectsServiceApi implements ProjectsService {
  final String baseUrl = "${ApiConstants.baseUrl}";

  @override
  Future<List<ProjectModel>> fetchProjects() async {
    final token = CacheHelper.getToken();
    final url = Uri.parse("$baseUrl/get-user-projects?lang=ar");
    final response = await http.get(url, headers: {
      "Authorization": "Bearer $token",
      "Accept": "application/json",
    });

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Response status code: ${response.statusCode}");
      print("Response body: ${response.body}");
      final body = jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch projects: ${response.statusCode}');
    }

    final body = jsonDecode(response.body);
    return (body['data'] as List).map((e) => ProjectModel.fromJson(e)).toList();
  }

  @override
  Future<ProjectDetailsModel> fetchProjectDetails(String id) async {
    final token = CacheHelper.getToken();
    final url = Uri.parse("$baseUrl/get-project?id=$id&lang=ar");
    final response = await http.get(url, headers: {
      "Authorization": "Bearer $token",
      "Accept": "application/json",
    });
    print("Url project Details is is $url");
    print(
        "response project Details is is ${response.body} with request ${response.headers} ");
    print("token is ${CacheHelper.getToken()}");
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return ProjectDetailsModel.fromJson(body['data']);
    } else {
      throw Exception(
          'Failed to fetch project details: ${response.statusCode}');
    }
  }

  @override
  Future<void> editProject(Map<String, dynamic> data) async {
    final token = CacheHelper.getToken();
    final url = Uri.parse("$baseUrl/edit-project");
    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode(data),
    );
    print("Response status code: ${response.statusCode}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Project edited successfully");
      return;
    } else {
      print("Failed to edit project: ${response.statusCode}");
      throw Exception(
          'Failed to edit project:${jsonDecode(response.body)['message']}');
    }
  }

  @override
  Future<void> addProject(Map<String, dynamic> data) async {
    final token = CacheHelper.getToken();
    final url = Uri.parse("$baseUrl/add-project");

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final res = jsonDecode(response.body);
      print('RESPONSE OF ADDING PROJECT IS : $res');
      if (res["status"] != 200 && res["status"] != 201) {
        throw Exception("فشل إضافة الفوج ❌: ${res["message"]}");
      }
      return;
    } else {
      toastification.show(
        title: Text(
          "${jsonDecode(response.body)["message"]} فشل إضافة الفوج ❌",
          style: AppTextStyles.boldWhite12,
        ),
        backgroundColor: AppColors.red,
        autoCloseDuration: const Duration(seconds: 2),
      );
      throw Exception("فشل إضافة الفوج ❌: ${response.statusCode}");
    }
  }

  @override
  Future<void> closeProject(
      String id,
      String sellingPrice,
      String currency,
      ) async {

    final token = CacheHelper.getToken();

    final url = Uri.parse(
      "$baseUrl/close-project",
    );

    final response = await http.post(
      url,

      headers: {
        "Authorization": "Bearer $token",

        "Accept": "application/json",

        "Content-Type":
        "application/json",
      },

      body: jsonEncode({
        "id": int.parse(id),

        "selling_price":
        double.parse(sellingPrice),

        "currency": currency,
      }),
    );

    final body =
    jsonDecode(response.body);

    if (response.statusCode == 200 ||
        response.statusCode == 201) {

      if (body["status"] != 200 &&
          body["status"] != 201) {

        throw Exception(
          body["message"],
        );
      }

      return;
    }

    throw Exception(
      body["message"] ??
          "حدث خطأ أثناء غلق الفوج",
    );
  }

  @override
  Future<void> reportOutbreak(String id, String message) async {
    final token = CacheHelper.getToken();
    final url = Uri.parse("$baseUrl/reporting-epidemic");
    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "id": int.parse(id),
        "message": message,
      }),
    );
    print('Report Disease Response status code: ${response.statusCode}');
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      CustomToast.show('تم التبليغ بنجاح');
      // toastification.show(
      //   title: Text(
      //     "تم التبليغ بنجاح",
      //     style: AppTextStyles.boldWhite12,
      //   ),
      //   icon: Icon(
      //     CupertinoIcons.checkmark_circle_fill,
      //     color: AppColors.white,
      //   ),
      //   backgroundColor:
      //   AppColors.green,
      //   autoCloseDuration: const Duration(seconds: 2),
      // );
      print('Report Disease Response body: $body');

      if (body["status"] != 200) {
        CustomToast.show('فشل في التبليغ: ${body["message"]}');

        throw Exception("Failed to report outbreak: ${body["message"]}");
      }
    } else {
      throw Exception("Failed to report outbreak: ${response.statusCode}");
    }
  }
}

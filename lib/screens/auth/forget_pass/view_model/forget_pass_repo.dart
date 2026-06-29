import 'forget_pass_service.dart';

class ForgetPasswordRepository {
  final ForgetPasswordService _service;

  ForgetPasswordRepository({ForgetPasswordService? service})
      : _service = service ?? ForgetPasswordService();

  Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    try {
      final result = await _service.requestPasswordReset(email);
      final statusCode = result['statusCode'];
      final body = result['body'];

      if (statusCode == 200 || statusCode == 201) {
        return {
          'success': true,
          'message': body['message'] ?? 'تم إرسال رابط إعادة تعيين كلمة المرور',
        };
      } else if (statusCode == 422) {
        throw body['message'] ?? 'خطأ في التحقق من البريد الإلكتروني';
      } else if (statusCode == 404) {
        throw 'البريد الإلكتروني غير موجود';
      } else if (statusCode == 500) {
        throw 'خطأ في الخادم، يرجى المحاولة لاحقًا';
      } else {
        throw body['message'] ?? 'فشل طلب إعادة تعيين كلمة المرور';
      }
    } catch (e) {
      throw e.toString();
    }
  }
}
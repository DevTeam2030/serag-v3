import 'auth_services.dart';

class AuthRepository {
  final AuthService service;

  AuthRepository(this.service);

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) {
    return service.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
  }


  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String tenantName,
    required String phone,
    required String email,
  }) {
    return service.updateProfile(
      name: name,
      tenantName: tenantName,
      phone: phone,
      email: email,
    );
  }

  Future<Map<String, dynamic>> deleteAccount() {
    return service.deleteAccount();
  }
  Future<Map<String, dynamic>> logout() {
    return service.logout();
  }


}

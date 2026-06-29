import 'package:fluttertoast/fluttertoast.dart';

class CustomToast {
  static void show(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
    print("Toast: $message");
  }
}
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mine/widgets/back_button.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
class InternetLossWidget extends StatelessWidget {
  final VoidCallback onRetry;

  const InternetLossWidget({Key? key, required this.onRetry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,

          children: [
            SizedBox(height: 40.h),
          Navigator.canPop(context)?  Align(
                alignment: Alignment.topLeft,
                child: BkBtn()):SizedBox(height: 0.h,),
            SizedBox(height: 100.h),
            Icon(
              Icons.wifi_off,
              size: 100.h,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'لا يوجد اتصال بالإنترنت',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // ElevatedButton(
            //   onPressed: onRetry,
            //   style: ElevatedButton.styleFrom(
            //     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(8),
            //     ),
            //   ),
            //   child: const Text(
            //     'Retry',
            //     style: TextStyle(fontSize: 16),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}



class InternetConnectionWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback? onReconnect;
  final Duration checkInterval;
  final Duration requestTimeout;

  const InternetConnectionWrapper({
    Key? key,
    required this.child,
    this.onReconnect,
    this.checkInterval = const Duration(seconds: 5),
    this.requestTimeout = const Duration(seconds: 8),
  }) : super(key: key);

  @override
  State<InternetConnectionWrapper> createState() =>
      _InternetConnectionWrapperState();
}

class _InternetConnectionWrapperState extends State<InternetConnectionWrapper> {
  bool _hasInternet = true;
  bool _isChecking = false;
  Timer? _timer;
  int _consecutiveFailures = 0;

  @override
  void initState() {
    super.initState();
    _checkInternetConnection();
    _startPeriodicCheck();
  }

  void _startPeriodicCheck() {
    _timer?.cancel();
    _timer = Timer.periodic(widget.checkInterval, (_) {
      if (!_isChecking) {
        _checkInternetConnection();
      }
    });
  }

  Future<void> _checkInternetConnection() async {
    if (_isChecking) return;

    _isChecking = true;

    try {

      final response = await http
          .get(
        Uri.parse('https://www.google.com'),
        headers: {'Cache-Control': 'no-cache'},
      )
          .timeout(widget.requestTimeout);

      // Check if we got a successful response
      final connected = response.statusCode >= 200 && response.statusCode < 300;

      if (connected) {
        _consecutiveFailures = 0;
      } else {
        _consecutiveFailures++;
      }

      // Only update state if connection status changed
      if (mounted && _hasInternet != connected) {
        setState(() => _hasInternet = connected);

        if (connected && widget.onReconnect != null) {
          widget.onReconnect!();
        }
      }
    } on TimeoutException catch (_) {
      // Timeout means weak/no connection
      _consecutiveFailures++;
      _handleConnectionFailure();
    } on http.ClientException catch (_) {
      // Network error (no connection, DNS failure, etc.)
      _consecutiveFailures++;
      _handleConnectionFailure();
    } catch (e) {
      // Any other error
      _consecutiveFailures++;
      _handleConnectionFailure();
    } finally {
      _isChecking = false;
    }
  }

  void _handleConnectionFailure() {
    if (mounted && _hasInternet != false) {
      setState(() => _hasInternet = false);
    }

    // Implement exponential backoff for repeated failures
    if (_consecutiveFailures > 3) {
      _timer?.cancel();
      final backoffDuration = Duration(
        seconds: (widget.checkInterval.inSeconds *
            (1 << (_consecutiveFailures - 3).clamp(0, 4))).clamp(5, 60),
      );
      _timer = Timer.periodic(backoffDuration, (_) {
        if (!_isChecking) {
          _checkInternetConnection();
        }
      });
    }
  }

  Future<void> _manualRetry() async {
    // Reset consecutive failures on manual retry
    _consecutiveFailures = 0;
    _startPeriodicCheck(); // Reset to normal check interval
    await _checkInternetConnection();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _hasInternet
        ? widget.child
        : InternetLossWidget(onRetry: _manualRetry);
  }
}

// Optional: Create a global wrapper for error handling
class HttpInterceptor {
  static Future<http.Response> get(
      Uri url, {
        Map<String, String>? headers,
        Duration timeout = const Duration(seconds: 10),
      }) async {
    try {
      return await http.get(url, headers: headers).timeout(timeout);
    } on TimeoutException {
      throw NetworkException('Connection timeout - weak or no internet');
    } on http.ClientException {
      throw NetworkException('Network error - check your connection');
    } catch (e) {
      throw NetworkException('Failed to connect: ${e.toString()}');
    }
  }
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);

  @override
  String toString() => message;
}



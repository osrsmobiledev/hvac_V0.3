import 'package:flutter/services.dart';

abstract final class VekaPortal {
  static const mock = bool.fromEnvironment('VEKA_MOCK_PORTAL');
  static const _channel = MethodChannel('com.example.hvac_app/veka_portal');

  static Future<void> open() async {
    if (!mock) await _channel.invokeMethod<void>('open');
  }
}

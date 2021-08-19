
import 'dart:async';

import 'package:flutter/services.dart';

class View {
  static const MethodChannel _channel = MethodChannel('view');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'icod_printer_platform_interface.dart';

/// An implementation of [IcodPrinterPlatform] that uses method channels.
class MethodChannelIcodPrinter extends IcodPrinterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('icod_printer');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}

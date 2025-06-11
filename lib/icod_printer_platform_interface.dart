import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'icod_printer_method_channel.dart';

abstract class IcodPrinterPlatform extends PlatformInterface {
  /// Constructs a IcodPrinterPlatform.
  IcodPrinterPlatform() : super(token: _token);

  static final Object _token = Object();

  static IcodPrinterPlatform _instance = MethodChannelIcodPrinter();

  /// The default instance of [IcodPrinterPlatform] to use.
  ///
  /// Defaults to [MethodChannelIcodPrinter].
  static IcodPrinterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [IcodPrinterPlatform] when
  /// they register themselves.
  static set instance(IcodPrinterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}

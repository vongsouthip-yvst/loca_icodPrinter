import 'package:flutter_test/flutter_test.dart';
import 'package:icod_printer/icod_printer.dart';
import 'package:icod_printer/icod_printer_platform_interface.dart';
import 'package:icod_printer/icod_printer_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockIcodPrinterPlatform
    with MockPlatformInterfaceMixin
    implements IcodPrinterPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final IcodPrinterPlatform initialPlatform = IcodPrinterPlatform.instance;

  test('$MethodChannelIcodPrinter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelIcodPrinter>());
  });

  test('getPlatformVersion', () async {
    IcodPrinter icodPrinterPlugin = IcodPrinter();
    MockIcodPrinterPlatform fakePlatform = MockIcodPrinterPlatform();
    IcodPrinterPlatform.instance = fakePlatform;

    expect(await icodPrinterPlugin.getPlatformVersion(), '42');
  });
}

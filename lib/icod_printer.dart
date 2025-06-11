import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart';

// Enums and classes
enum ConnectionType { usb, bluetooth, serial, wifi, usbNative }

enum AlignMode { left, center, right }

enum BarcodeType {
  upca,
  upce,
  jan13,
  jan8,
  code39,
  itf,
  codabar,
  code93,
  code128,
}

class IcodPrinter {
  static const MethodChannel _channel = MethodChannel('icod_printer');

  /// Connects to the printer via USB or other configured method.
  static Future<bool> connect() async {
    try {
      final bool result = await _channel.invokeMethod('connect');
      return result;
    } catch (e) {
      print("Error in connect(): $e");
      return false;
    }
  }

  /// Disconnects from the printer.
  static Future<bool> disconnect() async {
    try {
      final bool result = await _channel.invokeMethod('disconnect');
      return result;
    } catch (e) {
      print("Error in disconnect(): $e");
      return false;
    }
  }

  /// Sends a string to be printed by the printer.
  static Future<void> printString(String text) async {
    try {
      await _channel.invokeMethod('printString', {'text': text});
    } catch (e) {
      
      print("Error in printString(): $e");
    }
  }

  Future<String?> getPlatformVersion() async {
    return null;
  }
  // All your Flutter methods here...
}

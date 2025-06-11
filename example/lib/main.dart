import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Icod Printer Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const PrinterHomePage(),
    );
  }
}

class PrinterHomePage extends StatefulWidget {
  const PrinterHomePage({super.key});
  @override
  State<PrinterHomePage> createState() => _PrinterHomePageState();
}

class _PrinterHomePageState extends State<PrinterHomePage> {
  static const platform = MethodChannel('icod_printer');
  bool isConnected = false;
  final textController = TextEditingController();

  Future<void> _connectPrinter() async {
    try {
      final result = await platform.invokeMethod('connect');
      if (result == true) {
        setState(() => isConnected = true);
        _showMessage('Printer connected');
      } else {
        _showMessage('Failed to connect');
      }
    } on PlatformException catch (e) {
      _showMessage('Connect error: ${e.message}');
    }
  }

  Future<void> _disconnectPrinter() async {
    try {
      final result = await platform.invokeMethod('disconnect');
      if (result == true) {
        setState(() => isConnected = false);
        _showMessage('Printer disconnected');
      }
    } on PlatformException catch (e) {
      _showMessage('Disconnect error: ${e.message}');
    }
  }

  Future<void> _checkPrinterStatus() async {
    try {
      final int statusCode = await platform.invokeMethod('getPrinterStatus');
      String statusMessage;

      switch (statusCode) {
        case 0:
          statusMessage = '✅ Printer is ready.';
          break;
        case 3:
          statusMessage = '⚠️ Paper is about to run out.';
          break;
        case 12:
          statusMessage = '❌ Out of paper.';
          break;
        default:
          statusMessage = '❓ Unknown printer status: $statusCode';
      }

      _showMessage(statusMessage);
    } on PlatformException catch (e) {
      _showMessage('Status error: ${e.message}');
    }
  }

  Future<void> _printText() async {
    final text = textController.text.trim();
    if (text.isEmpty) {
      _showMessage('Enter text to print');
      return;
    }

    try {
      final result = await platform.invokeMethod('printString', {'text': text});
      if (result == true) {
        _showMessage('Text printed');
      }
    } on PlatformException catch (e) {
      _showMessage('Print error: ${e.message}');
    }
  }

  Future<void> _cutWithSize({int m = 66, int n = 0}) async {
  try {
    final result = await platform.invokeMethod('cutPaper', {
      'm': m,
      'n': n,
    });
    if (result == true) {
      _showMessage('✂️ Paper cut (m=$m, n=$n)');
    }
  } on PlatformException catch (e) {
    _showMessage('Cut error: ${e.message}');
  }
}


  Future<void> _printAndCut() async {
    final text = textController.text.trim();
    if (text.isEmpty) {
      _showMessage('Enter text to print');
      return;
    }

    try {
      final result = await platform.invokeMethod('printAndCut', {'text': text});
      if (result == true) {
        _showMessage('✅ Text printed and paper cut');
      }
    } on PlatformException catch (e) {
      _showMessage('Print & cut error: ${e.message}');
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Icod Printer')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: textController,
              decoration: const InputDecoration(labelText: 'Text to print'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: isConnected ? null : _connectPrinter,
              icon: const Icon(Icons.usb),
              label: const Text('Connect Printer'),
            ),
            ElevatedButton.icon(
              onPressed: isConnected ? _printText : null,
              icon: const Icon(Icons.print),
              label: const Text('Print Text'),
            ),
            ElevatedButton.icon(
              onPressed: isConnected ? _disconnectPrinter : null,
              icon: const Icon(Icons.close),
              label: const Text('Disconnect Printer'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
            ElevatedButton.icon(
              onPressed: _checkPrinterStatus,
              icon: const Icon(Icons.info_outline),
              label: const Text('Check Printer Status'),
            ),
            ElevatedButton.icon(
              onPressed: isConnected ?  ()=> _cutWithSize(m: 66, n: 0) : null,
              icon: const Icon(Icons.cut),
              label: const Text('Print & Cut'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Connected: $isConnected'),
          ],
        ),
      ),
    );
  }
}

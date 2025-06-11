package com.example.icod_printer

import android.content.Context
import android.util.Log
import com.szsicod.print.escpos.PrinterAPI
import com.szsicod.print.io.USBAPI
import com.szsicod.print.io.InterfaceAPI
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class IcodPrinterPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var printer: PrinterAPI? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "icod_printer")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "connect" -> handleConnect(result)
            "disconnect" -> handleDisconnect(result)
            "printString" -> handlePrintString(call, result)
            "printAndCut" -> handlePrintAndCut(call, result)
            "cutPaper" -> handleCutPaper(call, result)
            "getPrinterStatus" -> handleGetPrinterStatus(result)
            else -> result.notImplemented()
        }
    }

    private fun handleConnect(result: Result) {
        try {
            val io: InterfaceAPI = USBAPI(context)
            val printerInstance = PrinterAPI()
            val connected = printerInstance.connect(io)

            if (connected == 0) { // 0 = success, per SDK
                printerInstance.init()
                printer = printerInstance
                result.success(true)
            } else {
                result.error("CONNECT_FAILED", "Failed to connect. Error code: $connected", null)
            }
        } catch (e: Exception) {
            Log.e("IcodPrinterPlugin", "Connection error", e)
            result.error("CONNECT_ERROR", e.message, e.stackTraceToString())
        }
    }

    private fun handleDisconnect(result: Result) {
        try {
            printer?.disconnect()
            printer = null
            result.success(true)
        } catch (e: Exception) {
            Log.e("IcodPrinterPlugin", "Disconnect error", e)
            result.error("DISCONNECT_ERROR", e.message, e.stackTraceToString())
        }
    }

    private fun handleGetPrinterStatus(result: Result) {
    try {
        if (printer == null) {
            result.error("NO_PRINTER", "Printer not connected", null)
            return
        }

        // Status codes: 0 (OK), 3 (almost out), 12 (out of paper)
       val statusCode = printer!!.getPrinterStatus()
        result.success(statusCode)
    } catch (e: Exception) {
        Log.e("IcodPrinterPlugin", "Printer status error", e)
        result.error("PRINTER_STATUS_ERROR", e.message, e.stackTraceToString())
    }
}

    private fun handlePrintString(call: MethodCall, result: Result) {
    val text = call.argument<String>("text") ?: ""
    try {
        if (printer != null && text.isNotEmpty()) {
            printer!!.printString(text, "GBK", true) // Charset + auto feed
            result.success(true)
        } else {
            result.error("PRINT_ERROR", "Printer not connected or text is empty", null)
        }
    } catch (e: Exception) {
        Log.e("IcodPrinterPlugin", "Print error", e)
        result.error("PRINT_ERROR", e.message, e.stackTraceToString())
    }
}

private fun handlePrintAndCut(call: MethodCall, result: Result) {
    val text = call.argument<String>("text") ?: ""
    try {
        if (printer != null && text.isNotEmpty()) {
            printer!!.printString(text, "GBK", true)  // Print with charset and line feed
            printer!!.printFeed()                     // Advance paper (optional)
            printer!!.fullCut()                       // Cut paper
            result.success(true)
        } else {
            result.error("PRINT_CUT_ERROR", "Printer not connected or text is empty", null)
        }
    } catch (e: Exception) {
        Log.e("IcodPrinterPlugin", "Print and cut error", e)
        result.error("PRINT_CUT_ERROR", e.message, e.stackTraceToString())
    }
}

private fun handleCutPaper(call: MethodCall, result: Result) {
    try {
        val m = call.argument<Int>("m") ?: 66
        val n = call.argument<Int>("n") ?: 0

        if (printer != null) {
            printer!!.cutPaper(m, n)
            result.success(true)
        } else {
            result.error("NO_PRINTER", "Printer not connected", null)
        }
    } catch (e: Exception) {
        Log.e("IcodPrinterPlugin", "Cut paper error", e)
        result.error("CUT_PAPER_ERROR", e.message, e.stackTraceToString())
    }
}




    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}

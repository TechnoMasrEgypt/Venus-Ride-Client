import 'dart:developer' as developer;

abstract class PrintHalper {
  // blue //
  static void printInfo(String msg) {
    developer.log('\x1B[34m$msg\x1B[0m');
  }

// green //
  static void printSuccess(String msg) {
    developer.log('\x1B[32m$msg\x1B[0m');
  }

// yellow //
  static void printWarning(String msg) {
    developer.log('\x1B[33m$msg\x1B[0m');
  }

// red //
  static void printError(String msg) {
    developer.log('\x1B[31m$msg\x1B[0m');
  }
}

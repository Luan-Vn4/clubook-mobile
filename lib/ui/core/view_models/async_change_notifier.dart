import 'package:flutter/cupertino.dart';

abstract class AsyncChangeNotifier<T> extends ChangeNotifier {

  T? get payload;

  bool isLoading = false;

  bool get isCompleted => !isLoading;

  ({Object object, StackTrace stackTrace})? error;

  bool get hasError => error != null;

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  /// No-op once disposed. Guards every async notifier against Flutter's
  /// debug-mode `_debugAssertNotDisposed` assertion, which fires when a
  /// long-running operation (e.g. a network call) completes after the owning
  /// page is popped — the classic "notifyListeners after dispose" crash.
  @override
  void notifyListeners() {
    if (_isDisposed) return;
    super.notifyListeners();
  }

}
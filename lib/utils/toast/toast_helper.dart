import 'package:flutter/material.dart';

/// Utility for displaying user-friendly toast notifications via [SnackBar].
///
/// Wraps [ScaffoldMessenger.showSnackBar] to provide consistent styling for
/// error, success, and informational messages across the app.
class ToastHelper {
  ToastHelper._();

  /// Displays an error-styled toast using the theme's error color.
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  /// Displays a success-styled toast using the theme's primary color.
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  /// Displays an informational toast using the default [SnackBar] styling.
  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

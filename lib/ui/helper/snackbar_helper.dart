import 'package:flutter/material.dart';

class SnackbarHelper {
  // ── Context-based helpers ────────────────────────────────────────────────

  static void showSuccess(BuildContext context, String message) {
    _showViaContext(context, message,
        backgroundColor: Colors.green.shade700,
        icon: Icons.check_circle_outline);
  }

  static void showError(BuildContext context, String message) {
    _showViaContext(context, message,
        backgroundColor: Colors.red.shade700, icon: Icons.error_outline);
  }

  static void showInfo(BuildContext context, String message) {
    _showViaContext(context, message,
        backgroundColor: Colors.blueGrey.shade700,
        icon: Icons.info_outline);
  }

  // ── ScaffoldMessengerState helpers (safe across async gaps) ──────────────

  static void showSuccessMessenger(
      ScaffoldMessengerState messenger, String message) {
    _showViaMessenger(messenger, message,
        backgroundColor: Colors.green.shade700,
        icon: Icons.check_circle_outline);
  }

  static void showErrorMessenger(
      ScaffoldMessengerState messenger, String message) {
    _showViaMessenger(messenger, message,
        backgroundColor: Colors.red.shade700, icon: Icons.error_outline);
  }

  // ── Private ───────────────────────────────────────────────────────────────

  static void _showViaContext(
    BuildContext context,
    String message, {
    required Color backgroundColor,
    required IconData icon,
  }) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(_buildSnackBar(message, backgroundColor, icon));
  }

  static void _showViaMessenger(
    ScaffoldMessengerState messenger,
    String message, {
    required Color backgroundColor,
    required IconData icon,
  }) {
    messenger
      ..clearSnackBars()
      ..showSnackBar(_buildSnackBar(message, backgroundColor, icon));
  }

  static SnackBar _buildSnackBar(
      String message, Color backgroundColor, IconData icon) {
    return SnackBar(
      content: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      duration: const Duration(seconds: 3),
    );
  }
}

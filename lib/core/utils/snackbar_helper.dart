import 'package:flutter/material.dart';

void mySnackBar({
  required BuildContext context,
  required String message,
  Color? color,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      backgroundColor: color ?? const Color(0xFF5A9C41),
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

void showErrorSnackBar(BuildContext context, String message) {
  mySnackBar(context: context, message: message, color: Colors.red);
}

void showSuccessSnackBar(BuildContext context, String message) {
  mySnackBar(context: context, message: message, color: Colors.green);
}

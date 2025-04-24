import 'package:flutter/material.dart';
class CustomSnackBar extends SnackBar {
  final Color backgroundColor;

  const CustomSnackBar({
    super.key,
    required super.content,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SnackBar(
      content: content,
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.all(10),
      duration: const Duration(seconds: 3),
      action: SnackBarAction(
        label: 'OK',
        textColor: Colors.white,
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    );
  }
}

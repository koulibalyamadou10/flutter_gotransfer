import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DigitalPaymentsPage extends StatelessWidget {
  final Color _primaryColor = const Color(0xFF6200EE);
  final Color _textColor = const Color(0xFF121212);
  final Color _secondaryTextColor = const Color(0xFF757575);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              FontAwesomeIcons.mobileScreenButton,
              size: 60,
              color: _primaryColor,
            ),
            SizedBox(height: 20),
            Text(
              'Digital Payments',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _textColor,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Make secure payments anytime.',
              style: TextStyle(
                fontSize: 16,
                color: _secondaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

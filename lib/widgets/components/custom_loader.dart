import 'package:flutter/material.dart';

class CustomLoader extends StatelessWidget {
  final Color loaderColor;
  final double size;
  final double strokeWidth;
  final String? text;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;

  const CustomLoader({
    Key? key,
    this.loaderColor = Colors.blue,
    this.size = 40.0,
    this.strokeWidth = 4.0,
    this.text,
    this.textStyle,
    this.padding = const EdgeInsets.all(8.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding!,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: loaderColor,
              strokeWidth: strokeWidth,
              valueColor: AlwaysStoppedAnimation<Color>(loaderColor),
              semanticsLabel: 'Loading...',
            ),
            if (text != null) ...[
              SizedBox(height: 12),
              Text(
                text!,
                style: textStyle ??
                    TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: loaderColor,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

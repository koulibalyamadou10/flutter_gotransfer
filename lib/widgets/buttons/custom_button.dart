import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color loadingColor;
  final Color textColor;
  final double borderRadius;
  final EdgeInsets padding;
  final double elevation;
  final bool isFullWidth;
  final bool isLoading;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final double? width;
  final double? height;
  final TextStyle? textStyle;
  final BorderSide borderSide;

  const CustomButton({
    Key? key,
    required this.text,
    this.onTap,
    this.backgroundColor = Colors.blue,
    this.loadingColor = Colors.grey, // 👈 nouvelle couleur pour l'état de chargement
    this.textColor = Colors.white,
    this.borderRadius = 8.0,
    this.padding = const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
    this.elevation = 2.0,
    this.isFullWidth = false,
    this.isLoading = false,
    this.prefixIcon,
    this.suffixIcon,
    this.width,
    this.height,
    this.textStyle,
    this.borderSide = BorderSide.none,
  }) : super(key: key);
  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.isFullWidth ? double.infinity : widget.width,
      height: widget.height,
      child: ElevatedButton(
        onPressed: widget.isLoading || widget.onTap == null ? null : widget.onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.backgroundColor, // 👈 couleur dynamique
          foregroundColor: widget.textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            side: widget.borderSide,
          ),
          elevation: widget.elevation,
          padding: widget.padding,
        ),
        child: widget.isLoading
            ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: const [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 12),
            Text("Chargement..."), // 👈 Texte optionnel pendant le loading
          ],
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.prefixIcon != null) ...[
              widget.prefixIcon!,
              const SizedBox(width: 8),
            ],
            Text(
              widget.text,
              style: widget.textStyle ??
                  TextStyle(
                    color: widget.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            if (widget.suffixIcon != null) ...[
              const SizedBox(width: 8),
              widget.suffixIcon!,
            ],
          ],
        ),
      ),
    );
  }
}

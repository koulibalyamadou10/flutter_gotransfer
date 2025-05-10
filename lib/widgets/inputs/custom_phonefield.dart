import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

class CustomPhoneField extends StatelessWidget {
  final String initialCountryCode;
  final String initialValue;
  final ValueChanged<PhoneNumber> onChanged;
  final FormFieldValidator<PhoneNumber>? validator;
  final TextStyle? style;
  final TextStyle? dropdownTextStyle;
  final InputDecoration? decoration;
  final Icon? dropdownIcon;
  final TextInputType keyboardType;
  final EdgeInsets contentPadding;

  const CustomPhoneField({
    Key? key,
    this.initialCountryCode = 'GN',
    this.initialValue = '',
    required this.onChanged,
    this.validator,
    this.style,
    this.dropdownTextStyle,
    this.decoration,
    this.dropdownIcon,
    this.keyboardType = TextInputType.phone,
    this.contentPadding = const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IntlPhoneField(
      initialCountryCode: initialCountryCode,
      initialValue: initialValue,
      onChanged: onChanged,
      validator: validator,
      keyboardType: keyboardType,
      style: style ?? const TextStyle(fontSize: 16),
      dropdownTextStyle: dropdownTextStyle ?? const TextStyle(fontSize: 16),
      dropdownIcon: dropdownIcon ?? const Icon(Icons.arrow_drop_down),
      decoration: decoration ??
          InputDecoration(
            labelText: 'Phone number',
            hintText: 'Phone number',
            contentPadding: contentPadding,
            border: const OutlineInputBorder(),
          ),
    );
  }
}

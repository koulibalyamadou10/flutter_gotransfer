import '../../config/app_config.dart';

class Helpers {
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  static Map<String, String>? getNumberAndNameUser(String namePhoneNumber) {
    // Expression régulière pour extraire le nom et un numéro au format international
    final regex = RegExp(r'^(.*?)\s((?:\+|00)?\d{6,15})$');
    final match = regex.firstMatch(namePhoneNumber.trim());

    if (match != null) {
      String name = match.group(1)!.trim();
      String number = match.group(2)!.trim();

      print('Nom : $name');
      print('Numéro : $number');
      return {
        'name': name,
        'phone_number': number,
      };
    } else {
      print('Format non reconnu');
      return null;
    }
  }

  static Map<String, String> parsePhoneNumber(String rawNumber) {
    String cleaned = rawNumber.replaceAll(RegExp(r'[^0-9+]'), '');

    // Détection des formats internationaux
    if (cleaned.startsWith('+')) {
      final match = RegExp(r'^(\+\d{1,3})(\d+)$').firstMatch(cleaned);
      if (match != null) {
        return {
          'full': cleaned,
          'countryCode': match.group(1)!,
          'localNumber': match.group(2)!,
        };
      }
    }

    for (var code in AppConfig.worldCodes.keys) {
      if (cleaned.startsWith(code)) {
        return {
          'full': '+$cleaned',
          'countryCode': AppConfig.worldCodes[code]!,
          'localNumber': cleaned.substring(code.length),
        };
      }
    }

    // Fallback pour numéros non reconnus
    return {
      'full': cleaned,
      'countryCode': '+224',
      'localNumber': cleaned,
    };
  }

  static String formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  static String encrypt(String password){
    return password;
  }

  static String decrypt(String password){
    return password;
  }

  static String getCountryCode(String country){
    return AppConfig.countryCodeDialingCodes[country] ?? "";
  }

  static String getCountry(String codeCountry){
    return AppConfig.codeToCountry[codeCountry] ?? "";
  }

  static String getCountryCurrency(String codeCountry){
    return Helpers.getCurrency(AppConfig.codeToCountry[codeCountry] ?? "");
  }

  static String getCurrency(String codeCountry){
    return AppConfig.codeToCurrency[codeCountry] ?? "";
  }
}
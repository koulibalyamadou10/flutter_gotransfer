import 'dart:convert';

class Destinataire {
  final int? id;
  final String first_name;
  final String last_name;
  final String phone_number;
  final String pays;
  final String countryCode;
  final String countryCurrency;

  Destinataire({
    this.id,
    required this.first_name,
    required this.last_name,
    required this.pays,
    required this.phone_number,
    required this.countryCode,
    required this.countryCurrency
  });

  factory Destinataire.fromJson(Map<String, dynamic> json) {
    return Destinataire(
      id: json['id'],
      first_name: json['first_name'],
      last_name: json['last_name'],
      pays: json['pays'],
      phone_number: json['phone_number'],
      countryCode: json['country_code'],
      countryCurrency: json['country_currency']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': first_name,
      'last_name': last_name,
      'pays': pays,
      'email': pays,
      'phone_number': phone_number,
      'country_code': countryCode,
      'country_currency': countryCurrency
    };
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
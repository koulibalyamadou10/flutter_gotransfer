import 'dart:convert';

class Destinataire {
  final int? id;
  final int customer;
  final String first_name;
  final String last_name;
  final String phone_number;
  final String pays;

  Destinataire({
    this.id,
    required this.customer,
    required this.first_name,
    required this.last_name,
    required this.pays,
    required this.phone_number,
  });

  factory Destinataire.fromJson(Map<String, dynamic> json) {
    return Destinataire(
      id: json['id'],
      customer: json['customer'],
      first_name: json['first_name'],
      last_name: json['last_name'],
      pays: json['pays'],
      phone_number: json['phone_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer': customer,
      'first_name': first_name,
      'last_name': last_name,
      'email': pays,
      'phone_number': phone_number,
    };
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
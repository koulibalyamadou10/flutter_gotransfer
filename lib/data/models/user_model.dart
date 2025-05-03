import 'dart:convert';
import 'dart:ffi';

import 'beneficiary_model.dart';

class User {
  final int? id;
  final String first_name;
  final String last_name;
  final String email;
  final String phone_number;
  final String address;
  final String? country;
  final String? image;
  final String password;
  final double? balance;
  String? currency = '';
  final double? commission;
  List<Destinataire> destinataires = [];
  late bool isLoaded = false;

  User({
    this.id,
    required this.first_name,
    required this.last_name,
    required this.email,
    required this.phone_number,
    required this.address,
    this.country,
    this.image,
    this.balance,
    this.currency,
    this.commission,
    required this.password
  });

  factory User.fromJson(Map<String, dynamic> json) {
    User user = User(
      id: json['id'],
      first_name: json['first_name'],
      last_name: json['last_name'],
      email: json['email'],
      phone_number: json['phone_number'],
      country: json['country']?? '',
      address: json['address'] ?? '',
      image: json['image'] ?? '',
      balance: json['balance'] is double ? json['balance'] : double.parse(json['balance']),
      currency: json['currency'] ?? '',
      commission: json['commission'] is double ? json['balance'] : double.parse(json['commission']),
      password: json['password'] ?? '',
    );
    List<dynamic> beneficiariesJson = json['beneficiaries'] ?? [];
    List<Destinataire> destinataires = beneficiariesJson
        .map((beneficiaryJson) => Destinataire.fromJson(beneficiaryJson))
        .toList();
    user.destinataires = destinataires;
    return user;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': first_name,
      'last_name': last_name,
      'email': email,
      'phone_number': phone_number,
      'address': address,
      'image': image,
      'country': country?? '',
      'password': password,
      'currency': currency,
      'balance': balance,
      'commission': commission,
      'beneficiaries': destinataires.map((d) => d.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
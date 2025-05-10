import 'dart:convert';
import 'dart:ffi';

import 'package:gotransfer/data/models/remittance_model.dart';

import 'role_model.dart';

class User {
  final int? id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String address;
  final String? country;
  final String? image;
  final String password;
  final double? balance;
  String? currency = '';
  final double? commission;
  List<Role> roles = [];
  List<Remittance> remittances_today = [];
  List<Remittance> remittances_last = [];
  late bool isLoaded = false;

  User({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
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
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      country: json['country']?? '',
      address: json['address'] ?? '',
      image: json['image'] ?? '',
      balance: json['balance'] is double ? json['balance'] : double.parse(json['balance']),
      currency: json['currency'] ?? '',
      commission: json['commission'] is double ? json['balance'] : double.parse(json['commission']),
      password: json['password'] ?? '',
    );
    List<dynamic> rolesJson = json['roles'] ?? [];
    List<dynamic> remittancesTodayJson = json['remittances_today'] ?? [];
    List<dynamic> remittancesLastJson = json['remittances_last'] ?? [];

    List<Role> roles = rolesJson
        .map((roleJson) => Role.fromJson(roleJson))
        .toList();
    List<Remittance> remittances_today = remittancesTodayJson
        .map((remittanceJson) => Remittance.fromJson(remittanceJson))
        .toList();
    List<Remittance> remittancesLast = remittancesLastJson
        .map((remittanceJson) => Remittance.fromJson(remittanceJson))
        .toList();
    user.roles = roles;
    user.remittances_today = remittances_today;
    user.remittances_last = remittancesLast;
    return user;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone_number': phoneNumber,
      'address': address,
      'image': image,
      'country': country?? '',
      'password': password,
      'currency': currency,
      'balance': balance,
      'commission': commission,
      'beneficiaries': roles.map((d) => d.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
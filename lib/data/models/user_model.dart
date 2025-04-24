import 'dart:convert';
import 'dart:ffi';

class User {
  final int? id;
  final String first_name;
  final String last_name;
  final String email;
  final String phone_number;
  final String address;
  final String? image;
  final String password;
  final double? balance;
  final double? commission;
  late bool isLoaded = false;

  User({
    this.id,
    required this.first_name,
    required this.last_name,
    required this.email,
    required this.phone_number,
    required this.address,
    this.image,
    this.balance,
    this.commission,
    required this.password
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      first_name: json['first_name'],
      last_name: json['last_name'],
      email: json['email'],
      phone_number: json['phone_number'],
      address: json['address'] ?? '',
      image: json['image'] ?? '',
      balance: double.parse(json['balance']),
      commission: double.parse(json['commission']),
      password: json['password'] ?? '',
    );
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
      'password': password,
      'balance': balance,
      'commission': commission,
    };
  }

  static void setUserInSharedPreferences(){

  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
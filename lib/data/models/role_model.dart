class Role {
  final int id;
  final int senderId;
  final String firstName;
  final String lastName;
  final String country;
  final String countryCode;
  final String countryCurrency;
  final String telephone;
  final String? email;
  final bool active;
  final String? idCard;
  final String? idExpDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Role({
    required this.id,
    required this.senderId,
    required this.firstName,
    required this.lastName,
    required this.country,
    required this.countryCode,
    required this.countryCurrency,
    required this.telephone,
    required this.email,
    required this.active,
    required this.idCard,
    required this.idExpDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'],
      senderId: json['sender'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      country: json['country'],
      countryCode: json['country_code'],
      countryCurrency: json['country_currency'],
      telephone: json['telephone'],
      email: json['email'] ?? '',
      active: json['active'] == 1,
      idCard: json['id_card'] ?? '',
      idExpDate: json['id_exp_date'] ?? '',
      createdAt: json['created_at'] == null ? null : DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] == null ? null : DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'first_name': firstName,
      'last_name': lastName,
      'country': country,
      'country_code': countryCode,
      'telephone': telephone,
      'email': email ?? '',
      'active': active ? 1 : 0,
      'id_card': idCard ?? '',
      'id_exp_date': idExpDate ?? '',
      'created_at': createdAt == null ? null : createdAt!.toIso8601String(),
      'updated_at': updatedAt == null ? null : updatedAt!.toIso8601String(),
    };
  }
}
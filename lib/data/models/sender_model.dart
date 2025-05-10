class Sender {
  final int? userId; // id de l'utilisateur lié (CustomUser)
  final String firstName;
  final String lastName;
  final String address;
  final String telephone;
  final String email;
  final String idCard;
  final DateTime idExpDate;
  final String senderUuid;
  final DateTime createdAt;
  final DateTime updatedAt;

  Sender({
    this.userId,
    required this.firstName,
    required this.lastName,
    required this.address,
    required this.telephone,
    required this.email,
    required this.idCard,
    required this.idExpDate,
    required this.senderUuid,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Sender.fromJson(Map<String, dynamic> json) {
    return Sender(
      userId: json['user'] as int?,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      address: json['address'] ?? '',
      telephone: json['telephone'] ?? '',
      email: json['email'] ?? '',
      idCard: json['id_card'] ?? '',
      idExpDate: DateTime.parse(json['id_exp_date']),
      senderUuid: json['sender_uuid'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': userId,
      'first_name': firstName,
      'last_name': lastName,
      'address': address,
      'telephone': telephone,
      'email': email,
      'id_card': idCard,
      'id_exp_date': idExpDate.toIso8601String(),
      'sender_uuid': senderUuid,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

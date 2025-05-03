class Topup {
  String transactionId;
  int user;
  int role;
  String recipientNumber;
  String operator;
  String product;
  double price;
  double sellingPrice;
  String currency;
  String sellingCurrency;
  double profit;
  double agentProfit;
  String status;
  String senderFirstName;
  String senderLastName;
  String senderTelephone;
  String? agentUsername;
  String topupUuid;
  DateTime createdAt;
  DateTime updatedAt;

  Topup({
    required this.transactionId,
    required this.user,
    required this.role,
    required this.recipientNumber,
    required this.operator,
    required this.product,
    required this.price,
    required this.sellingPrice,
    required this.currency,
    required this.sellingCurrency,
    required this.profit,
    required this.agentProfit,
    required this.status,
    required this.senderFirstName,
    required this.senderLastName,
    required this.senderTelephone,
    this.agentUsername,
    required this.topupUuid,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Topup.fromJson(Map<String, dynamic> json) {
    return Topup(
      transactionId: json['transaction_id'],
      user: json['user'],
      role: json['role'],
      recipientNumber: json['recipient_number'],
      operator: json['operator'],
      product: json['product'],
      price: (json['price'] as num).toDouble(),
      sellingPrice: (json['selling_price'] as num).toDouble(),
      currency: json['currency'],
      sellingCurrency: json['selling_currency'],
      profit: (json['profit'] as num).toDouble(),
      agentProfit: (json['agent_profit'] as num).toDouble(),
      status: json['status'],
      senderFirstName: json['sender_first_name'],
      senderLastName: json['sender_last_name'],
      senderTelephone: json['sender_telephone'],
      agentUsername: json['agent_username'],
      topupUuid: json['topup_uuid'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_id': transactionId,
      'user': user,
      'role': role,
      'recipient_number': recipientNumber,
      'operator': operator,
      'product': product,
      'price': price,
      'selling_price': sellingPrice,
      'currency': currency,
      'selling_currency': sellingCurrency,
      'profit': profit,
      'agent_profit': agentProfit,
      'status': status,
      'sender_first_name': senderFirstName,
      'sender_last_name': senderLastName,
      'sender_telephone': senderTelephone,
      'agent_username': agentUsername,
      'topup_uuid': topupUuid,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

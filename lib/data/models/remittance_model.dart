class Remittance {
  final String transactionId;
  final int sender; // ID du sender (CustomUser)
  final int role; // ID du role (Beneficiary)
  final String cashoutLocation;
  final String payoutOption;
  final double amountSent;
  final String senderCurrency;
  final double exchangeRate;
  final double recipientAmount;
  final double agentProfit;
  final double fees;
  final double total;
  final String status;

  Remittance({
    required this.transactionId,
    required this.sender,
    required this.role,
    required this.cashoutLocation,
    required this.payoutOption,
    required this.amountSent,
    required this.senderCurrency,
    required this.exchangeRate,
    required this.recipientAmount,
    required this.agentProfit,
    required this.fees,
    required this.total,
    required this.status,
  });

  factory Remittance.fromJson(Map<String, dynamic> json) {
    return Remittance(
      transactionId: json['transaction_id'],
      sender: json['sender'],
      role: json['role'],
      cashoutLocation: json['cashout_location'],
      payoutOption: json['payout_option'],
      amountSent: double.parse(json['amount_sent']),
      senderCurrency: json['sender_currency'],
      exchangeRate: double.parse(json['exchange_rate']),
      recipientAmount: double.parse(json['recipient_amount'],),
      agentProfit: double.parse(json['agent_profit']),
      fees: double.parse(json['fees']),
      total: double.parse(json['total']),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_id': transactionId,
      'sender': sender,
      'role': role,
      'cashout_location': cashoutLocation,
      'payout_option': payoutOption,
      'amount_sent': amountSent,
      'sender_currency': senderCurrency,
      'exchange_rate': exchangeRate,
      'recipient_amount': recipientAmount,
      'agent_profit': agentProfit,
      'fees': fees,
      'total': total,
      'status': status,
    };
  }
}

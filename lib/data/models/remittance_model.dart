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
      amountSent: (json['amount_sent'] as num).toDouble(),
      senderCurrency: json['sender_currency'],
      exchangeRate: (json['exchange_rate'] as num).toDouble(),
      recipientAmount: (json['recipient_amount'] as num).toDouble(),
      agentProfit: (json['agent_profit'] as num).toDouble(),
      fees: (json['fees'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
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

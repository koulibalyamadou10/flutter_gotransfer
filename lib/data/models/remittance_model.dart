import 'dart:convert';

class Remittance {
  final String transactionId;
  final int? senderId;
  final int roleId;
  final String? roleInfo;
  final String cashoutLocation;
  final String payoutOption;
  final double amountSent;
  final String senderCurrency;
  final double exchangeRate;
  final double recipientAmount;
  final String recipientCurrency;
  final double agentProfit;
  final double? fees;
  final double? total;
  final String status;
  final DateTime? transactionCompletionDate;
  final String? agentStartUsername;
  final String? agentCompletionUsername;
  final String? comments;
  final String? partnerCode;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? remittanceUuid;

  Remittance({
    required this.transactionId,
    this.senderId,
    required this.roleId,
    this.roleInfo,
    required this.cashoutLocation,
    required this.payoutOption,
    required this.amountSent,
    required this.senderCurrency,
    required this.exchangeRate,
    required this.recipientAmount,
    required this.recipientCurrency,
    this.agentProfit = 0.0,
    this.fees,
    this.total,
    required this.status,
    this.transactionCompletionDate,
    this.agentStartUsername,
    this.agentCompletionUsername,
    this.comments,
    this.partnerCode,
    this.createdAt,
    this.updatedAt,
    this.remittanceUuid,
  });

  factory Remittance.fromJson(Map<String, dynamic> json) {
    return Remittance(
      transactionId: json['transaction_id'],
      senderId: json['sender'],
      roleId: json['role'] ?? 0,
      roleInfo: json['role_info'],
      cashoutLocation: json['cashout_location'],
      payoutOption: json['payout_option'],
      amountSent: double.parse(json['amount_sent'].toString()),
      senderCurrency: json['sender_currency'],
      exchangeRate: double.parse(json['exchange_rate'].toString()),
      recipientAmount: double.parse(json['recipient_amount'].toString()),
      recipientCurrency: json['recipient_currency'],
      agentProfit: json['agent_profit'] != null
          ? double.parse(json['agent_profit'].toString())
          : 0.0,
      fees: json['fees'] != null
          ? double.parse(json['fees'].toString())
          : null,
      total: json['total'] != null
          ? double.parse(json['total'].toString())
          : null,
      status: json['status'],
      transactionCompletionDate: json['transaction_completion_date'] != null
          ? DateTime.parse(json['transaction_completion_date'])
          : null,
      agentStartUsername: json['agent_start_username'],
      agentCompletionUsername: json['agent_completion_username'],
      comments: json['comments'],
      partnerCode: json['partner_code'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      remittanceUuid: json['remittance_uuid'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_id': transactionId,
      'sender': senderId,
      'role': roleId,
      'cashout_location': cashoutLocation,
      'payout_option': payoutOption,
      'amount_sent': amountSent,
      'sender_currency': senderCurrency,
      'exchange_rate': exchangeRate,
      'recipient_amount': recipientAmount,
      'recipient_currency': recipientCurrency,
      'agent_profit': agentProfit,
      'fees': fees,
      'total': total,
      'status': status,
      'transaction_completion_date': transactionCompletionDate?.toIso8601String(),
      'agent_start_username': agentStartUsername,
      'agent_completion_username': agentCompletionUsername,
      'comments': comments,
      'partner_code': partnerCode,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'remittance_uuid': remittanceUuid,
    };
  }

  String toJsonString() => json.encode(toJson());

  factory Remittance.fromJsonString(String source) =>
      Remittance.fromJson(json.decode(source));
}
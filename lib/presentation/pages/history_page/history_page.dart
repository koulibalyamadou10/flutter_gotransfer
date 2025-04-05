import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final List<Transaction> _transactions = [
    Transaction(
      id: '1',
      amount: 150000,
      type: 'Transfert',
      recipient: 'Mamadou Diallo',
      date: DateTime.now().subtract(const Duration(minutes: 10)),
      status: 'Terminé',
      isIncoming: false,
    ),
    Transaction(
      id: '2',
      amount: 75000,
      type: 'Recharge',
      recipient: 'Orange Money',
      date: DateTime.now().subtract(const Duration(hours: 2)),
      status: 'Terminé',
      isIncoming: false,
    ),
    Transaction(
      id: '3',
      amount: 250000,
      type: 'Dépôt',
      recipient: 'Compte Principal',
      date: DateTime.now().subtract(const Duration(days: 1)),
      status: 'Terminé',
      isIncoming: true,
    ),
    Transaction(
      id: '4',
      amount: 50000,
      type: 'Paiement',
      recipient: 'Supermarket ABC',
      date: DateTime.now().subtract(const Duration(days: 3)),
      status: 'Terminé',
      isIncoming: false,
    ),
    Transaction(
      id: '5',
      amount: 120000,
      type: 'Transfert',
      recipient: 'Fatoumata Binta',
      date: DateTime.now().subtract(const Duration(days: 5)),
      status: 'Échoué',
      isIncoming: false,
    ),
  ];

  String _selectedFilter = 'Tous';

  @override
  Widget build(BuildContext context) {
    final filteredTransactions = _selectedFilter == 'Tous'
        ? _transactions
        : _transactions.where((t) => t.type == _selectedFilter).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Rechercher une transaction...',
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      // Implémenter la recherche
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredTransactions.length,
              itemBuilder: (context, index) {
                final transaction = filteredTransactions[index];
                return _buildTransactionCard(transaction);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    final amountColor = transaction.isIncoming ? Colors.green : Colors.red;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getTypeColor(transaction.type).withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              _getTypeIcon(transaction.type),
              color: _getTypeColor(transaction.type),
            ),
          ),
        ),
        title: Text(
          transaction.type,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(transaction.recipient),
            const SizedBox(height: 4),
            Text(
              dateFormat.format(transaction.date),
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${transaction.amount} GNF',
              style: TextStyle(
                color: amountColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(transaction.status),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                transaction.status,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
        onTap: () {
          _showTransactionDetails(transaction);
        },
      ),
    );
  }

  void _showTransactionDetails(Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Détails de la transaction'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Type', transaction.type),
            _buildDetailRow('Bénéficiaire', transaction.recipient),
            _buildDetailRow('Montant', '${transaction.amount} GNF'),
            _buildDetailRow('Date', DateFormat('dd/MM/yyyy HH:mm').format(transaction.date)),
            _buildDetailRow('Statut', transaction.status),
            _buildDetailRow('Référence', transaction.id),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
          if (transaction.status == 'Échoué')
            TextButton(
              onPressed: () {
                // Relancer la transaction
              },
              child: const Text('Réessayer'),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrer par type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFilterOption('Tous'),
            _buildFilterOption('Transfert'),
            _buildFilterOption('Recharge'),
            _buildFilterOption('Paiement'),
            _buildFilterOption('Dépôt'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String value) {
    return ListTile(
      title: Text(value),
      leading: Radio<String>(
        value: value,
        groupValue: _selectedFilter,
        onChanged: (String? newValue) {
          setState(() {
            _selectedFilter = newValue!;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Transfert':
        return Colors.blue;
      case 'Recharge':
        return Colors.orange;
      case 'Paiement':
        return Colors.purple;
      case 'Dépôt':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'Transfert':
        return Icons.send;
      case 'Recharge':
        return Icons.phone_android;
      case 'Paiement':
        return Icons.payment;
      case 'Dépôt':
        return Icons.account_balance_wallet;
      default:
        return Icons.receipt;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Terminé':
        return Colors.green;
      case 'En cours':
        return Colors.orange;
      case 'Échoué':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class Transaction {
  final String id;
  final int amount;
  final String type;
  final String recipient;
  final DateTime date;
  final String status;
  final bool isIncoming;

  Transaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.recipient,
    required this.date,
    required this.status,
    required this.isIncoming,
  });
}
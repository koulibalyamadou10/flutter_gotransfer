import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RechargePage extends StatefulWidget {
  const RechargePage({super.key});

  @override
  State<RechargePage> createState() => _RechargePageState();
}

class _RechargePageState extends State<RechargePage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedOperator = 'Orange Money';

  final List<String> _operators = [
    'Orange Money',
    'MTN Mobile Money',
    'Wave',
    'Moov Money'
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recharger mon compte'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Opérateur mobile',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedOperator,
                items: _operators.map((String operator) {
                  return DropdownMenuItem<String>(
                    value: operator,
                    child: Text(operator),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedOperator = newValue!;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  prefixIcon: const Icon(Icons.phone_android),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Numéro de téléphone',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.phone),
                  prefixText: '+224 ',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un numéro';
                  }
                  if (value.length != 9) {
                    return 'Numéro invalide';
                  }
                  return null;
                },
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(8),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Montant (GNF)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.money),
                  suffixText: 'GNF',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un montant';
                  }
                  if (int.tryParse(value.trim()) == null) {
                    return 'Montant invalide';
                  }
                  if (int.parse(value) < 5000) {
                    return 'Minimum 5 000 GNF';
                  }
                  return null;
                },
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _showConfirmationDialog();
                    }
                  },
                  child: const Text('Confirmer la recharge'),
                ),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),
              Text(
                'Forfaits populaires',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              Center(
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _buildAmountChip('10 000 GNF'),
                    _buildAmountChip('25 000 GNF'),
                    _buildAmountChip('50 000 GNF'),
                    _buildAmountChip('100 000 GNF'),
                    _buildAmountChip('200 000 GNF'),
                    _buildAmountChip('500 000 GNF'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountChip(String amount) {
    return ActionChip(
      label: Text(amount),
      onPressed: () {
        _amountController.text = amount.replaceAll(' GNF', '');
      },
    );
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la recharge'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Opérateur: $_selectedOperator'),
            const SizedBox(height: 8),
            Text('Numéro: +224 ${_phoneController.text}'),
            const SizedBox(height: 8),
            Text('Montant: ${_amountController.text} GNF'),
            const SizedBox(height: 16),
            const Text('Frais: 500 GNF'),
            const Divider(),
            Text(
              'Total: ${int.parse(_amountController.text) + 500} GNF',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processPayment();
            },
            child: const Text('Payer'),
          ),
        ],
      ),
    );
  }

  void _processPayment() {
    // Ici vous implémenteriez la logique de paiement réel
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Recharge de ${_amountController.text} GNF effectuée avec succès'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }
}
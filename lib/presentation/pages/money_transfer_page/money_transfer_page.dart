import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gotransfer/data/models/beneficiary_model.dart';
import 'package:gotransfer/data/models/user_model.dart';
import 'package:gotransfer/data/repositories/destinataire_repository.dart';
import 'package:gotransfer/data/repositories/user_repository.dart';
import 'package:gotransfer/widgets/buttons/custom_button.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../../widgets/components/country_selector.dart';

class MoneyTransferPage extends StatefulWidget {
  const MoneyTransferPage({super.key});

  @override
  State<MoneyTransferPage> createState() => _MoneyTransferPageState();
}

class _MoneyTransferPageState extends State<MoneyTransferPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountSendController = TextEditingController();
  final _amountReceiveController = TextEditingController();
  final _rateController = TextEditingController(text: "1 CAD = 5,500 GNF");
  final _feesController = TextEditingController(text: "0");
  final _totalController = TextEditingController();
  final _noteController = TextEditingController();
  String _selectedContact = '';
  String _selectedPaymentMethod = 'Mobile Money';
  bool _isSending = false;

  // Taux de change fictifs
  final Map<String, double> _exchangeRates = {
    'GNF': 5500.0,
    'USD': 0.75,
    'EUR': 0.68,
    'XOF': 450.0,
  };

  final TextEditingController _phoneController = TextEditingController();

  // Méthodes de paiement disponibles
  final List<String> _paymentMethods = [
    'Mobile Money',
    'Cash Pickup',
    'Bank Transfer',
    'Wallet',
    'Card Payment'
  ];

  @override
  void initState() {
    super.initState();
    _amountSendController.addListener(_convertSendToReceive);
    _amountReceiveController.addListener(_convertReceiveToSend);
  }

  @override
  void dispose() {
    _amountSendController.dispose();
    _amountReceiveController.dispose();
    _rateController.dispose();
    _feesController.dispose();
    _totalController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _convertSendToReceive() {
    if (_amountSendController.text.isEmpty) {
      _amountReceiveController.clear();
      _updateTotal();
      return;
    }

    final amount = double.tryParse(_amountSendController.text);
    if (amount == null) return;

    String targetCurrency = _getTargetCurrency();
    final rate = _exchangeRates[targetCurrency] ?? 1.0;
    final convertedAmount = amount * rate;

    setState(() {
      _amountReceiveController.text = NumberFormat('#,##0.00').format(convertedAmount);
      _rateController.text = "1 CAD = ${NumberFormat('#,##0.00').format(rate)} $targetCurrency";
      _updateTotal();
    });
  }

  void _convertReceiveToSend() {
    if (_amountReceiveController.text.isEmpty) {
      _amountSendController.clear();
      _updateTotal();
      return;
    }

    final amount = double.tryParse(_amountReceiveController.text.replaceAll(',', ''));
    if (amount == null) return;

    String targetCurrency = _getTargetCurrency();
    final rate = _exchangeRates[targetCurrency] ?? 1.0;
    final convertedAmount = amount / rate;

    setState(() {
      _amountSendController.text = NumberFormat('#,##0.00').format(convertedAmount);
      _rateController.text = "1 CAD = ${NumberFormat('#,##0.00').format(rate)} $targetCurrency";
      _updateTotal();
    });
  }

  String _getTargetCurrency() {
    if (_selectedContact.isNotEmpty) {
      if (_selectedContact.contains('237')) return 'GNF';
      if (_selectedContact.contains('1')) return 'USD';
    }
    return 'GNF'; // Par défaut
  }

  void _updateTotal() {
    final sendAmount = double.tryParse(_amountSendController.text.replaceAll(',', '')) ?? 0;
    final fees = double.tryParse(_feesController.text.replaceAll(',', '')) ?? 0;
    final total = sendAmount + fees;

    setState(() {
      _totalController.text = NumberFormat('#,##0.00').format(total);
    });
  }

  void _submitTransfer() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSending = true;
      });

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isSending = false;
          });
          _showSuccessDialog();
        }
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Transfert Réussi', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSuccessDetail('Destinataire:', _selectedContact.split('(')[0]),
            _buildSuccessDetail('Montant envoyé:', '${_amountSendController.text} CAD'),
            _buildSuccessDetail('Montant reçu:', '${_amountReceiveController.text} ${_getTargetCurrency()}'),
            _buildSuccessDetail('Méthode:', _selectedPaymentMethod),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Le bénéficiaire recevra un SMS avec les instructions',
                style: TextStyle(color: Colors.green[800]),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _formKey.currentState?.reset();
              _amountSendController.clear();
              _amountReceiveController.clear();
              setState(() {
                _selectedContact = '';
                _selectedPaymentMethod = 'Mobile Money';
              });
            },
            child: Text('Fermer', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Nouveau Transfert'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Section Destinataire
              _buildRecipientSection(colorScheme),

          SizedBox(height: 24),
          
          // Button ajout dstinataire
                Container(
                  child: Row(
                    children: [
                      Spacer(),
                      GestureDetector(
                        onTap: (){
                          final _formKey = GlobalKey<FormState>();
                          String? firstName, lastName, phoneNumber, _countryCode ;

                          showDialog(
                              context: context,
                              builder: (context){
                                return AlertDialog(
                                  title: Text("Ajouter un Bénéficiaire"),
                                  content: SingleChildScrollView(
                                    child: Form(
                                      key: _formKey,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextFormField(
                                            decoration: InputDecoration(labelText: "Prénom"),
                                            validator: (value) =>
                                            value == null || value.isEmpty ? "Ce champ est requis" : null,
                                            onSaved: (value) => firstName = value,
                                          ),
                                          SizedBox(height: 12),
                                          TextFormField(
                                            decoration: InputDecoration(labelText: "Nom"),
                                            validator: (value) =>
                                            value == null || value.isEmpty ? "Ce champ est requis" : null,
                                            onSaved: (value) => lastName = value,
                                          ),
                                          SizedBox(height: 12),
                                          IntlPhoneField(
                                            decoration: InputDecoration(
                                              labelText: 'Phone number',
                                              hintText: 'Phone number',
                                              contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                                              border: OutlineInputBorder(),
                                            ),
                                            dropdownIcon: Icon(Icons.arrow_drop_down),
                                            initialCountryCode: 'GN',
                                            onChanged: (phone) {
                                              // Gérer le changement de numéro
                                              print("phone number is : ${phone.completeNumber}");
                                              setState(() {
                                                _phoneController.text = phone.completeNumber;
                                              });
                                            },
                                            keyboardType: TextInputType.phone,
                                            validator: (phone) {
                                              if (phone == null || phone.number.isEmpty) {
                                                return 'Please enter a valid phone number';
                                              }
                                              return null;
                                            },
                                            style: TextStyle(fontSize: 16),
                                            dropdownTextStyle: TextStyle(fontSize: 16),
                                          ),
                                          SizedBox(height: 12),
                                        ],
                                      ),
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      child: Text("Annuler"),
                                      onPressed: () => Navigator.of(context).pop(),
                                    ),
                                    CustomButton(
                                      text: 'Ajouter',
                                      onTap: () async {
                                        if (_formKey.currentState!.validate()) {
                                          _formKey.currentState!.save();

                                          User user = await UserRepository.getUserInSharedPreferences();
                                          print(user);
                                          print(user.id);
                                          DestinataireRepository.create(
                                            Destinataire(
                                              customer: 1,
                                              first_name: firstName ?? '',
                                              last_name: lastName ?? '',
                                              pays: 'Guinea',
                                              phone_number: _phoneController.text
                                            ),
                                            context
                                          );
                                          Navigator.of(context).pop(); // Fermer la boîte de dialogue
                                        }
                                      }
                                    ),
                                  ],
                                );
                              }
                          );

                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.all(Radius.circular(10))
                          ),
                          child: Text("Ajouter un destinaire", style: TextStyle(color: Colors.white),),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 24),

          // Section Montant à envoyer (CAD)
          _buildAmountSection(
            controller: _amountSendController,
            label: 'Montant à envoyer (CAD)',
            currency: 'CAD',
            colorScheme: colorScheme,
          ),

          SizedBox(height: 16),

          // Section Montant à recevoir
          _buildAmountSection(
            controller: _amountReceiveController,
            label: 'Montant à recevoir',
            currency: _getTargetCurrency(),
            colorScheme: colorScheme,
          ),

          SizedBox(height: 16),

          // Section Taux de change
          _buildInfoField(
            controller: _rateController,
            label: 'Taux de change',
            icon: Icons.currency_exchange,
            colorScheme: colorScheme,
          ),

          SizedBox(height: 16),

          // Section Frais
          _buildAmountSection(
            controller: _feesController,
            label: 'Frais de transfert',
            currency: 'CAD',
            colorScheme: colorScheme,
            onChanged: (_) => _updateTotal(),
          ),

          SizedBox(height: 16),

          // Section Total
          _buildInfoField(
            controller: _totalController,
            label: 'Total à débiter',
            icon: Icons.calculate,
            colorScheme: colorScheme,
          ),

          SizedBox(height: 24),

          // Section Méthode de paiement
          Text(
            'Méthode de paiement',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          _buildPaymentMethodDropdown(colorScheme),

          SizedBox(height: 24),

          // Section Note
          Text(
            'Note (optionnelle)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          TextFormField(
            controller: _noteController,
            maxLines: 3,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Ajouter un message pour le bénéficiaire...',
            ),
          ),

          SizedBox(height: 32),

          // Bouton Envoyer
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isSending ? null : _submitTransfer,
                child: _isSending
                    ? SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(color: Colors.white),
                )
                    : Text(
                  'ENVOYER LE TRANSFERT',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              )
            ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecipientSection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Destinataire',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedContact.isEmpty ? null : _selectedContact,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Sélectionner un destinataire',
            prefixIcon: Icon(Icons.person_outline),
          ),
          items: [
            'Alice (237 6XX XXX XXX)',
            'Bob (1 234 567 8901)',
            'Charlie (237 6XX XXX XXX)',
            'David (1 987 654 3210)',
          ].map((contact) {
            return DropdownMenuItem(
              value: contact,
              child: Text(contact),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedContact = value ?? '';
              if (_amountSendController.text.isNotEmpty) {
                _convertSendToReceive();
              } else if (_amountReceiveController.text.isNotEmpty) {
                _convertReceiveToSend();
              }
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez sélectionner un destinataire';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPaymentMethodDropdown(ColorScheme colorScheme) {
    return DropdownButtonFormField<String>(
      value: _selectedPaymentMethod,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.payment),
      ),
      items: _paymentMethods.map((method) {
        return DropdownMenuItem(
          value: method,
          child: Text(method),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedPaymentMethod = value ?? 'Mobile Money';
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez sélectionner une méthode';
        }
        return null;
      },
    );
  }

  Widget _buildAmountSection({
    required TextEditingController controller,
    required String label,
    required String currency,
    required ColorScheme colorScheme,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            TextInputFormatter.withFunction((oldValue, newValue) {
              try {
                final text = newValue.text;
                if (text.isNotEmpty) {
                  double.parse(text);
                }
                return newValue;
              } catch (e) {
                return oldValue;
              }
            }),
          ],
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            prefixIcon: Padding(
              padding: EdgeInsets.only(left: 16),
              child: Text(
                '$currency ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ),
            prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildInfoField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ColorScheme colorScheme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          style: TextStyle(fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            prefixIcon: Icon(icon, color: colorScheme.primary),
            filled: true,
            fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
          ),
        ),
      ],
    );
  }
}
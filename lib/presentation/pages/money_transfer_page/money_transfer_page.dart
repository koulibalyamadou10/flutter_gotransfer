import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gotransfer/config/app_config.dart';
import 'package:gotransfer/data/repositories/exchange_reporitory.dart';
import 'package:gotransfer/presentation/widgets/components/custom_scaffold.dart';
import 'package:intl/intl.dart';
import 'package:confetti/confetti.dart';
import '../../widgets/components/currency_selector.dart';

class MoneyTransferPage extends StatefulWidget {
  const MoneyTransferPage({super.key});

  @override
  State<MoneyTransferPage> createState() => _MoneyTransferPageState();
}

class _MoneyTransferPageState extends State<MoneyTransferPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _amountConvertController = TextEditingController();
  final _noteController = TextEditingController();
  String _selectedCurrencies = 'USD';
  late ConfettiController _confettiController;
  late AnimationController _animationController;
  String _selectedContact = '';
  String _selectedPaymentMethod = 'Mobile Money';
  DateTime _selectedDate = DateTime.now();
  bool _isSending = false;
  bool _isConvert = false;
  bool _showRecipientCard = false;
  double _transferProgress = 0;

  // Ajout d'un TextEditingController pour la recherche
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredContacts = [];

  final List<String> _contacts = [
    'John (237 6XX XXX XXX)',
    'Jane (237 6XX XXX XXX)',
    'Alice (237 6XX XXX XXX)',
    'Bob (237 6XX XXX XXX)',
    'Bob (237 6XX XXX XXX)',
    'Bob (237 6XX XXX XXX)',
    'Bob (237 6XX XXX XXX)',
    'Bob (237 6XX XXX XXX)',
    'Bob (237 6XX XXX XXX)',
    'Bob (237 6XX XXX XXX)',
    'Bob (237 6XX XXX XXX)',
    'Bob (237 6XX XXX XXX)',
    'Bob (237 6XX XXX XXX)',
    'Bob (237 6XX XXX XXX)',
    'Bob (237 6XX XXX XXX)',
    'Bob (237 6XX XXX XXX)',
    'Bob (237 6XX XXX XXX)',
    'Bob (237 6XX XXX XXX)',
    'Bob (237 6XX XXX XXX)',
    'Bob (237 6XX XXX XXX)',
    'Bob (237 6XX XXX XXX)',
    'Bob (237 6XX XXX XXX)',
    'Bob (237 6XX XXX XXX)',
  ];

  final List<String> _paymentMethods = [
    'Mobile Money',
    'Bank Transfer',
    'Credit Card',
    'PayPal'
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _filteredContacts = _contacts;
    _searchController.addListener(_filterContacts);

    _confettiController = ConfettiController(duration: 3.seconds);
    _animationController = AnimationController(
      vsync: this,
      duration: 1.seconds,
    );
  }

  void _filterContacts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredContacts = _contacts.where((contact) {
        return contact.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _confettiController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitTransfer() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSending = true;
        _transferProgress = 0;
      });

      // Animation de progression
      _animationController.reset();
      _animationController.forward();

      // Simulation de progression
      const totalSteps = 20;
      for (int i = 1; i <= totalSteps; i++) {
        Future.delayed((i * 100).milliseconds, () {
          if (mounted) {
            setState(() {
              _transferProgress = i / totalSteps;
            });
          }
        });
      }

      // Simulation d'appel API
      Future.delayed(2.seconds, () {
        if (mounted) {
          setState(() {
            _isSending = false;
          });
          _confettiController.play();
          _showSuccessDialog();
        }
      });
    }
  }

  void _submitConvert() async {
    // Vérifie si le montant est valide
    if (_amountController.text.isEmpty || double.tryParse(_amountController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomScaffold(
          content: Text('Veuillez entrer un montant valide') ,
          backgroundColor: Colors.red
        )
      );
      return;
    }

    setState(() {
      _isConvert = true;
    });

    try {
      final montant = double.parse(_amountController.text);
      final targetCurrency = _selectedCurrencies;

      // Appel à l'API avec la devise de base CAD
      final exchangeData = await ExchangeRepository.fetchExchangeRates('CAD');

      if (exchangeData == null || exchangeData['conversion_rates'] == null) {
        throw Exception('Données de conversion invalides');
      }

      final tauxConversion = exchangeData['conversion_rates'][targetCurrency];
      if (tauxConversion == null) {
        throw Exception('Taux de change non disponible pour $targetCurrency');
      }

      final montantConverti = montant * tauxConversion;

      if (mounted) {
        setState(() {
          _amountConvertController.text = montantConverti.toStringAsFixed(2);
        });

        // Affichage d'un dialogue de succès stylisé
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 2),
                Text('Conversion réussie', style: TextStyle(fontSize: 15)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${_amountController.text} CAD = ${montantConverti.toStringAsFixed(2)} $targetCurrency'),
                SizedBox(height: 10),
                Text('Taux: 1 CAD = ${tauxConversion.toStringAsFixed(6)} $targetCurrency',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK', style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                )),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            action: SnackBarAction(
              label: 'Réessayer',
              textColor: Colors.white,
              onPressed: _submitConvert,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isConvert = false;
        });
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Column(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 10),
            const Text(
              'Transfert Réussi!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSuccessDetailRow(Icons.attach_money, 'Montant:', '${_amountController.text} GNF'),
            _buildSuccessDetailRow(Icons.person, 'Destinataire:', _selectedContact.split('(')[0]),
            _buildSuccessDetailRow(Icons.payment, 'Méthode:', _selectedPaymentMethod),
            _buildSuccessDetailRow(Icons.calendar_today, 'Date:', DateFormat('dd MMM yyyy').format(_selectedDate)),
            const SizedBox(height: 15),
            const Text(
              'Votre transfert a été effectué avec succès!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _amountController.clear();
              _noteController.clear();
              setState(() {
                _selectedContact = '';
              });
            },
            child: const Text('Fermer', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 15, color: Colors.grey),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 4),
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
      backgroundColor: colorScheme.background,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 0),

                  // Titre avec animation
                  // Text(
                  //   'Nouveau Transfert',
                  //   style: TextStyle(
                  //     fontSize: 26,
                  //     fontWeight: FontWeight.bold,
                  //     color: colorScheme.primary,
                  //   ),
                  // ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),

                  const SizedBox(height: 30),

                  // Section Destinataire
                  _buildRecipientSection(colorScheme),

                  if (_showRecipientCard) _buildRecipientCard(colorScheme),

                  const SizedBox(height: 20),

                  // Section Montant
                  _buildAmountSection(colorScheme),

                  const SizedBox(height: 20),

                  // Section Conversion
                  _buildAmountTranslate(),

                  const SizedBox(height: 20),

                  // Bouton Convertir
                  _buildConvertButton(colorScheme),

                  const SizedBox(height: 20),

                  // Méthode de paiement
                  _buildPaymentMethodSection(colorScheme),

                  const SizedBox(height: 20),

                  // Note
                  _buildNoteSection(),

                  const SizedBox(height: 30),

                  // Bouton Envoyer
                  _buildSendButton(colorScheme),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),

          // Confetti pour la réussite
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipientSection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Destinataire',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => setState(() {
            _showRecipientCard = !_showRecipientCard;
            if (!_showRecipientCard) {
              _searchController.clear();
            }
          }),
          child: AnimatedContainer(
            duration: 300.ms,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  _showRecipientCard ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedContact.isEmpty
                        ? 'Sélectionner un contact'
                        : _selectedContact,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      color: _selectedContact.isEmpty
                          ? colorScheme.onSurface.withOpacity(0.6)
                          : colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                CircleAvatar(
                  backgroundColor: colorScheme.primary.withOpacity(0.2),
                  radius: 18,
                  child: Icon(
                    Icons.contacts,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecipientCard(ColorScheme colorScheme) {
    return Column(
      children: [
        // Barre de recherche
        Padding(
          padding: const EdgeInsets.only(bottom: 5, top: 5),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Rechercher un contact...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),

        // Liste des contacts avec scroll
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.4, // 40% de l'écran
          ),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            itemCount: _filteredContacts.length,
            itemBuilder: (context, index) {
              return _buildContactItem(_filteredContacts[index], colorScheme);
            },
          ),
        ),
      ],
    ).animate().fadeIn().slideY(begin: -0.5);
  }

  Widget _buildContactItem(String contact, ColorScheme colorScheme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.primary.withOpacity(0.2),
          child: Text(
            contact.substring(0, 1),
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          contact.split('(')[0].trim(),
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          contact.split('(')[1].replaceAll(')', ''),
          style: TextStyle(
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          setState(() {
            _selectedContact = contact;
            _showRecipientCard = false;
            _searchController.clear();
          });
        },
      ),
    );
  }

  Widget _buildAmountSection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Montant',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: colorScheme.surface,
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 15, right: 10),
              child: Text(
                'CAD',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            hintText: '0',
            hintStyle: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.3),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer un montant';
            }
            if (double.tryParse(value) == null) {
              return 'Veuillez entrer un nombre valide';
            }
            if (double.parse(value) <= 0) {
              return 'Le montant doit être supérieur à 0';
            }
            return null;
          },
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildAmountChip('10,000'),
              _buildAmountChip('50,000'),
              _buildAmountChip('100,000'),
              _buildAmountChip('200,000'),
              _buildAmountChip('500,000'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAmountChip(String amount) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(amount),
        labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        shape: StadiumBorder(
          side: BorderSide(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
        ),
        onPressed: () {
          _amountController.text = amount.replaceAll(',', '');
        },
      ),
    );
  }

  Widget _buildAmountTranslate() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Conversion',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 16),
        CurrencySelector(
          amountController: _amountConvertController,
          availableCurrencies: AppConfig.devises,
          selectedCurrency: _selectedCurrencies,
          onCurrencyChanged: (selectedCurrency) {
            if (selectedCurrency != null) {
              setState(() {
                _selectedCurrencies = selectedCurrency;
              });
              _submitConvert(); // Conversion automatique quand la devise change
            }
          },
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Méthode de paiement',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _paymentMethods.map((method) {
            final isSelected = method == _selectedPaymentMethod;
            return ChoiceChip(
              label: Text(method),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedPaymentMethod = method;
                });
              },
              selectedColor: colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : colorScheme.onSurface,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.outline.withOpacity(0.2),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNoteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Note (Optionnelle)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _noteController,
          maxLines: 3,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            hintText: 'Ajouter un message pour le destinataire...',
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildConvertButton(ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: colorScheme.primary.withOpacity(0.8),
          elevation: 3,
          shadowColor: colorScheme.primary.withOpacity(0.3),
        ),
        onPressed: _isConvert ? null : _submitConvert,
        child: _isConvert
            ? const CircularProgressIndicator(color: Colors.white)
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.autorenew, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              'Convertir',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSendButton(ColorScheme colorScheme) {
    return Column(
      children: [
        if (_isSending) ...[
          LinearProgressIndicator(
            value: _transferProgress,
            backgroundColor: colorScheme.surface,
            color: colorScheme.primary,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 15),
        ],
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              backgroundColor: colorScheme.primary,
              elevation: 5,
              shadowColor: colorScheme.primary.withOpacity(0.4),
            ),
            onPressed: _isSending ? null : _submitTransfer,
            child: _isSending
                ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.white),
                const SizedBox(width: 15),
                Text(
                  'Traitement...',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ],
            )
                : Text(
              'ENVOYER',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
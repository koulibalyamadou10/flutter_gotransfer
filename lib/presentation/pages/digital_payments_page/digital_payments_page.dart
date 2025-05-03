import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gotransfer/core/utils/helpers.dart';
import 'package:gotransfer/data/repositories/topup_repositoy.dart';

import '../../../data/models/user_model.dart';
import '../../../data/repositories/user_repository.dart';

class DigitalPaymentsPage extends StatefulWidget {
  const DigitalPaymentsPage({super.key});

  @override
  State<DigitalPaymentsPage> createState() => _DigitalPaymentsPageState();
}

class _DigitalPaymentsPageState extends State<DigitalPaymentsPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedProduct = '';

  final List<String> _products = [];

  @override
  void initState() {
    super.initState();
    _loadDestinataires();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  bool _isLoadingDestinataires = true;
  String _selectedContact = '';
  final List<String> destinataires = [];

  void _loadDestinataires() async {
    if (mounted) {
      setState(() {
        _isLoadingDestinataires = true;
      });
    }

    try {
      User user = await UserRepository.getUserInSharedPreferences();
      List<String> loadedDestinataires = [];

      for (var destinataire in user.destinataires) {
        loadedDestinataires.add('${destinataire.first_name} ${destinataire.last_name} ${destinataire.phone_number}');
      }

      if (mounted) {
        setState(() {
          destinataires.clear();
          destinataires.addAll(loadedDestinataires);
          _isLoadingDestinataires = false;
        });
      }
    } catch (e) {
      print('Erreur lors du chargement des destinataires: $e');
      if (mounted) {
        setState(() {
          _isLoadingDestinataires = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingDestinataires = false;
        });
      }
    }
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
        _isLoadingDestinataires
            ? Center(child: CircularProgressIndicator())
            : Container(
          constraints: BoxConstraints(
            minWidth: double.infinity, // Prend toute la largeur
          ),
          child: DropdownButtonFormField<String>(
            isExpanded: true, // Important pour éviter le débordement
            value: _selectedContact.isEmpty ? null : _selectedContact,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: destinataires.isEmpty
                  ? 'Aucun destinataire'
                  : 'Sélectionner un destinataire',
              prefixIcon: Icon(Icons.person_outline),
            ),
            items: destinataires.map((contact) {
              return DropdownMenuItem(
                value: contact,
                child: Text(
                  contact,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1, // Limite à une seule ligne
                ),
              );
            }).toList(),
            onChanged: (value) async {
              print('value dropdown $value');
              if (value != null) {
                setState(() {
                  _selectedContact = value;
                });
                String? phone_number = Helpers.getNumberAndNameUser(_selectedContact)?['phone_number'];
                // Mettre ici l'appele pour le chargement des produits
                List<dynamic>? data = await TopupRepository.getAvailableProducts(
                  {
                    'phone_number': phone_number ?? '',
                  },
                  context
                );
                print(data);
                List<String> productLoaded = [];
                for (var d in data!) {
                  productLoaded.add('${d['operator']['name']} ${d['name']} ${d['id']}');
                }
                setState(() {
                  _products.clear();
                  _products.addAll(productLoaded);
                });
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez sélectionner un destinataire';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Récharge télephonique'),
      ),
      body: SafeArea(child: _isLoadingDestinataires ? Center(child: CircularProgressIndicator(color: colorScheme.primary,),) :
      SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Destinataire
              Row(
                children: [
                  Expanded(
                    child: _buildRecipientSection(colorScheme),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Section Produit
              Text(
                'Sélectionner un produit',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedProduct,
                items: _products.map((String product) {
                  return DropdownMenuItem<String>(
                    value: product,
                    child: Text(product),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedProduct = newValue!;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  hintText: destinataires.isEmpty
                      ? 'Aucun destinataire'
                      : 'Sélectionner...',
                  prefixIcon: const Icon(Icons.shopping_cart),
                ),
              ),
              const SizedBox(height: 20),

              // Section Montant
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
                  return null;
                },
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                enabled: false,
              ),
              const SizedBox(height: 30),

              // Bouton de confirmation
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
                  child: const Text('Confirmer le paiement'),
                ),
              ),
            ],
          ),
        ),
      ) ),
    );
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer le paiement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Produit: $_selectedProduct'),
            const SizedBox(height: 8),
            Text('Destinataire: +224 ${_phoneController.text}'),
            const SizedBox(height: 8),
            Text('Montant: ${_amountController.text} GNF'),
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
            child: const Text('Confirmer'),
          ),
        ],
      ),    );
  }

  void _processPayment() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Paiement de ${_amountController.text} GNF effectué avec succès'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

import 'package:drop_down_list/drop_down_list.dart';
import 'package:drop_down_list/model/selected_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'package:flutter_native_contact_picker/model/contact.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gotransfer/core/utils/helpers.dart';
import 'package:gotransfer/data/models/topup_model.dart';
import 'package:gotransfer/data/models/user_model.dart';
import 'package:gotransfer/data/repositories/user_repository.dart';
import 'package:gotransfer/widgets/buttons/custom_button.dart';
import 'package:gotransfer/widgets/components/custom_loader.dart';
import 'package:gotransfer/widgets/components/custom_toast.dart';
import 'package:gotransfer/widgets/inputs/custom_phonefield.dart';
import 'package:gotransfer/widgets/inputs/custom_textformfield.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../data/repositories/topup_repositoy.dart';

class DigitalPaymentsPage extends StatefulWidget {
  const DigitalPaymentsPage({super.key});

  @override
  State<DigitalPaymentsPage> createState() => _DigitalPaymentsPageState();
}

class _DigitalPaymentsPageState extends State<DigitalPaymentsPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController(text: '0');
  final FocusNode _focusNodeAmountController = FocusNode();
  String _selectedProduct = '';
  Map<int, dynamic> productMapID = {};
  bool _isProcessing = false;
  bool _isLoading = true;
  UniqueKey containerButtonKey = UniqueKey();
  final FToast fToast = FToast();

  // Produits disponibles
  final List<String> _products = [];
  String _selectedContact = '';
  final List<String> destinataires = [];

  @override
  void initState() {
    super.initState();
    _loadDestinataires();
    fToast.init(context);

    // Écouteur pour le champ "Montant"
    _focusNodeAmountController.addListener(() {
      if (!_focusNodeAmountController.hasFocus) {
        _handleAmountChange();
      }
    });
  }

  Future<void> _handleAmountChange() async {
    if (_amountController.text.isNotEmpty) {
      // Traitement si nécessaire
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    _focusNodeAmountController.dispose();
    super.dispose();
  }

  bool _isLoadingDestinataires = true;
  void _loadDestinataires() async {
    if (mounted) {
      setState(() {
        _isLoadingDestinataires = true;
        _isLoading = true;
      });
    }

    try {
      User user = await UserRepository.getUserInSharedPreferences();
      List<String> loadedDestinataires = [];

      for (var destinataire in user.roles) {
        //loadedDestinataires.add('${destinataire.first_name} ${destinataire.last_name} ${destinataire.phone_number}');
      }

      if (mounted) {
        setState(() {
          destinataires.clear();
          destinataires.addAll(loadedDestinataires);
          _isLoadingDestinataires = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Erreur lors du chargement des destinataires: $e');
      if (mounted) {
        setState(() {
          _isLoadingDestinataires = false;
          _isLoading = false;
        });
      }
    }
  }

  void _choiceDestinataire() {
    DropDownState<String>(
      dropDown: DropDown<String>(
        data: destinataires.map((toElement) => SelectedListItem<String>(data: toElement)).toList(),
        onSelected: (selectedItems) {
          List<String> list = [];
          for (var item in selectedItems) {
            list.add(item.data);
          }
          setState(() {
            _selectedContact = list[0];
            _loadProducts();
          });
        },
      ),
    ).showModal(context);
  }

  void _choiceProducts() {
    DropDownState<String>(
      dropDown: DropDown<String>(
        data: _products.map((toElement) => SelectedListItem<String>(data: toElement)).toList(),
        onSelected: (selectedItems) {
          List<String> list = [];
          for (var item in selectedItems) {
            list.add(item.data);
          }
          setState(() {
            _selectedProduct = list[0];
          });
          // Calculer le montant ici pour l'afficher

        },
      ),
    ).showModal(context);
  }

  Future<void> _loadProducts() async {
    if (_selectedContact.isEmpty) return;

    setState(() {
      _isLoading = true;
      productMapID.clear();
    });

    try {
      String? phoneNumber = Helpers.getNumberAndNameUser(_selectedContact)?['phone_number'];
      if (phoneNumber == null) return;

      List<dynamic>? products = await TopupRepository.getAvailableProducts(
          {'phone_number': phoneNumber},
          context
      );

      if (products != null) {
        List<String> productList = [];
        Map<int, dynamic> map = {};
        for (var product in products) {
          String name = "${product['operator']['name']} ${product['name']}";
          int id = product['id'];
          dynamic data = {
            'name': name,
            'retail': product['retail']
          };

          map[id] = data;
          productList.add(name);
        }

        setState(() {
          _products.clear();
          _products.addAll(productList);
          productMapID = map;
          if (_products.isNotEmpty) {
            _selectedProduct = _products.first;
          }
        });
      }
    } catch (e) {
      print('Erreur lors du chargement des produits: $e');
      fToast.showToast(
          child: CustomToast(
          message: 'Erreur lors du chargement des produits',
          textColor: Colors.white,
          backgroundColor: Colors.red.withOpacity(1))
    );
    } finally {
    setState(() {
    _isLoading = false;
    });
    }
  }

  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  bool _isAddingBeneficiaire = false;
  String _countryCode = '+224';

  Future<void> _addDestinataire() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      setState(() => _isAddingBeneficiaire = true);
      setState(() => containerButtonKey = UniqueKey());
      await UserRepository.getUserInSharedPreferences();
      setState(() => _isAddingBeneficiaire = false);
    }
  }

  void _pickUpContact() async {
    final status = await Permission.contacts.request();
    if (!status.isGranted) return;

    final FlutterNativeContactPicker _contactPicker = FlutterNativeContactPicker();
    Contact? contact = await _contactPicker.selectContact();
    if (contact == null) return;

    try {
      List<String>? fullName = contact.fullName?.split(' ');
      if (fullName != null && fullName.length >= 2) {
        String firstName = fullName[0];
        String lastName = fullName.sublist(1).join(' ');
        setState(() {
          _firstNameController.text = firstName;
          _lastNameController.text = lastName;
        });
      } else if (fullName != null && fullName.isNotEmpty) {
        setState(() {
          _firstNameController.text = fullName[0];
          _lastNameController.text = fullName[0];
        });
      }

      if (contact.phoneNumbers != null && contact.phoneNumbers!.isNotEmpty) {
        String? rawPhoneNumber = contact.phoneNumbers![0];
        if (rawPhoneNumber != null) {
          final Map<String, String> cleanedNumber = Helpers.parsePhoneNumber(rawPhoneNumber);
          setState(() {
            _countryCode = cleanedNumber['countryCode']!;
          });
        }
      }
    } catch (e) {
      print('Erreur lors du traitement du contact: $e');
    }
  }

  void _showModalBottomAddDestinataire() {
    final _formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: SafeArea(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ajouter un destinataire',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.person_add, size: 24, color: Colors.blue),
                          onPressed: _pickUpContact,
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          CustomTextFormField(
                            hintText: 'Prénom',
                            controller: _firstNameController,
                            validator: (value) => value == null || value.isEmpty
                                ? "Ce champ est requis"
                                : null,
                            borderColor: Colors.black,
                          ),
                          SizedBox(height: 8),
                          CustomTextFormField(
                            hintText: 'Nom',
                            controller: _lastNameController,
                            validator: (value) => value == null || value.isEmpty
                                ? "Ce champ est requis"
                                : null,
                            borderColor: Colors.black,
                          ),
                          SizedBox(height: 8),
                          CustomPhoneField(
                            initialCountryCode: _countryCode,
                            onChanged: (phone) {
                              setState(() {
                                _phoneController.text = phone.completeNumber;
                                _countryCode = phone.countryCode;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      key: containerButtonKey,
                      child: _isAddingBeneficiaire
                          ? CustomLoader()
                          : CustomButton(
                        text: 'Ajouter',
                        onTap: _addDestinataire,
                        isFullWidth: true,
                        isLoading: _isAddingBeneficiaire,
                      ),
                    ),
                    SizedBox(height: 8),
                    CustomButton(
                      text: 'Annuler',
                      onTap: () => Navigator.of(context).pop(),
                      isFullWidth: true,
                      backgroundColor: Colors.red,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _submitRecharge() async {
    if (_formKey.currentState!.validate() && _selectedContact.isNotEmpty && _selectedProduct.isNotEmpty) {
      setState(() {
        _isProcessing = true;
      });

      try {
        String? phoneNumber = Helpers.getNumberAndNameUser(_selectedContact)?['phone_number'];
        if (phoneNumber == null) return;

        String productId = _selectedProduct.split(' ').last;
        double amount = double.tryParse(_amountController.text) ?? 0;

        // bool success = await TopupRepository.processTopup(
        //     {
        //       'phone_number': phoneNumber,
        //       'product_id': productId,
        //       'amount': amount,
        //     },
        //     context
        // );
        //
        // if (success) {
        //   _showSuccessDialog();
        // }
      } catch (e) {
        print('Erreur lors de la recharge: $e');
        fToast.showToast(
            child: CustomToast(
            message: 'Erreur lors de la recharge',
            textColor: Colors.white,
            backgroundColor: Colors.red.withOpacity(1),)
    );
    } finally {
    setState(() {
    _isProcessing = false;
    });
    }
    } else {
    fToast.showToast(
    child: CustomToast(
    message: 'Veuillez sélectionner un destinataire et un produit',
    textColor: Colors.white,
    backgroundColor: Colors.yellow[800]!.withOpacity(1),
    ),
    gravity: ToastGravity.TOP
    );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle, size: 40, color: Colors.blue[700]),
              ),
              const SizedBox(height: 16),
              Text('Recharge Réussie!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  )),
              const SizedBox(height: 8),
              Text('Votre recharge a été effectuée avec succès',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  )),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildDetailRow('Destinataire:', _selectedContact.split('-')[0]),
                    const Divider(height: 20, thickness: 0.5),
                    _buildDetailRow('Produit:', _selectedProduct.split(' ').sublist(0, 2).join(' ')),
                    const Divider(height: 20, thickness: 0.5),
                    _buildDetailRow('Montant:', '${_amountController.text} GNF', isAmount: true),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[100]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 20, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Un SMS de confirmation a été envoyé au bénéficiaire',
                        style: TextStyle(
                          color: Colors.blue[800],
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _resetForm();
                  },
                  child: const Text('Retour à l\'accueil',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isAmount = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.4),
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Text(
                value,
                style: TextStyle(
                  color: isAmount ? Colors.green[700] : Colors.black,
                  fontWeight: isAmount ? FontWeight.bold : FontWeight.normal,
                  fontSize: isAmount ? 15 : 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _amountController.clear();
    setState(() {
      _selectedContact = '';
      _selectedProduct = '';
      _products.clear();
    });
  }

  Widget _buildRecipientSection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        _isLoadingDestinataires
            ? Center(child: CircularProgressIndicator())
            : Container(
          constraints: BoxConstraints(
            minWidth: double.infinity,
          ),
          child: TextFormField(
            controller: TextEditingController(text: _selectedContact),
            readOnly: true,
            onTap: _choiceDestinataire,
            decoration: InputDecoration(
              labelText: _selectedContact.isEmpty
                  ? 'Sélectionner un bénéficiaire'
                  : 'Destinataire',
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.blue,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              suffixIcon: IconButton(
                icon: Icon(Icons.person_add),
                onPressed: _showModalBottomAddDestinataire,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductSection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        Container(
          constraints: BoxConstraints(
            minWidth: double.infinity,
          ),
          child: TextFormField(
            controller: TextEditingController(text: _selectedProduct),
            readOnly: true,
            onTap: _choiceProducts,
            decoration: InputDecoration(
              labelText: _selectedContact.isEmpty
                  ? 'Sélectionner un produit'
                  : 'Produit',
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.blue,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountSection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          child: Row(
            children: [
              Expanded(flex:1, child: Center(
                child: Text(
                  'Montant à Récharger',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              )),
              Expanded(child: CustomTextFormField(controller: _amountController,))
            ],
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
        title: Text('Recharge Téléphonique'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
            : SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRecipientSection(colorScheme),
                SizedBox(height: 16),
                if (_selectedContact.isNotEmpty) _buildProductSection(colorScheme),
                SizedBox(height: 16),
                if (_selectedProduct.isNotEmpty) _buildAmountSection(colorScheme),
                SizedBox(height: 24),
                _isProcessing
                    ? CustomLoader()
                    : CustomButton(
                  text: 'Confirmer la recharge',
                  onTap: _submitRecharge,
                  isFullWidth: true,
                  backgroundColor: colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
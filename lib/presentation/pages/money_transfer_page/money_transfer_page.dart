import 'package:drop_down_list/drop_down_list.dart';
import 'package:drop_down_list/model/selected_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'package:flutter_native_contact_picker/model/contact.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gotransfer/config/app_config.dart' as App;
import 'package:gotransfer/constants/dimensions.dart';
import 'package:gotransfer/core/utils/helpers.dart';
import 'package:gotransfer/data/models/beneficiary_model.dart';
import 'package:gotransfer/data/models/remittance_model.dart';
import 'package:gotransfer/data/models/user_model.dart';
import 'package:gotransfer/data/repositories/destinataire_repository.dart';
import 'package:gotransfer/data/repositories/remittance_repository.dart';
import 'package:gotransfer/data/repositories/user_repository.dart';
import 'package:gotransfer/routes/app_routes.dart';
import 'package:gotransfer/widgets/buttons/custom_button.dart';
import 'package:gotransfer/widgets/components/custom_loader.dart';
import 'package:gotransfer/widgets/components/custom_toast.dart';
import 'package:gotransfer/widgets/inputs/custom_phonefield.dart';
import 'package:gotransfer/widgets/inputs/custom_textformfield.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../widgets/components/horizontal_selectable_list.dart';
import '../../../widgets/components/top_snackbar.dart';

class MoneyTransferPage extends StatefulWidget {
  const MoneyTransferPage({super.key});

  @override
  State<MoneyTransferPage> createState() => _MoneyTransferPageState();
}

class _MoneyTransferPageState extends State<MoneyTransferPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountSendController = TextEditingController(text: '0');
  final FocusNode _focusNodeAmountSendController = FocusNode();
  final _amountReceiveController = TextEditingController(text: '0');
  final FocusNode _focusNodeAmountReceiveController = FocusNode();
  final _rateController = TextEditingController(text: "");
  final _feesController = TextEditingController(text: "0");
  final _totalController = TextEditingController();
  String _selectedContact = '';
  Destinataire? destinataire = null;
  String _selectedPaymentMethod = 'Mobile Money';
  bool _isSending = false;
  bool _isLoading = true;
  UniqueKey containerButtonKey = UniqueKey();
  final FToast fToast = FToast();

  // Conversion final
  Map<String, dynamic> data =  {
    'fixed_fee' : 0,
    'pourcentage_frais' : 0,
    'total_fee' : 0,
    'currency' : 0,
    'from' : '',
    'to' : '',
    'ratio' : 0,
    "country_code" : ''
  };

  // Destinataires
  final List<String> destinataires = [];

  final TextEditingController _phoneController = TextEditingController();

  // Méthodes de paiement disponibles
  final List<HorizontalSelectableItem> _paymentMethods = [
    HorizontalSelectableItem(
      text: 'Mobile Money',
      leadingIcon: Icon(FontAwesome.mobile_phone, size: 24),
    ),
    HorizontalSelectableItem(
      text: 'Go Pay',
      leadingIcon: Icon(FontAwesome.paypal, size: 24),
    ),
    HorizontalSelectableItem(
      text: 'Cash Pickup',
      leadingIcon: Icon(Icons.cabin_sharp, size: 24),
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Écouteur pour le champ "Montant à envoyer"
    _focusNodeAmountSendController.addListener(() {
      if (!_focusNodeAmountSendController.hasFocus) {
        _handleAmountSendChange();
      }
    });

    // Écouteur pour le champ "Montant à recevoir"
    _focusNodeAmountReceiveController.addListener(() {
      if (!_focusNodeAmountReceiveController.hasFocus) {
        _handleAmountReceiveChange();
      }
    });

    _loadDestinataires();

    fToast.init(context);
  }

  Future<void> _handleAmountSendChange() async {
    if (_amountSendController.text.isNotEmpty) {
      await _getTargetCurrency();
      // Autres traitements nécessaires...
    }
  }

  Future<void> _handleAmountReceiveChange() async {
    if (_amountReceiveController.text.isNotEmpty) {
      await _getTargetCurrency();
      // Autres traitements nécessaires...
    }
  }

  @override
  void dispose() {
    _amountSendController.dispose();
    _amountReceiveController.dispose();
    _rateController.dispose();
    _feesController.dispose();
    _totalController.dispose();
    _focusNodeAmountReceiveController.dispose();
    _focusNodeAmountSendController.dispose();
    super.dispose();
  }

  bool _isLoadingDestinataires = false;
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
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _convertSendToReceive() async {
    if (_amountSendController.text.isEmpty) {
      _amountReceiveController.clear();
      return;
    }

    final amount = double.tryParse(_amountSendController.text);
    if (amount == null) return;

    await _getTargetCurrency();
  }

  Future<void> _convertReceiveToSend() async {
    if (_amountReceiveController.text.isEmpty) {
      _amountSendController.clear();
      return;
    }

    final amount = double.tryParse(_amountReceiveController.text.replaceAll(',', ''));
    if (amount == null) return;

    await _getTargetCurrency();
  }

  String _targetCurrency = '';
  bool _targetCurrencyLoader = false;

  Future<void> _getTargetCurrency() async {
    if (_selectedContact.isNotEmpty) {
      setState(() {
        _targetCurrencyLoader = true;
        _isLoading = true;
      });

      String _numberContact = Helpers.getNumberAndNameUser(_selectedContact)!['phone_number'] ?? '';
      String _srcCurrency = (await UserRepository.getUserInSharedPreferences()).currency ?? '';
      Destinataire d = (await DestinataireRepository.getCountryCodByPhoneNumber(_numberContact, context))!;
      String _dstCurrency = d.countryCurrency ?? '';
      double _amout = double.tryParse(_amountSendController.text) ?? 0;
      String _srcCountry = App.AppConfig.currencyToCountry[_srcCurrency] ?? '';
      String _dstCountry = App.AppConfig.currencyToCountry[_dstCurrency] ?? '';

      print('$_numberContact $_srcCurrency $_dstCurrency $_srcCountry $_dstCountry $_amout');

      Map<String, dynamic>? rs = await DestinataireRepository.getXRate(
        _numberContact,
        _srcCurrency,
        _dstCurrency,
        _srcCountry,
        _dstCountry,
        _amout,
        context
      );
      setState(() {
        _targetCurrencyLoader = false;
        _isLoading = true;
        _isLoading = false;
      });
      if( rs == null ) return;

      print(rs);

      setState(() {
        data = rs;
        destinataire = d;
        _amountSendController.text = '${data['amount']} $_srcCurrency';
        _amountReceiveController.text = '${data['amount'] * data['ratio']} ${_dstCurrency}';
        _rateController.text = "1 ${_srcCurrency} = ${data['ratio']} ${_dstCurrency}";
        _feesController.text = '${data['total_fee']}';
        _totalController.text = '${data['total_amount']} ${_srcCurrency}';
        _targetCurrency = _dstCurrency;
        _targetCurrencyLoader = false;
        _isLoading = false;
      });

      setState(() {
      });
    }
  }

  void _submitTransfer() async {
    if (_formKey.currentState!.validate() && _selectedContact.isNotEmpty && _rateController.text.isNotEmpty) {
      setState(() {
        _isSending = true;
      });

      User user = (await UserRepository.getUserInSharedPreferences());
      if( user == null || destinataire == null ) return;

      bool rs = await RemittanceRepository.create(
        Remittance(
          transactionId: '',
          sender: user.id ?? 0,
          role: destinataire!.id ?? 0,
          cashoutLocation: 'Guinea',
          payoutOption: _selectedPaymentMethod,
          amountSent: double.tryParse(_amountSendController.text) ?? 0,
          senderCurrency: user.currency ?? '',
          exchangeRate: 1000,
          recipientAmount: double.tryParse(_amountReceiveController.text) ?? 0,
          agentProfit: 0,
          fees: double.tryParse(_feesController.text) ?? 0,
          total: double.tryParse(_totalController.text) ?? 0,
          status: 'REQUESTED'
        ),
        context
      );
      if( rs )
        _showSuccessDialog();

      if (mounted) {
        setState(() {
          _isSending = false;
          _isLoading = false;
        });
      }
    }
    else {
      fToast.showToast(
        child: CustomToast(
          message: 'Selectionner le destinataire!',
          textColor: Colors.white,
          backgroundColor: Colors.yellow[800]!.withOpacity(1),
        ),
        gravity: ToastGravity.TOP
      );
    }
  }

  void _choiceDestinataire(){
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
          });
        },
      ),
    ).showModal(context);
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
      bool rs = await DestinataireRepository.create(
          Destinataire(
            first_name: _firstNameController.text ?? '',
            last_name: _lastNameController.text ?? '',
            pays: Helpers.getCountry(_countryCode),
            countryCode: _countryCode,
            countryCurrency: Helpers.getCurrency(_countryCode),
            phone_number: _phoneController.text
          ),
          context
      );
      if( rs ) {
        _loadDestinataires();
        Navigator.of(context).pop();
      };
      setState(() => _isAddingBeneficiaire = false);
    }
  }

  void _pickUpContact() async {
    final status = await Permission.contacts.request();
    if( !status.isGranted ) return;

    final FlutterNativeContactPicker _contactPicker = FlutterNativeContactPicker();
    Contact? contact = await _contactPicker.selectContact();
    if( contact == null ) return;

    // Mettre à jour les éléments de contact
    try {
      // Séparer le nom complet
      List<String>? fullName = contact.fullName?.split(' ');

      // Vérifier si le nom complet existe et a au moins 2 parties
      if (fullName != null && fullName.length >= 2) {
        String firstName = fullName[0];
        String lastName = fullName.sublist(1).join(' '); // Gère les noms composés
        setState(() {
          _firstNameController.text = firstName;
          _lastNameController.text = lastName;
        });
      } else if (fullName != null && fullName.isNotEmpty) {
        // Cas où seul le prénom est disponible
        setState(() {
          _firstNameController.text = fullName[0];
          _lastNameController.text = fullName[0];
        });
        print('Prénom: ${fullName[0]}');
        print('Nom: non spécifié');
      } else {
        print('Aucun nom disponible');
      }

      // Accéder au numéro de téléphone
      if (contact.phoneNumbers != null && contact.phoneNumbers!.isNotEmpty) {
        String? rawPhoneNumber = contact.phoneNumbers![0];

        if (rawPhoneNumber != null) {
          // Nettoyage du numéro
          final Map<String, String> cleanedNumber = Helpers.parsePhoneNumber(rawPhoneNumber);
          setState(() {
            _countryCode = cleanedNumber!['countryCode']!;
          });
          print('cleanedNumber $cleanedNumber');
        }
      } else {
        print('Aucun numéro de téléphone disponible');
      }
    } catch (e) {
      print('Erreur lors du traitement du contact: $e');
    }
  }

  void _showModalBottomAddDestinataire(){
    final _formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 👈 autorise le BottomSheet à prendre plus de place si nécessaire
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom, // 👈 évite d’être masqué par le clavier
            ),
            child: SingleChildScrollView(
              child: SafeArea(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2 * AppDimensions.smallPadding,
                    vertical: 20,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header avec bouton de fermeture
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
                      SizedBox(height: 2 * AppDimensions.smallPadding),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            CustomTextFormField(
                              hintText: 'first name',
                              controller: _firstNameController,
                              validator: (value) => value == null || value.isEmpty
                                  ? "Ce champ est requis"
                                  : null,
                              borderColor: Colors.black,
                            ),
                            SizedBox(height: AppDimensions.smallPadding),
                            CustomTextFormField(
                              hintText: 'last name',
                              controller: _lastNameController,
                              validator: (value) => value == null || value.isEmpty
                                  ? "Ce champ est requis"
                                  : null,
                              borderColor: Colors.black,
                            ),
                            SizedBox(height: AppDimensions.smallPadding),
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
                      SizedBox(height: AppDimensions.smallPadding),
                      Container(key:containerButtonKey, child: _isAddingBeneficiaire ? CustomLoader() : CustomButton(
                        text: 'Ajouter',
                        onTap: _addDestinataire,
                        isFullWidth: true,
                        isLoading: _isAddingBeneficiaire,
                      ),),
                      SizedBox(height: AppDimensions.smallPadding),
                      CustomButton(
                        text: 'Annuler',
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        isFullWidth: true,
                        backgroundColor: Colors.red,
                      ),
                      SizedBox(height: 2 * AppDimensions.smallPadding),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Empêche la fermeture en cliquant à l'extérieur
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
              // Header avec icône
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle,
                    size: 40,
                    color: Colors.blue[700]),
              ),
              const SizedBox(height: 16),

              // Titre
              Text('Transfert Réussi!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  )),
              const SizedBox(height: 8),
              Text('Votre transaction a été effectuée avec succès',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  )),
              const SizedBox(height: 20),

              // Détails de la transaction
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
                    _buildDetailRow('Montant envoyé:',
                        '${_amountSendController.text} CAD',
                        isAmount: true),
                    const Divider(height: 20, thickness: 0.5),
                    _buildDetailRow('Montant reçu:',
                        '${_amountReceiveController.text} ${_targetCurrency}',
                        isAmount: true),
                    const Divider(height: 20, thickness: 0.5),
                    _buildDetailRow('Méthode:', _selectedPaymentMethod),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Message d'information
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[100]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 20,
                        color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Un SMS avec les instructions a été envoyé au bénéficiaire',
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

              // Bouton de fermeture
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
                    Navigator.popAndPushNamed(context, AppRoutes.home);
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
          // Label avec contrainte de largeur
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

          SizedBox(width: AppDimensions.smallPadding),

          // Valeur avec scroll horizontal si besoin
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
    _amountSendController.clear();
    _amountReceiveController.clear();
    setState(() {
      _selectedContact = '';
      _selectedPaymentMethod = 'Mobile Money';
    });
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
      body: SafeArea(child: _isLoading ? Center(child: CircularProgressIndicator(color: colorScheme.primary)) :
      SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRecipientSection(colorScheme),

              SizedBox(height: 3*AppDimensions.smallPadding),

              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: _buildAmountSection(
                      controller: _amountSendController,
                      focusNode: _focusNodeAmountSendController,
                      label: 'Montant à envoyer',
                      currency: 'CAD',
                      colorScheme: colorScheme,
                    ),
                  ),
                  SizedBox(width: 16), // <-- Ajoute un espacement ici
                  Expanded(
                    child: _buildAmountSection(
                      controller: _amountReceiveController,
                      focusNode: _focusNodeAmountReceiveController,
                      label: 'Montant à recevoir',
                      currency: _targetCurrency,
                      colorScheme: colorScheme,
                    ),
                  )
                ],
              ),

              SizedBox(height: 16),

              // Section Taux de change
              _buildInfoField(
                controller: _rateController,
                label: 'Taux de change ${_rateController.text}',
                icon: Icons.currency_exchange,
                colorScheme: colorScheme,
                crossAxisAlignment: CrossAxisAlignment.center
              ),

              SizedBox(height: 2*AppDimensions.smallPadding),

              // Section Total
              _buildInfoField(
                controller: _totalController,
                label: 'Total à transferer ${_totalController.text}',
                icon: Icons.calculate,
                colorScheme: colorScheme,
                crossAxisAlignment: CrossAxisAlignment.center
              ),

              SizedBox(height: 24),

              // Section Méthode de paiement
              Text(
                'Méthode de paiement',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              HorizontalSelectableList(
                items: _paymentMethods,
                onItemSelected: (selectedItem) {
                  print('Item sélectionné: $selectedItem');
                  setState(() {
                    _selectedPaymentMethod = _paymentMethods[selectedItem].text ?? 'Mobile Money';
                  });
                },
                selectedColor: colorScheme.primary,
                unselectedColor: Colors.grey[200]!,
                selectedTextColor: Colors.white,
                unselectedTextColor: Colors.black87,
                itemPadding: 16.0,
              ),

              // _buildPaymentMethodDropdown(colorScheme),

              SizedBox(height: 24),

              // Bouton Envoyer
              _isSending ? CustomLoader() :
              CustomButton(
                text: 'Envoyer le transfer',
                onTap: _isSending ? null : _submitTransfer,
                isFullWidth: true,
                backgroundColor: colorScheme.primary,
              ),
            ],
          ),
        ),
      ))
    );
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
            minWidth: double.infinity, // Prend toute la largeur
          ),
          child: TextFormField(
            controller: TextEditingController(text: _selectedContact),
            readOnly: true, // Empêche la saisie
            onTap: _choiceDestinataire, // 👈 Appelé quand on clique sur le champ
            decoration: InputDecoration(
              labelText: _selectedContact.isEmpty
                  ? 'Sélectionner un bénéficiaire'
                  : 'Destinataire',
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.blue,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(AppDimensions.borderRadius),
                ),
              ),
              suffixIcon: IconButton(
                icon: Icon(Icons.person_add),
                onPressed: _showModalBottomAddDestinataire, // 👈 Même action que le onTap
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountSection({
    required TextEditingController controller,
    required FocusNode? focusNode,
    required String label,
    required String currency,
    required ColorScheme colorScheme,
    void Function(String)? onChanged,
    bool readOnly = false,
    bool enabled = true
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        CustomTextFormField(
          controller: controller,
          focusNode: focusNode,
          enabled: enabled,
          readOnly: readOnly,
          onChanged: onChanged,
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
        ),
      ],
    );
  }

  Widget _buildInfoField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ColorScheme colorScheme,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
    bool showBorder = true,
    bool isDense = false,
  }) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6.0),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          decoration: showBorder
              ? BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          )
              : null,
          child: TextFormField(
            controller: controller,
            readOnly: true,
            style: TextStyle(
              fontSize: isDense ? 14 : 16,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: isDense ? 12 : 16,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: colorScheme.outline.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: colorScheme.primary,
                ),
              ),
              filled: true,
              fillColor: colorScheme.surfaceVariant.withOpacity(0.2),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: colorScheme.primary.withOpacity(0.4),
                  width: 2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
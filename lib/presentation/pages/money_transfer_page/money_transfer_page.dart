import 'package:drop_down_list/drop_down_list.dart';
import 'package:drop_down_list/model/selected_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'package:flutter_native_contact_picker/model/contact.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gotransfer/config/api_config.dart';
import 'package:gotransfer/config/app_config.dart' as App;
import 'package:gotransfer/constants/dimensions.dart';
import 'package:gotransfer/core/utils/helpers.dart';
import 'package:gotransfer/data/models/remittance_model.dart';
import 'package:gotransfer/data/models/user_model.dart';
import 'package:gotransfer/data/repositories/role_repository.dart';
import 'package:gotransfer/data/repositories/remittance_repository.dart';
import 'package:gotransfer/data/repositories/user_repository.dart';
import 'package:gotransfer/routes/app_routes.dart';
import 'package:gotransfer/widgets/buttons/custom_button.dart';
import 'package:gotransfer/widgets/components/custom_loader.dart';
import 'package:gotransfer/widgets/components/custom_toast.dart';
import 'package:gotransfer/widgets/inputs/custom_phonefield.dart';
import 'package:gotransfer/widgets/inputs/custom_textformfield.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../data/models/role_model.dart';
import '../../../widgets/components/grid_selectable_list.dart';
import '../../../widgets/components/horizontal_selectable_list.dart';
import '../../../widgets/components/top_snackbar.dart';

class MoneyTransferPage extends StatefulWidget {
  const MoneyTransferPage({super.key});

  @override
  State<MoneyTransferPage> createState() => _MoneyTransferPageState();
}

class _MoneyTransferPageState extends State<MoneyTransferPage> {
  final _formKey = GlobalKey<FormState>();
  late UniqueKey _phoneNumberKey = UniqueKey();
  final _amountSendController = TextEditingController(text: '0');
  final FocusNode _focusNodeAmountSendController = FocusNode();
  final _amountReceiveController = TextEditingController(text: '0');
  final FocusNode _focusNodeAmountReceiveController = FocusNode();
  final _rateController = TextEditingController(text: "");
  final _feesController = TextEditingController(text: "0");
  final _totalController = TextEditingController();
  String _selectedContact = '';
  Role? role = null;
  String _selectedPaymentMethod = 'Mobile Money';
  bool _isSending = false;
  bool _isLoading = true;
  UniqueKey containerButtonKey = UniqueKey();
  final FToast fToast = FToast();
  Map<String, Role> contactToRole = {};

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


  // Méthodes de paiement disponibles
  final List<GridSelectableItem> _paymentMethods = [
    GridSelectableItem(
      text: 'Orange Money',
      asset: 'assets/images/wbg/orange-money.png',
      leadingIcon: Image.asset('assets/images/orange-money.png', width: 200, height: 50),
      trailingIcon: null
    ),
    GridSelectableItem(
      text: 'GoPay',
      asset: 'assets/images/wbg/gopay.png',
      leadingIcon: Image.asset('assets/images/gopay.png', width: 200, height: 50),
      trailingIcon: null
    ),
    GridSelectableItem(
      text: 'Wave',
      asset: 'assets/images/wbg/wave.png',
      leadingIcon: Image.asset('assets/images/wave.png', width: 200, height: 50),
      trailingIcon: null
    ),
    GridSelectableItem(
      text: 'CashPickup',
      asset: 'assets/images/wbg/cash-pickup.png',
      leadingIcon: Image.asset('assets/images/cash-pickup.png', width: 200, height: 50),
      trailingIcon: null
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
      await _getTargetCurrency(_amountSendController.text);
      // Autres traitements nécessaires...
    }
  }

  Future<void> _handleAmountReceiveChange() async {
    if (_amountReceiveController.text.isNotEmpty) {
      await _getTargetCurrency(_amountReceiveController.text);
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
      List<dynamic> roles = await UserRepository.getRolesInSharedPreferences();
      print(roles);
      List<String> loadedDestinataires = [];
      Map<String, Role> loadedcontactToRole = {};

      for (var role in roles) {
        Role d = Role.fromJson(role);
        loadedDestinataires.add('${d.firstName} ${d.lastName} ${d.telephone}');
        loadedcontactToRole['${d.firstName} ${d.lastName} ${d.telephone}'] = d;
      }

      if (mounted) {
        setState(() {
          destinataires.clear();
          contactToRole.clear();
          destinataires.addAll(loadedDestinataires);
          contactToRole.addAll(loadedcontactToRole);
          _isLoadingDestinataires = false;
          _selectedContact = destinataires.last;
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

  String _targetCurrency = '';
  bool _targetCurrencyLoader = false;

  Future<void> _getTargetCurrency(String amountStr) async {
    double amount = amountStr.split(" ").length > 1 ? double.tryParse(amountStr.split(" ")[0]) ?? 0 : double.tryParse(amountStr) ?? 0;
    if (_selectedContact.isNotEmpty) {
      setState(() {
        _targetCurrencyLoader = true;
        _isLoading = true;
      });

      String userCurrency = await UserRepository.getCurrencyInSharedPreferences();
      String userCountry = await UserRepository.getCountryInSharedPreferences();

      Role role = contactToRole[_selectedContact]!;
      Map<String, dynamic>? rs = await RoleRepository.getXRate(
        role.telephone,
        userCurrency,
        role.countryCurrency,
        userCountry,
        role.country,
        amount,
        context,
        fToast
      );
      print(rs);
      setState(() {
        _targetCurrencyLoader = false;
        _isLoading = true;
        _isLoading = false;
      });
      if( rs == null ) return;

      print(rs);

      setState(() {
        data = rs;
        _amountSendController.text = '${data['amount']} ${data['currency']}';
        _amountReceiveController.text = '${data['amount'] * data['ratio']} ${role.countryCurrency}';
        _rateController.text = "Taux de change 1.00 ${userCurrency} = ${data['ratio']} ${role.countryCurrency}";
        _feesController.text = '${data['total_fee']}';
        _totalController.text = '${data['total_amount']} ${userCurrency}';
        _targetCurrencyLoader = false;
        _isLoading = false;
      });
      /*setState(() {
        data = rs;
        destinataire = d;
        _amountSendController.text = '${data['amount']} ${data['currency']}';
        _amountReceiveController.text = '${data['amount'] * data['ratio']} ${_dstCurrency}';
        _rateController.text = "Taux de change 1.00 ${user.currency} = ${data['ratio']} ${_dstCurrency}";
        _feesController.text = '${data['total_fee']}';
        _totalController.text = '${data['total_amount']} ${user.currency}';
        _targetCurrency = _dstCurrency;
        _targetCurrencyLoader = false;
        _isLoading = false;
      });*/

      setState(() {
      });
    }
  }

  void _submitTransfer() async {
    if (_formKey.currentState!.validate() && _selectedContact.isNotEmpty && _rateController.text.isNotEmpty) {
      setState(() {
        _isSending = true;
      });

      if( role == null ) {
        fToast.showToast(
            child: CustomToast(
              message: 'Destinataire non selectionné!',
              textColor: Colors.white,
              backgroundColor: Colors.yellow[800]!.withOpacity(1),
            ),
            gravity: ToastGravity.TOP
        );
        if (mounted) {
          setState(() {
            _isSending = false;
          });
        }
      }

      String senderCurrency = await UserRepository.getCurrencyInSharedPreferences();
      String senderCountry = await UserRepository.getCountryInSharedPreferences();

      bool rs = await RemittanceRepository.create(
          Remittance(
            transactionId: '',
            senderId: 0,
            roleId: role!.id,
            cashoutLocation: role!.country,
            payoutOption: _selectedPaymentMethod,
            amountSent: data['amount'],
            senderCurrency: senderCurrency,
            exchangeRate: data['ratio'],
            recipientAmount: data['ratio'] * data['amount'],
            recipientCurrency: role!.countryCurrency, // Devise du bénéficiaire (Guinée)
            agentProfit: 0,
            fees: data['total_fee'],
            total: data['total_amount'],
            status: 'REQUESTED',
            transactionCompletionDate: null, // À compléter quand la transaction est terminée
            agentStartUsername: null, // Nom d'utilisateur de l'agent qui initie
            agentCompletionUsername: null, // À compléter à la fin de la transaction
            comments: null,
            partnerCode: null, // Code partenaire si applicable
            createdAt: null, // Date de création maintenant
            updatedAt: null, // Date de mise à jour maintenant
            remittanceUuid: '', // Génère un UUID v4 unique
          ),
        context
      );
      if( rs ){
        _showSuccessDialog();
      }

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
            role = contactToRole[_selectedContact];
          });
          if( _amountSendController.text.isNotEmpty && _amountSendController.text != '0' ){
            _getTargetCurrency(_amountSendController.text);
          }else if( _amountReceiveController.text.isNotEmpty && _amountReceiveController.text != '0' ){
            _getTargetCurrency(_amountReceiveController.text);
          }
        },
      ),
    ).showModal(context);
  }

  TextEditingController _firstNameController = TextEditingController(text: '');
  TextEditingController _lastNameController = TextEditingController(text: '');
  TextEditingController _countryController = TextEditingController(text: 'GN');
  TextEditingController _countryCodeController = TextEditingController(text: '+224');
  TextEditingController _countryCurrencyController = TextEditingController(text: '+224');
  final TextEditingController _phoneController = TextEditingController(text: '');
  final TextEditingController _emailController = TextEditingController(text: '');
  bool _isAddingBeneficiaire = false;

  Future<void> _addDestinataire() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      setState(() => _isAddingBeneficiaire = true);
      setState(() => containerButtonKey = UniqueKey());
      await UserRepository.getUserInSharedPreferences();

      bool rs = await RoleRepository.create(
          Role(
            id: 0,
            senderId: 0,
            firstName: _firstNameController.text,
            lastName: _lastNameController.text,
            country: _countryController.text,
            countryCode: _countryCodeController.text,
            countryCurrency: _countryCurrencyController.text,
            telephone: _phoneController.text,
            email: _emailController.text,
            active: true,
            idCard: '',
            idExpDate: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          context,
        fToast
      );
      if( rs ) {
        _loadDestinataires();
        setState(() {
          _firstNameController.text = '';
          _lastNameController.text = '';
          _phoneController.text = '';
          _phoneNumberKey = UniqueKey();
        });
        //Navigator.of(context).pop();
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
          setState(() {
            _phoneController.text = rawPhoneNumber.trim().trimLeft().trimRight();
            _phoneNumberKey = UniqueKey();
          });
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
                            /*CustomTextFormField(
                              hintText: 'example@gmail.com',
                              controller: _emailController,
                              validator: (value) => null,
                              borderColor: Colors.black,
                            ),*/
                            SizedBox(height: AppDimensions.smallPadding),
                            CustomPhoneField(
                              key: _phoneNumberKey,
                              initialValue: _phoneController.text,
                              onChanged: (phone) {
                                String _code = phone.countryCode;
                                setState(() {
                                  _phoneController.text = phone.completeNumber.trim().replaceAll("+", "");
                                  _countryController.text = App.AppConfig.codeToCountry[_code]!;
                                  _countryCodeController.text = phone.countryCode.replaceAll("+", "");
                                  _countryCurrencyController.text = App.AppConfig.codeToCurrency[_code]!;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: AppDimensions.smallPadding),
                      Container(
                        key:containerButtonKey,
                        child: _isAddingBeneficiaire ?
                        CustomLoader() :
                        CustomButton(
                          text: 'Ajouter',
                          onTap: _addDestinataire,
                          isFullWidth: true,
                          isLoading: _isAddingBeneficiaire,
                        ),
                      ),
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
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle,
                    size: 40,
                    color: Colors.blue[700]),
              ),
              const SizedBox(height: 16),

              // Titre
              Text('Transaction Soumise!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  )),
              const SizedBox(height: 8),
              Text('Votre transaction a été soumise avec succès',
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
                        '${_amountSendController.text}',
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
                  color: isAmount ? Colors.blue[700] : Colors.black,
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
                  SizedBox(width: 2*AppDimensions.smallPadding),
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

              SizedBox(height: 2*AppDimensions.smallPadding),

              // Section Taux de change
              Center(
                child: Text(
                  '${_rateController.text}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              SizedBox(height: 2*AppDimensions.smallPadding),

              Container(
                child: Row(
                  children: [
                    Expanded(flex:1, child: Center(
                      child: Text(
                        'Montant à Payer',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    )),
                    SizedBox(width: 2*AppDimensions.smallPadding),
                    Expanded(child: CustomTextFormField(controller: _totalController,))
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Section Méthode de paiement
              Center(
                child: Text(
                  'Méthode de paiement',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 8),
              GridSelectableList(
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
                text: 'Envoyer',
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
}
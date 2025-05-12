import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gotransfer/core/config/app_config.dart';
import 'package:gotransfer/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/user_repository.dart';
import '../../widgets/components/custom_scaffold.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isChecked = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _canResend = false;
  final FocusNode _focusNode = FocusNode();
  List<String> code = List.filled(6, ''); // Pour stocker le code
  List<FocusNode> focus = List.filled(6, FocusNode());
  int _timeToResendCode = 2;
  int _countToResendCode = 1;
  UniqueKey _animationKey = UniqueKey();

  // Contrôleurs pour les champs du formulaire
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _sponsorEmailController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _countryCodeController = TextEditingController();
  final TextEditingController _countryCurrencyController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final PageController _controller = PageController();
  int _currentPage = 0;

  late ColorScheme colorScheme;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _firstNameController.text = '';
    _lastNameController.text = '';
    _emailController.text = '';
    _passwordController.text = '';
    _addressController.text = '';
    _phoneController.text = '';
    _sponsorEmailController.text = '';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _controller.dispose();
    _sponsorEmailController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomScaffold(content: Text('Veuillez accepter les conditions générales'), backgroundColor: Colors.red)
      );
      return;
    }
    if( _countryController.text.isEmpty ){
      ScaffoldMessenger.of(context).showSnackBar(
          CustomScaffold(
              content: Text('Numero non pris en charge pour le moment !'),
              backgroundColor: Colors.red
          )
      );
      return;
    }

    setState(() => _isLoading = true);
    print('submi ${_phoneController.text}');
    try {
      final user = await UserRepository.register(
        User(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          phoneNumber: _phoneController.text,
          country: _countryController.text,
          sponsorEmail:  _sponsorEmailController.text.isEmpty ? null : _sponsorEmailController.text,
          countryCode: _countryCodeController.text,
          currency: _countryCurrencyController.text,
          email: _emailController.text,
          password: _passwordController.text,
          address: _addressController.text,
          commission: 0
        ),
        null,
        context,
      );
    } on HttpException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red[800],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(10),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }  finally {
      setState(() => _isLoading = false);
    }
  }

  void _nextPage() {
    if (_currentPage < 1) {
      _currentPage++;
      _controller.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _currentPage--;
      _controller.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _verifyCode() {
    setState(() => _isLoading = true);
    Future.delayed(2800.ms, () {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    });
  }

  void _resendCode() {
    setState(() {
      _canResend = false;
      code = List.filled(6, '');
      _countToResendCode++;
      _timeToResendCode = _countToResendCode*2;
      _animationKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    colorScheme = theme.colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.background,
      body: PageView(
        controller: _controller,
        physics: NeverScrollableScrollPhysics(), // Désactive le swipe
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        children: [
          _buildRegisterPage(),
          //_buildConfirmationPage(colorScheme)
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, [IconData? icon, Widget? suffixIcon]) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon, color: colorScheme.primary) : null,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: colorScheme.primary),
        borderRadius: BorderRadius.circular(10),
      ),
      labelStyle: TextStyle(color: colorScheme.onBackground),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Conditions générales', style: TextStyle(color: colorScheme.primary)),
          content: SingleChildScrollView(
            child: Text(
              '''
              1. Vous acceptez de respecter toutes les règles établies par notre plateforme.
              2. Les informations personnelles que vous fournissez seront traitées conformément à notre politique de confidentialité.
              3. Nous nous réservons le droit de suspendre ou de supprimer votre compte en cas de non-respect des conditions.
              4. Les paiements effectués ne sont pas remboursables, sauf indication contraire.
              5. Les contenus publiés doivent respecter les lois en vigueur et ne pas contenir de propos diffamatoires ou offensants.
              6. Nous ne sommes pas responsables des pertes ou dommages résultant de l'utilisation de notre plateforme.
              ''',
              style: TextStyle(color: colorScheme.onBackground),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Fermer', style: TextStyle(color: colorScheme.primary)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRegisterPage(){
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey, // Ajout du formulaire
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              // Logo personnalisé avec la palette de couleurs
              Center(
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Image.asset('assets/images/wbg/gotransfer.png', width: 100, height: 100, fit: BoxFit.cover),
                  ),
                ),
              ),
              Text(
                "S'Inscrire",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _firstNameController,
                      validator: (value){
                        if( value!.isEmpty ){
                          ScaffoldMessenger.of(context).showSnackBar(
                              CustomScaffold(
                                  content: Text('Prénom requis !') ,
                                  backgroundColor: Colors.red
                              )
                          );
                          return '';
                        }
                        return null;
                      },
                      decoration: _buildInputDecoration('Prénom', Icons.person),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _lastNameController,
                      validator: (value){
                        if( value!.isEmpty ){
                          ScaffoldMessenger.of(context).showSnackBar(
                              CustomScaffold(
                                  content: Text('Nom requis !') ,
                                  backgroundColor: Colors.red
                              )
                          );
                          return '';
                        }
                        return null;
                      },
                      decoration: _buildInputDecoration('Nom', Icons.person),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
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
                  setState(() {
                    _phoneController.text = phone.completeNumber.replaceAll("+", "");
                    _countryController.text = AppConfig.countryCodeToCountryName[phone.countryISOCode] ?? '';
                    _countryCodeController.text = phone.countryCode.replaceAll("+", "");
                    _countryCurrencyController.text = AppConfig.countryCurrencyMap[phone.countryISOCode] ?? '';
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
              const SizedBox(height: 20),
              TextFormField(
                controller: _addressController,
                validator: (value){
                  if( value!.isEmpty ){
                    ScaffoldMessenger.of(context).showSnackBar(
                        CustomScaffold(
                            content: Text('Addresse réquise !') ,
                            backgroundColor: Colors.red
                        )
                    );
                    return '';
                  }
                  return null;
                },
                keyboardType: TextInputType.text,
                decoration: _buildInputDecoration('Addresse', Icons.location_city),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                validator: (value) => value!.isEmpty
                    ? 'Champ requis'
                    : !value.contains('@')
                    ? 'Email invalide'
                    : null,
                keyboardType: TextInputType.emailAddress,
                decoration: _buildInputDecoration('Email', Icons.email),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _sponsorEmailController,
                validator: (value) {
                  if (value!.isNotEmpty && !value.contains('@')) {
                    return 'Email invalide';
                  }
                  return null;
                },
                keyboardType: TextInputType.emailAddress,
                decoration: _buildInputDecoration('Email du parrain (optionnel)', Icons.email),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                validator: (value) => value!.length < 6
                    ? '6 caractères minimum'
                    : null,
                obscureText: _obscurePassword,
                decoration: _buildInputDecoration(
                  'Mot de passe',
                  Icons.lock,
                  IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      color: colorScheme.primary,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Checkbox(
                    value: _isChecked,
                    activeColor: colorScheme.primary,
                    checkColor: Colors.white,
                    onChanged: (bool? value) {
                      setState(() {
                        _isChecked = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: _showTermsDialog,
                      child: Text(
                        'En cliquant sur ce bouton, vous acceptez nos Conditions générales',
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onBackground,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              // Bouton d'inscription avec loader
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  shadowColor: colorScheme.primary.withOpacity(0.3),
                ),
                child: _isLoading
                    ? SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Colors.white,
                  ),
                )
                    : Text(
                  'Se connecter',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Vous avez déjà un compte? ',
                    style: TextStyle(
                      color: colorScheme.onBackground,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {Navigator.pushReplacementNamed(context, AppRoutes.login);},
                    child: Text(
                      'Se connecter',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Colors.grey.shade300,
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'OU',
                      style: TextStyle(
                        color: colorScheme.onBackground,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: Colors.grey.shade300,
                      thickness: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: colorScheme.onBackground.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/google.png',
                      width: 24,
                      height: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Continuer avec Google',
                      style: TextStyle(
                        color: colorScheme.onBackground,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
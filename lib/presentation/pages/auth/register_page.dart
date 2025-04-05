import 'package:flutter/services.dart';
import 'package:gotransfer/data/repositories/user_repository.dart';
import 'package:gotransfer/exceptions/http_exception.dart';
import 'package:gotransfer/routes/app_routes.dart';
import 'package:flutter/material.dart';

import '../../../data/models/user_model.dart';
import '../../../data/preferences/user_preferences.dart';
import '../../../exceptions/badrequest_exception.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isChecked = false;
  bool _isLoading = false; // Ajout d'un état pour le loader

  // Contrôleurs pour les champs du formulaire
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Clé pour le formulaire

  late ColorScheme colorScheme;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _firstNameController.text = 'amadou';
    _lastNameController.text = 'koulibaly';
    _emailController.text = 'koulibalyamadou11@gmail.com';
    _passwordController.text = '123456789';
    _addressController.text = 'kiroty';
    _phoneController.text = '+224621820065';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez accepter les conditions générales')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Simulation d'une requête API (remplacez par votre logique réelle)
      await Future.delayed(const Duration(seconds: 2));

      Navigator.pushReplacementNamed(context, AppRoutes.home);
    //   final user = await UserRepository.createUser(
    //     User(
    //       first_name: _firstNameController.text,
    //       last_name: _lastNameController.text,
    //       phone_number: _phoneController.text,
    //       email: _emailController.text,
    //       password: _passwordController.text,
    //       address: _addressController.text,
    //     ),
    //   );
    //   if( user == null ) return;
    //   final saved = await UserPreferences.saveUser(user.toJson());
    //   if (saved) {
    //     print('Utilisateur sauvegardé avec succès');
    //     Navigator.pushReplacementNamed(context, AppRoutes.home);
    //   } else {
    //     print('Utilisateur non sauvegardé !');
    //   }
    // } on HttpException catch (e) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text(
    //         e.toString(),
    //         style: const TextStyle(color: Colors.white),
    //       ),
    //       backgroundColor: Colors.red[800],
    //       behavior: SnackBarBehavior.floating,
    //       shape: RoundedRectangleBorder(
    //         borderRadius: BorderRadius.circular(10),
    //       ),
    //       margin: const EdgeInsets.all(10),
    //       duration: const Duration(seconds: 3),
    //       action: SnackBarAction(
    //         label: 'OK',
    //         textColor: Colors.white,
    //         onPressed: () {
    //           ScaffoldMessenger.of(context).hideCurrentSnackBar();
    //         },
    //       ),
    //     ),
    //   );
    }  finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    colorScheme = theme.colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SingleChildScrollView(
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
                  child: Icon(
                    Icons.credit_card,
                    size: 50,
                    color: colorScheme.primary,
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
                        validator: (value) => value!.isEmpty ? 'Champ requis' : null,
                        decoration: _buildInputDecoration('Prénom', Icons.person),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        controller: _lastNameController,
                        validator: (value) => value!.isEmpty ? 'Champ requis' : null,
                        decoration: _buildInputDecoration('Nom', Icons.person),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _phoneController,
                  validator: (value) => value!.isEmpty ? 'Champ requis' : null,
                  keyboardType: TextInputType.phone,
                  decoration: _buildInputDecoration('Téléphone', Icons.phone),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _addressController,
                  validator: (value) => value!.isEmpty ? 'Champ requis' : null,
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
                  controller: _passwordController,
                  validator: (value) => value!.length < 6
                      ? '6 caractères minimum'
                      : null,
                  obscureText: true,
                  decoration: _buildInputDecoration('Mot de passe', Icons.lock),
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
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, [IconData? icon]) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon, color: colorScheme.primary) : null,
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
}
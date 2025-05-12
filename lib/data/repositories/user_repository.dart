import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gotransfer/data/models/user_model.dart';
import 'package:gotransfer/data/repositories/reference_repository.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/config/api_config.dart';
import '../../routes/app_routes.dart';
import '../../widgets/components/custom_scaffold.dart';
import '../../widgets/components/custom_toast.dart';
import '../models/reference_model.dart';
import '../models/role_model.dart';

class UserRepository {

  static final String USER = 'user';
  static final String ROLES = 'roles';
  static final String CURRENCY = 'currency';
  static final String COUNTRY = 'country';
  static final String PASSWORDHASHED = 'passwordHashed';
  static final String EMAIL = 'email';
  static final String CURReNTPAGe = 'currentPage';

  static Future<void> register(User user, File? image, BuildContext context, {bool isSavedSession = true}) async {
    try {
      // Prepare the request
      var response = await http.post(
        Uri.parse(ApiConfig.registerEndpoint),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'user': user.toJson(),
          'sender': {}
        }),
      );

      // Check the response status
      if (response.statusCode == 201) {
        Map<String, dynamic> succss = jsonDecode(response.body);
          await UserRepository.setUserEmail(user.email) && await UserRepository.setUserPasswordHashed(user.password);
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(
            content: Text('Utilisateur créé avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacementNamed(
          context, 
          AppRoutes.login,
          arguments: {
            'email': user.email,
            'password': user.password
          }
        );
      } else {
        Map<String, dynamic> errors = jsonDecode(response.body);
        print(errors);
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(
            content: Text(
              errors.containsKey('phone_number') ?
                  errors['phone_number'][0] :
                  errors.containsKey('email') ?
                      errors['email'][0]:
                      errors.containsKey('country')?
                          errors['country'][0] :
                      errors.containsKey('detail') ?
                          errors['detail'] :
                      'Erreur Interne'
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar(
          content: Text('Une erreur s\'est produite : $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  static Future<void> login(User user, BuildContext context, FToast fToast, {bool isSavedSession = true}) async {
    try {
      var response = await http.post(
          Uri.parse(ApiConfig.loginEndpoint),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(user.toJson())
      );

      if( response.statusCode == 200 ){
        fToast.showToast(
            child: CustomToast(
              message: 'Connexion Reussie !',
              textColor: Colors.white,
              backgroundColor: Colors.green,
            ),
            gravity: ToastGravity.TOP
        );
        Map<String, dynamic> success = jsonDecode(response.body);
        print(success['user']);
        bool result = await ReferenceRepository.setReferenceInSharedReference(
            Reference(
                id: 1,
                accessToken: success[ReferenceRepository.ACCESSTOKEN],
                refreshToken: success[ReferenceRepository.REFRESHTOKEN]
            )
        )
        && await UserRepository.setUserInSharedPreferences(User.fromJson(success[UserRepository.USER]))
        && await UserRepository.setRolesInSharedPreferences(success['user']['roles'])
        && await UserRepository.setCurrencyInSharedPreferences(success['user']['currency'])
        && await UserRepository.setCountryInSharedPreferences(success['user']['country'] ?? '');

        if( isSavedSession ){
          await UserRepository.setUserEmail(success[UserRepository.USER]['email']) && await UserRepository.setUserPasswordHashed(user.password);
        }
        String cp = (await UserRepository.getUserCurrentPage());
        if ( result ) Navigator.popAndPushNamed(context, cp.isEmpty ? AppRoutes.home : cp );
      }else {
        fToast.showToast(
            child: CustomToast(
              message: jsonDecode(response.body)['detail'],
              textColor: Colors.white,
              backgroundColor: Colors.red,
            ),
            gravity: ToastGravity.TOP
        );
      }
    }catch( e ){
      fToast.showToast(
          child: CustomToast(
            message: 'Erreur $e',
            textColor: Colors.white,
            backgroundColor: Colors.red,
          ),
          gravity: ToastGravity.TOP
      );
    }
  }

  static Future<User?> getUser(BuildContext context) async {
    try {
      // Récupérer le token une seule fois
      final accessToken = (await ReferenceRepository.getReferenceInSharedReference()).accessToken;

      if (accessToken.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
                content: Text('Token d\'accès non disponible'),
                backgroundColor: Colors.red
            )
        );
        return null;
      }

      var response = await http.get(
          Uri.parse(ApiConfig.getUserEndpoint),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $accessToken" // Utiliser la variable directement
          },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> success = jsonDecode(response.body);
        await UserRepository.setUserInSharedPreferences(User.fromJson(success));
        return User.fromJson(success);
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
                content: Text('Session expirée ou non autorisée'),
                backgroundColor: Colors.red
            )
        );
        // Ici vous pourriez déclencher une déconnexion ou un refresh token
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
                content: Text('Erreur serveur: ${response.statusCode}'),
                backgroundColor: Colors.red
            )
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(
              content: Text('Erreur: ${e.toString()}'),
              backgroundColor: Colors.red
          )
      );
    }
    return null;
  }

  static Future<bool> setUserInSharedPreferences(User user) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return await sharedPreferences.setString(USER, jsonEncode(user.toJson()));
  }

  static Future<User> getUserInSharedPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return User.fromJson(jsonDecode(await sharedPreferences.getString(USER) ?? '{}' ));
  }

  static Future<bool> setCurrencyInSharedPreferences(String currency) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return await sharedPreferences.setString(CURRENCY, currency);
  }

  static Future<String> getCurrencyInSharedPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return await sharedPreferences.getString(CURRENCY) ?? '';
  }

  static Future<bool> setCountryInSharedPreferences(String country) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return await sharedPreferences.setString(COUNTRY, country);
  }

  static Future<String> getCountryInSharedPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return await sharedPreferences.getString(COUNTRY) ?? '';
  }

  static Future<bool> setRolesInSharedPreferences(List<dynamic> roles) async {
    try {
      final sharedPreferences = await SharedPreferences.getInstance();
      return await sharedPreferences.setString(ROLES, jsonEncode(roles));
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde des rôles: $e');
      return false;
    }
  }

  static Future getRolesInSharedPreferences() async {
    try {
      final sharedPreferences = await SharedPreferences.getInstance();
      final rolesJsonString = sharedPreferences.getString(ROLES);

      if (rolesJsonString == null || rolesJsonString.isEmpty) {
        return []; // Retourne une liste vide si aucune donnée n'est sauvegardée
      }

      return jsonDecode(rolesJsonString);
    } catch (e) {
      debugPrint('Erreur lors de la récupération des rôles: $e');
      return {}; // Retourne une liste vide en cas d'erreur
    }
  }

  static Future<bool> setUserPasswordHashed(String passwordHashed) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return await sharedPreferences.setString(PASSWORDHASHED, passwordHashed);
  }

  static Future<String> getUserPasswordHashed() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return await sharedPreferences.getString(PASSWORDHASHED) ?? '';
  }

  static Future<bool> setUserEmail(String email) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return await sharedPreferences.setString(EMAIL, email);
  }

  static Future<String> getUserEmail() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return await sharedPreferences.getString(EMAIL) ?? '';
  }

  static Future<bool> setUserCurrentPage(String currentPage) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return await sharedPreferences.setString(CURReNTPAGe, '');
  }

  static Future<String> getUserCurrentPage() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return await sharedPreferences.getString(CURReNTPAGe) ?? '';
  }

  static Future<void> apiToken(BuildContext context, {String email = '', String password = ''}) async {
    try {
      var response = await http.post(
        Uri.parse(ApiConfig.apiTokenEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
          {
            'email': email.isEmpty ? (await getUserInSharedPreferences()).email : email,
            'password': password.isEmpty ? (await getUserInSharedPreferences()).password : password
          },
        ),
      ).timeout(const Duration(seconds: 10)); // ⏰ Maximum 10 secondes d'attente

      if (response.statusCode == 200) {
        Map<String, dynamic> success = jsonDecode(response.body);
        await ReferenceRepository.setReferenceInSharedReference(
          Reference(
            id: 1,
            accessToken: success[ReferenceRepository.ACCESSTOKEN],
            refreshToken: success[ReferenceRepository.REFRESHTOKEN],
          ),
        );
        String cp = (await UserRepository.getUserCurrentPage());
        await UserRepository.setUserCurrentPage('');
        Navigator.pushReplacementNamed(
          context, cp.isEmpty ? AppRoutes.login : cp
         );
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    } on TimeoutException catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar(content: Text('Erreur : Le serveur met trop de temps à répondre.'), backgroundColor: Colors.red),
      );
    } on http.ClientException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar(content: Text('Erreur de connexion : ${e.message}'), backgroundColor: Colors.red),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar(content: Text('Une erreur est survenue : $e'), backgroundColor: Colors.red),
      );
    }
  }

  static Future<void> apiTokenRefresh(BuildContext context) async {
    try{
      var refresh = (await ReferenceRepository.getReferenceInSharedReference()).refreshToken;
      var response = await http.post(
          Uri.parse(ApiConfig.apiTokenRefreshEndpoint),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(
              {
                ReferenceRepository.REFRESHTOKEN: refresh
              }
          )
      );

      if( response.statusCode == 200 ){
        Map<String, dynamic> success = jsonDecode(response.body);
        await ReferenceRepository.setReferenceInSharedReference(
            Reference(
                id: 1,
                accessToken: success[ReferenceRepository.ACCESSTOKEN],
                refreshToken: refresh
            )
        );
      }else {
        ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(content: Text('Erreur : ${response.body}'), backgroundColor: Colors.red)
        );
      }
    }catch( e ) {
      ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red)
      );
    }
  }
}
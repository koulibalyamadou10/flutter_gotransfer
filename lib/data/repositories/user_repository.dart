import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gotransfer/data/models/user_model.dart';
import 'package:gotransfer/data/repositories/reference_repository.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/api_config.dart';
import '../../routes/app_routes.dart';
import '../../widgets/components/custom_scaffold.dart';
import '../models/reference_model.dart';

class UserRepository {

  static final String USER = 'user';
  static final String PASSWORDHASHED = 'passwordHashed';
  static final String EMAIL = 'email';

  /// Author : koulibaly amadou
  /// Email  : koulibalyamadou10@gmail.com
  /// Desc   : Cette fonction permet de creer un utilisateur avec une image
  static Future<void> register(User user, File? image, BuildContext context,) async {
    try {
      // Prepare the request
      var request = http.MultipartRequest('POST', Uri.parse(ApiConfig.registerEndpoint))
        ..fields['first_name'] = user.first_name
        ..fields['last_name'] = user.last_name
        ..fields['email'] = user.email
        ..fields['phone_number'] = user.phone_number
        ..fields['address'] = user.address
        ..fields['commission'] = '${user.commission}'
        ..fields['password'] = user.password;

      final response = await request.send();

      // Check the response status
      if (response.statusCode == 201) {
        Map<String, dynamic> succss = jsonDecode(await response.stream.bytesToString());
        UserRepository.setUserEmail(succss['email']);
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(
            content: Text('Utilisateur créé avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        Map<String, dynamic> errors = jsonDecode(await response.stream.bytesToString());
        print(errors);
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(
            content: Text(
              errors.containsKey('phone_number') ?
                  errors['phone_number'][0] :
                  errors.containsKey('email') ?
                      errors['email'][0]:
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

  /// Author : koulibaly amadou
  /// Email  : koulibalyamadou10@gmail.com
  /// Desc  : Cette fonction permet de connecter un utilisateur avec un mail et un password
  static Future<void> login(User user, BuildContext context) async {
    try {
      var response = await http.post(
          Uri.parse(ApiConfig.loginEndpoint),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(user.toJson())
      );

      if( response.statusCode == 200 ){
        ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(content: Text('Connexion Reussie !'), backgroundColor: Colors.green )
        );
        Map<String, dynamic> success = jsonDecode(response.body);
        print(success);
        bool result = await ReferenceRepository.setReferenceInSharedReference(
            Reference(
                id: 1,
                accessToken: success[ReferenceRepository.ACCESSTOKEN],
                refreshToken: success[ReferenceRepository.REFRESHTOKEN]
            )
        ) && await UserRepository.setUserInSharedPreferences(User.fromJson(success[UserRepository.USER]))
            && await UserRepository.setUserEmail(success[UserRepository.USER]['email'])
            && await UserRepository.setUserPasswordHashed(user.password);
        if ( result ) Navigator.popAndPushNamed(context, AppRoutes.home );
      }else {
        ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(content: Text(
                jsonDecode(response.body)['detail']
            ), backgroundColor: Colors.red)
        );
      }
    }catch( e ){
      ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(content: Text('Erreur $e'), backgroundColor: Colors.red)
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
        print(success);
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

  /// Author : koulibaly amadou
  /// Email  : koulibalyamadou10@gmail.com
  /// Desc   : Cette fonction permet de stocker l'utilisateur dans le sharedpreferences
  static Future<bool> setUserInSharedPreferences(User user) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return await sharedPreferences.setString(USER, jsonEncode(user.toJson()));
  }

  /// Author : koulibaly amadou
  /// Email  : koulibalyamadou10@gmail.com
  /// Desc   : Cette fonction permet de recuperer le user stocké dans le sharedpreferences
  static Future<User> getUserInSharedPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return User.fromJson(jsonDecode(await sharedPreferences.getString(USER) ?? '{}' ));
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

  static Future<void> apiToken(BuildContext context, {String email = '', String password = ''}) async {
    try{
      var response = await http.post(
          Uri.parse(ApiConfig.apiTokenEndpoint),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(
              {
                'email': email.isEmpty ? (await getUserInSharedPreferences()).email : email,
                'password': password.isEmpty ? (await getUserInSharedPreferences()).password : password
              }
          )
      );

      if( response.statusCode == 200 ){
        Map<String, dynamic> success = jsonDecode(response.body);
        await ReferenceRepository.setReferenceInSharedReference(
            Reference(
                id: 1,
                accessToken: success[ReferenceRepository.ACCESSTOKEN],
                refreshToken: success[ReferenceRepository.REFRESHTOKEN]
            )
        );
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }else {
        // ScaffoldMessenger.of(context).showSnackBar(
        //     CustomSnackBar(content: Text('Erreur : ${response.body}'), backgroundColor: Colors.red)
        // );
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    }catch( e ) {
      ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red)
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
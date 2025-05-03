import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gotransfer/data/models/beneficiary_model.dart';
import 'package:gotransfer/data/models/user_model.dart';
import 'package:gotransfer/data/repositories/reference_repository.dart';
import 'package:gotransfer/data/repositories/user_repository.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/api_config.dart';
import '../../routes/app_routes.dart';
import '../../widgets/components/custom_scaffold.dart';
import '../models/reference_model.dart';

class DestinataireRepository {

  static final String USER = 'user';
  static final String PASSWORDHASHED = 'passwordHashed';
  static final String EMAIL = 'email';

  static Future<bool> create(Destinataire destinataire, BuildContext context) async {
    // Récupérer le token une seule fois
    final accessToken = (await ReferenceRepository.getReferenceInSharedReference()).accessToken;
    try {
      var response = await http.post(
          Uri.parse(ApiConfig.addDestinataireEndpoint),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $accessToken" // Utiliser la variable directement
          },
          body: jsonEncode(destinataire.toJson())
      );

      if(response.statusCode == 201 ) {
        Map<String, dynamic> success = jsonDecode(response.body);
        print(success);
        User user = await UserRepository.getUserInSharedPreferences();
        user.destinataires.add(Destinataire.fromJson(success));
        await UserRepository.setUserInSharedPreferences(user);
        ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(content: Text(
                'Beneficiaire crée !'
            ), backgroundColor: Colors.green)
        );
        return true;
      }else if(response.statusCode == 401 ) {
        Map<String, dynamic> errors = jsonDecode(response.body);
        print(errors);
        ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(content: Text(
                'Votre session a expiré !'
            ), backgroundColor: Colors.red)
        );
        await UserRepository.setUserCurrentPage(AppRoutes.quick_transfer);
        Navigator.pushNamed(context, AppRoutes.login);
      }else if(response.statusCode == 400 ) {
        Map<String, dynamic> errors = jsonDecode(response.body);
        print(errors);
        ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(content: Text(
                errors.containsKey('detail') ? errors['detail'] :
                errors.containsKey('phone_number') ? errors['phone_number'][0] :
                'Une erreur est survenue !'
            ), backgroundColor: Colors.red)
        );
      }else {
        Map<String, dynamic> errors = jsonDecode(response.body);
        print(errors);
        ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(content: Text(
                'Veuiller ressayer plus tard !'
            ), backgroundColor: Colors.red)
        );
      }
    }catch( e ){
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(content: Text('Erreur $e'), backgroundColor: Colors.red)
      );
    }
    return false;
  }

  static Future<Destinataire?> getCountryCodByPhoneNumber(String phoneNumber, BuildContext context) async {
    final accessToken = (await ReferenceRepository.getReferenceInSharedReference()).accessToken;
    try {
      var response = await http.post(
          Uri.parse(ApiConfig.getCountryCodeEndpoint),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $accessToken" // Utiliser la variable directement
          },
          body: jsonEncode({
            'phone_number': phoneNumber,
          })
      );

      if(response.statusCode == 200 ) {
        Map<String, dynamic> success = jsonDecode(response.body);
        return Destinataire.fromJson(success);
      }else if(response.statusCode == 400 ) {
        Map<String, dynamic> errors = jsonDecode(response.body);
        print(errors);
        ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(content: Text(
                errors.containsKey('detail') ? errors['detail'] :
                errors.containsKey('phone_number') ? errors['phone_number'][0] :
                'Une erreur est survenue !'
            ), backgroundColor: Colors.red)
        );
      }else if(response.statusCode == 401 ) {
        Map<String, dynamic> errors = jsonDecode(response.body);
        print(errors);
        ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(content: Text(
                'Votre session a expiré !'
            ), backgroundColor: Colors.red)
        );
        Navigator.pushNamed(context, AppRoutes.login);
      }else if(response.statusCode == 404 ) {
        Map<String, dynamic> errors = jsonDecode(response.body);
        print(errors);
        ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(content: Text(
                errors.containsKey('detail') ? errors['detail'] :
                'Une erreur est survenue !'
            ), backgroundColor: Colors.red)
        );
      }else {
        Map<String, dynamic> errors = jsonDecode(response.body);
        print(errors);
        ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(content: Text(
                'Veuiller ressayer plus tard !'
            ), backgroundColor: Colors.red)
        );
      }
    }catch( e ){
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(content: Text('Erreur $e'), backgroundColor: Colors.red)
      );
    }
    return null;
  }

  static Future<Map<String, dynamic>?> getXRate(String phoneNumber, String srcCurrency, String dstCurrency, String srcCountry, String dstCountry, double amount, BuildContext context) async {
    final accessToken = (await ReferenceRepository.getReferenceInSharedReference()).accessToken;
    try {
      var response = await http.post(
          Uri.parse(ApiConfig.getXRateEndpoint),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $accessToken" // Utiliser la variable directement
          },
          body: jsonEncode({
            'phone_number': phoneNumber,
            'src_currency': srcCurrency,
            'dst_currency': dstCurrency,
            'src_country': srcCountry,
            'dst_country': dstCountry,
            'amount': amount
          })
      );

      if(response.statusCode == 200 ) {
        Map<String, dynamic> success = jsonDecode(response.body);
        return success;
      }else if(response.statusCode == 400 ) {
        Map<String, dynamic> errors = jsonDecode(response.body);
        print(errors);
        ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(content: Text(
                errors.containsKey('detail') ? errors['detail'] :
                errors.containsKey('phone_number') ? errors['phone_number'][0] :
                'Une erreur est survenue !'
            ), backgroundColor: Colors.red)
        );
      }else if(response.statusCode == 401 ) {
        Map<String, dynamic> errors = jsonDecode(response.body);
        print(errors);
        ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(content: Text(
                'Votre session a expiré !'
            ), backgroundColor: Colors.red)
        );
        Navigator.pushNamed(context, AppRoutes.login);
      }else if(response.statusCode == 404 ) {
        Map<String, dynamic> errors = jsonDecode(response.body);
        print(errors);
        ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(content: Text(
                errors.containsKey('detail') ? errors['detail'] :
                'Une erreur est survenue !'
            ), backgroundColor: Colors.red)
        );
      }else {
        Map<String, dynamic> errors = jsonDecode(response.body);
        print(errors);
        ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(content: Text(
                'Veuiller ressayer plus tard !'
            ), backgroundColor: Colors.red)
        );
      }
    }catch( e ){
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(content: Text('Erreur $e'), backgroundColor: Colors.red)
      );
    }
    return null;
  }
}
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gotransfer/core/utils/helpers.dart';
import 'package:gotransfer/data/repositories/user_repository.dart';
import 'package:gotransfer/widgets/components/custom_toast.dart';
import 'package:http/http.dart' as http;

import '../../core/config/api_config.dart';
import '../../routes/app_routes.dart';
import '../../widgets/components/custom_scaffold.dart';
import '../models/role_model.dart';
import '../repositories/reference_repository.dart';

class RoleRepository {

  static Future<bool> create(Role role, BuildContext context, FToast fToast) async {
    try {
      final accessToken = (await ReferenceRepository
          .getReferenceInSharedReference()).accessToken;

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/beneficiary/register/'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken"
        },
        body: jsonEncode(role.toJson()),
        encoding: Encoding.getByName('utf-8')
      );


      Map<String, dynamic> decodedResponse = Helpers.decodeResponse(response);
      if ( response.statusCode == 201 ){
        fToast.showToast(
            child: CustomToast(
              message: 'Beneficiaire inscrit',
              backgroundColor: Colors.green,
            ),
            gravity: ToastGravity.TOP
        );
        final List<dynamic> roles = await UserRepository.getRolesInSharedPreferences();
        roles.add(decodedResponse);
        await UserRepository.setRolesInSharedPreferences(roles);
        Navigator.pop(context);
        return true;
      } else if ( response.statusCode == 400 ) {
        fToast.showToast(
            child: CustomToast(
              message: decodedResponse['detail'] ?? '',
              backgroundColor: Colors.red,
            ),
            gravity: ToastGravity.TOP
        );
      }else if ( response.statusCode == 401 ) {
        fToast.showToast(
            child: CustomToast(
              message: 'votre session a expiré !',
              backgroundColor: Colors.red,
            ),
            gravity: ToastGravity.TOP
        );
      }
    }catch(e){

    }
    return false;
  }

  static Future<Role?> getCountryCodByPhoneNumber(String phoneNumber, BuildContext context) async {
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
        return Role.fromJson(success);
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

  static Future<Map<String, dynamic>?> getXRate(String phoneNumber,
      String srcCurrency,
      String dstCurrency,
      String srcCountry,
      String dstCountry,
      double amount,
      String direction,
      BuildContext context,
      FToast fToast) async {
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
            'amount': amount,
            'direction': direction
          })
      );

      Map<String, dynamic> decodedResponse = Helpers.decodeResponse(response);
      if(response.statusCode == 200 ) {
        Map<String, dynamic> success = decodedResponse;
        return success;
      }else if(response.statusCode == 400 ) {
        Map<String, dynamic> errors = decodedResponse;
        fToast.showToast(
            child: CustomToast(
              message: errors.containsKey('detail') ? errors['detail'] :
              errors.containsKey('phone_number') ? errors['phone_number'][0] :
              'Une erreur est survenue !',
              backgroundColor: Colors.red,
            ),
            gravity: ToastGravity.TOP
        );
      }else if(response.statusCode == 401 ) {
        Map<String, dynamic> errors = decodedResponse;
        fToast.showToast(
            child: CustomToast(
              message: 'Votre session a expiré !',
              backgroundColor: Colors.red
            ),
            gravity: ToastGravity.TOP
        );
        Navigator.pushNamed(context, AppRoutes.login);
      }else if(response.statusCode == 404 ) {
        Map<String, dynamic> errors = decodedResponse;
        fToast.showToast(
            child: CustomToast(
              message: errors.containsKey('detail') ? errors['detail'] :
              'Une erreur est survenue !',
              backgroundColor: Colors.red
            ),
            gravity: ToastGravity.TOP
        );
      }else {
        Map<String, dynamic> errors = decodedResponse;
        fToast.showToast(
            child: CustomToast(
              message: 'Veuiller ressayer plus tard !',
              backgroundColor: Colors.red
            ),
            gravity: ToastGravity.TOP
        );
      }
    }catch( e ){
      fToast.showToast(
          child: CustomToast(
            message: 'Erreur $e',
            backgroundColor: Colors.red
          ),
          gravity: ToastGravity.TOP
      );
    }
    return null;
  }
}

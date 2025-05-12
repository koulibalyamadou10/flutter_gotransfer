import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gotransfer/data/models/topup_model.dart';
import 'package:gotransfer/data/repositories/reference_repository.dart';
import 'package:gotransfer/data/repositories/user_repository.dart';
import 'package:gotransfer/widgets/components/custom_toast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config/api_config.dart';
import '../../routes/app_routes.dart';
import '../../widgets/components/custom_scaffold.dart';
import '../models/user_model.dart';

class TopupRepository {
  // Créer une nouvelle recharge
  static Future<bool> create(int productId, double amount, String phoneNumber, BuildContext context, FToast fToast) async {
    final accessToken = (await ReferenceRepository.getReferenceInSharedReference()).accessToken;
    try {
      var response = await http.post(
        Uri.parse(ApiConfig.addTopupEndpoint),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken"
        },
        body: jsonEncode({
          'product_id': productId,
          'price': amount,
          'phone_number': phoneNumber
        }),
      );

      if (response.statusCode == 201) {
        Map<String, dynamic> success = jsonDecode(response.body);
        print('Recharge créée avec succès: $success');
        fToast.showToast(
          child: CustomSnackBar(
            content: Text(
              'Recharge créée avec succès'
            ),
            backgroundColor: Colors.green,
          ),
            toastDuration: Duration(seconds: 3),
          gravity: ToastGravity.TOP
        );
        // Mise à jour de l'utilisateur si nécessaire
        User user = await UserRepository.getUserInSharedPreferences();
        return true;
      } else if( response.statusCode == 400) {
        Map<String, dynamic> errors = jsonDecode(response.body);
        print('Erreur 400: $errors');
        fToast.showToast(
          child: CustomToast(
            message: (
              errors.containsKey('detail') ?
              errors['detail'] :
              'Une erreur est survenue lors de la création de la recharge.'
            ),
            backgroundColor: Colors.red,
          ),
            toastDuration: Duration(seconds: 3),
          gravity: ToastGravity.TOP
        );
      } else if( response.statusCode == 401) {
        Map<String, dynamic> errors = jsonDecode(response.body);
        fToast.showToast(
          child: CustomToast(
            message: (
              'Votre session a expiré. Veuillez vous reconnecter.'
            ),
            backgroundColor: Colors.red,

          ),
          toastDuration: Duration(seconds: 3),
          gravity: ToastGravity.TOP,
        );
        Navigator.popAndPushNamed(context, AppRoutes.login );
      }
    } catch (e) {
      print('Exception lors de la création de la recharge: $e');
    }
    return false;
  }

  // Récupérer la liste des produits disponibles
  static Future<List<dynamic>?> getAvailableProducts(Map<String, dynamic> data, BuildContext context) async {
    final accessToken = (await ReferenceRepository.getReferenceInSharedReference()).accessToken;
    try {
      var response = await http.post(
        Uri.parse(ApiConfig.listProductTopupEndpoint),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken"
        },
        body: jsonEncode(data)
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if( response.statusCode == 400) {
        Map<String, dynamic> errors = jsonDecode(response.body);
        print('Erreur 400: $errors');
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(
            content: Text(
              errors.containsKey('detail')? errors['detail'] : 'Une erreur est survenue lors de la récupération des produits.'
            ),
            backgroundColor: Colors.red,
          ),
        );
        print('Erreur lors de la récupération des produits: ${response.body}');
      } else if( response.statusCode == 401) {
        Map<String, dynamic> errors = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(
            content: Text(
              'Votre session a expiré. Veuillez vous reconnecter.'
            ),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.popAndPushNamed(context, AppRoutes.login );
      }
    } catch (e) {
      print('Exception lors de la récupération des produits: $e');
    }
    return null;
  }
}
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gotransfer/data/models/topup_model.dart';
import 'package:gotransfer/data/repositories/reference_repository.dart';
import 'package:gotransfer/data/repositories/user_repository.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/api_config.dart';
import '../../routes/app_routes.dart';
import '../../widgets/components/custom_scaffold.dart';
import '../models/user_model.dart';

class TopupRepository {
  // Créer une nouvelle recharge
  static Future<bool> create(Topup topup, BuildContext context) async {
    final accessToken = (await ReferenceRepository.getReferenceInSharedReference()).accessToken;
    try {
      var response = await http.post(
        Uri.parse(ApiConfig.addTopupEndpoint),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken"
        },
        body: jsonEncode(topup.toJson()),
      );

      if (response.statusCode == 201) {
        Map<String, dynamic> success = jsonDecode(response.body);
        print('Recharge créée avec succès: $success');

        // Mise à jour de l'utilisateur si nécessaire
        User user = await UserRepository.getUserInSharedPreferences();
        return true;
      } else if( response.statusCode == 400) {
        Map<String, dynamic> errors = jsonDecode(response.body);
        print('Erreur 400: $errors');
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(
            content: Text(
              errors.containsKey('detail') ? errors['detail'] : 'Une erreur est survenue lors de la création de la recharge.'
            ),
            backgroundColor: Colors.red,
          ),
        );
        print('Erreur lors de la création de la recharge: ${response.body}');
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
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gotransfer/data/models/remittance_model.dart'; // Ton modèle Remittance
import 'package:gotransfer/data/repositories/reference_repository.dart';
import 'package:gotransfer/data/repositories/user_repository.dart';
import 'package:http/http.dart' as http;
import '../../core/config/api_config.dart';
import '../../routes/app_routes.dart';
import '../../widgets/components/custom_scaffold.dart';
import '../models/user_model.dart';

class RemittanceRepository {

  static Future<bool> create(Remittance remittance, BuildContext context) async {
    final accessToken = (await ReferenceRepository.getReferenceInSharedReference()).accessToken;
    try {
      var response = await http.post(
        Uri.parse(ApiConfig.addRemittanceEndpoint), // <-- n'oublie pas de définir cette URL dans ApiConfig
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken"
        },
        body: jsonEncode(remittance.toJson()),
      );

      if (response.statusCode == 201) {
        Map<String, dynamic> success = jsonDecode(response.body);
        print('Remittance créée avec succès: $success');

        // Mise à jour de l'utilisateur si besoin
        User user = await UserRepository.getUserInSharedPreferences();
        // Exemple si tu veux stocker les remittances : user.remittances.add(Remittance.fromJson(success));
        // await UserRepository.setUserInSharedPreferences(user);

        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(
            content: Text('Transactions créée avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        return true;

      } else if (response.statusCode == 401) {
        Map<String, dynamic> errors = jsonDecode(response.body);
        print('Erreur 401: $errors');
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(
            content: Text('Votre session a expiré. Veuillez vous reconnecter.'),
            backgroundColor: Colors.red,
          ),
        );
        await UserRepository.setUserCurrentPage(AppRoutes.quick_transfer);
        Navigator.pushNamed(context, AppRoutes.login);

      } else if (response.statusCode == 400) {
        Map<String, dynamic> errors = jsonDecode(response.body);
        print('Erreur 400: $errors');
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(
            content: Text(
              errors.containsKey('detail') ? errors['detail'] : 'Erreur de saisie !',
            ),
            backgroundColor: Colors.red,
          ),
        );

      } else {
        Map<String, dynamic> errors = jsonDecode(response.body);
        print('Erreur serveur: $errors');
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(
            content: Text('Veuillez réessayer plus tard.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar(
          content: Text('Erreur : $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
    return false;
  }
}

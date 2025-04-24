import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gotransfer/data/models/beneficiary_model.dart';
import 'package:gotransfer/data/models/user_model.dart';
import 'package:gotransfer/data/repositories/reference_repository.dart';
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

      if( response.statusCode == 200 ){
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(content: Text('Destinataire Reussie !'), backgroundColor: Colors.green )
        );
        return true;
      }else {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(content: Text(
            'Votre session a expiré !'
          ), backgroundColor: Colors.red)
        );
      }
    }catch( e ){
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar(content: Text('Erreur $e'), backgroundColor: Colors.red)
      );
    }
    return false;
  }
}
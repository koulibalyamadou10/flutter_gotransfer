import 'dart:convert';
import 'package:gotransfer/config/api_config.dart';
import 'package:http/http.dart' as http;

import '../models/sender_model.dart';

class SenderRepository {

  // Fetch la liste des senders
  Future<List<Sender>> fetchSenders() async {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/senders/'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Sender.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors du chargement des senders: ${response.statusCode}');
    }
  }

  // Récupérer un sender par UUID
  Future<Sender> fetchSenderByUuid(String uuid) async {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/senders/'));

    if (response.statusCode == 200) {
      return Sender.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Sender non trouvé: ${response.statusCode}');
    }
  }

  // Créer un nouveau sender
  Future<Sender> createSender(Sender sender) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/senders/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(sender.toJson()),
    );

    if (response.statusCode == 201) {
      return Sender.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur lors de la création: ${response.statusCode}');
    }
  }

  // Mettre à jour un sender existant
  Future<Sender> updateSender(String uuid, Sender sender) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/senders/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(sender.toJson()),
    );

    if (response.statusCode == 200) {
      return Sender.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur lors de la mise à jour: ${response.statusCode}');
    }
  }

  // Supprimer un sender
  Future<void> deleteSender(String uuid) async {
    final response = await http.delete(Uri.parse('${ApiConfig.baseUrl}/senders/'));

    if (response.statusCode != 204) {
      throw Exception('Erreur lors de la suppression: ${response.statusCode}');
    }
  }
}

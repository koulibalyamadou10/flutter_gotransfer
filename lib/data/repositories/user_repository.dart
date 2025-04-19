import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:gotransfer/config/api_config.dart';
import '../../exceptions/badrequest_exception.dart';
import '../../exceptions/notfound_exception.dart';
import '../../exceptions/server_exception.dart';
import '../../exceptions/unauthorized_exception.dart';
import '../models/user_model.dart';

class UserRepository {
  static String baseUrl = "${ApiConfig.protocol}://${ApiConfig.host}${ApiConfig.port}/";

  Future<User?> userById(int id) async {
    final response = await http.get(Uri.parse('${baseUrl}users/$id/'));

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      return null;
    }
  }

  static Future<User?> createUser(User user) async {
    try {
      final http.Response response = await http.post(
        Uri.parse('${baseUrl}account/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode == 201) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        // Lancez des exceptions spécifiques selon le code de statut
        switch (response.statusCode) {
          case 400:
            {
              Map<String, dynamic> errors = jsonDecode(response.body);
              if ( errors.containsKey('email') ) {
                throw BadRequestException(errors['email'][0]);
              }
            }
          case 401:
            throw UnauthorizedException('Non autorisé !');
          case 404:
            throw NotFoundException('Non trouvé !');
          case 500:
            throw ServerException('Erreur interne !');
          default:
            throw HttpException('Erreur HTTP ${response.statusCode}');
        }
      }
    } on FormatException catch (_) {
      throw const FormatException('Format de réponse invalide du serveur');
    } on SocketException {
      throw const SocketException('Pas de connexion internet');
    } on http.ClientException catch (e) {
      throw HttpException('Erreur lors de la requête: ${e.message}');
    }
  }

  static Future<User?> loginUser(Map<String, dynamic> credentials) async {
      try {
        final http.Response response = await http.post(
          Uri.parse('${baseUrl}account/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(credentials),
        );

        if (response.statusCode == 201) {
          return User.fromJson(jsonDecode(response.body));
        } else {
          switch (response.statusCode) {
            case 400:
              {
                Map<String, dynamic> errors = jsonDecode(response.body);
                if ( errors.containsKey('email') ) {
                  throw BadRequestException(errors['email'][0]);
                }
              }
            case 401:
              throw UnauthorizedException('Non autorisé !');
            case 404:
              throw NotFoundException('Non trouvé !');
            case 500:
              throw ServerException('Erreur interne !');
            default:
              throw HttpException('Erreur HTTP ${response.statusCode}');
          }
        }
      } on FormatException catch (_) {
        throw const FormatException('Format de réponse invalide du serveur');
      } on SocketException {
        throw const SocketException('Pas de connexion internet');
      } on http.ClientException catch (e) {
        throw HttpException('Erreur lors de la requête: ${e.message}');
      }
    }
}

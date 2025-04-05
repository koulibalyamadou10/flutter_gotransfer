import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static const String _keyUserData = 'user_data';
  static const String _keyFirstName = 'first_name';
  static const String _keyLastName = 'last_name';
  static const String _keyEmail = 'email';
  static const String _keyPhone = 'phone_number';
  static const String _keyAddress = 'address';
  static const String _keyIsLoggedIn = 'is_logged_in';

  // Sauvegarder toutes les infos utilisateur
  static Future<bool> saveUser(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      return await prefs.setString(_keyUserData, jsonEncode(userData)) &&
          await prefs.setString(_keyFirstName, userData['first_name'] ?? '') &&
          await prefs.setString(_keyLastName, userData['last_name'] ?? '') &&
          await prefs.setString(_keyEmail, userData['email'] ?? '') &&
          await prefs.setString(_keyPhone, userData['phone_number'] ?? '') &&
          await prefs.setString(_keyAddress, userData['address'] ?? '') &&
          await prefs.setBool(_keyIsLoggedIn, true);
    } catch (e) {
      debugPrint('Erreur sauvegarde utilisateur: $e');
      return false;
    }
  }

  // Récupérer toutes les infos utilisateur
  static Future<Map<String, dynamic>?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_keyUserData);

      if (userJson != null) {
        return jsonDecode(userJson);
      }

      // Fallback pour les anciennes versions
      return {
        'first_name': prefs.getString(_keyFirstName),
        'last_name': prefs.getString(_keyLastName),
        'email': prefs.getString(_keyEmail),
        'phone_number': prefs.getString(_keyPhone),
        'address': prefs.getString(_keyAddress),
      };
    } catch (e) {
      debugPrint('Erreur récupération utilisateur: $e');
      return null;
    }
  }

  // Vérifier si l'utilisateur est connecté
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // Déconnexion (supprimer les données)
  static Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_keyUserData) &&
          await prefs.remove(_keyFirstName) &&
          await prefs.remove(_keyLastName) &&
          await prefs.remove(_keyEmail) &&
          await prefs.remove(_keyPhone) &&
          await prefs.remove(_keyAddress) &&
          await prefs.setBool(_keyIsLoggedIn, false);
    } catch (e) {
      debugPrint('Erreur déconnexion: $e');
      return false;
    }
  }
}
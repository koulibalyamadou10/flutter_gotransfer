import 'package:sqflite/sqflite.dart';

import '../../main.dart';

class Reference {
  int id;
  String refreshToken;
  String accessToken;

  Reference({required this.id, required this.accessToken, required this.refreshToken});

  Map<String, dynamic> toJson(){
    return {
      'id': id,
      'refresh_token': refreshToken,
      'access_token': accessToken
    };
  }

  static Future<void> create(Reference reference) async {
    // Get a reference to the database.
    final db = await database;

    // Insert the Dog into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same dog is inserted twice.
    //
    // In this case, replace any previous data.
    await db.insert(
      'reference',
      reference.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // A method that retrieves all the dogs from the dogs table.
  Future<List<Reference>> getAll() async {
    // Get a reference to the database.
    final db = await database;

    // Query the table for all the dogs.
    final List<Map<String, Object?>> dogMaps = await db.query('reference');

    // Convert the list of each dog's fields into a list of `Dog` objects.
    return [
      for (final {'id': id as int, 'accessToken': accessToken as String, 'refreshToken': refreshToken as String} in dogMaps) Reference(id: id, accessToken: accessToken, refreshToken: refreshToken),
    ];
  }

  Future<void> update(Reference reference) async {
    // Get a reference to the database.
    final db = await database;

    // Update the given Dog.
    await db.update(
      'reference',
      reference.toJson(),
      // Ensure that the Dog has a matching id.
      where: 'id = ?',
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [reference.id],
    );
  }

  Future<void> delete(int id) async {
    // Get a reference to the database.
    final db = await database;

    // Remove the Dog from the database.
    await db.delete(
      'reference',
      // Use a `where` clause to delete a specific dog.
      where: 'id = ?',
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }

  @override
  String toString() {
    return "Reference{id: $id, refreshToken: $refreshToken, accessToken: $accessToken}";
  }
}
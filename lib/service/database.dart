import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../model/usuario.dart';

class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await initDB();
    return _database!;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'database.db');

    return await openDatabase(path, version: 1, onCreate: (Database db, int version) async {
      await db.execute(
          "CREATE TABLE Usuario ("
              "id INTEGER PRIMARY KEY,"
              "nome TEXT,"
              "senha TEXT,"
              "pontuacaoDataJSON TEXT,"
              "logged INTEGER"
              ")");

    });
  }

  Future<int> novoUsuario(Usuario usuario) async {
    final db = await database;
    try {
      int id = await db.insert('Usuario', usuario.toJsonDB(),
          conflictAlgorithm: ConflictAlgorithm.ignore);
      return id;
    } catch (e) {
      print('Error inserting Usuario: $e');
      return -1; // Return an error code or handle the error accordingly
    }
  }

  Future<Usuario?> getUsuarioLogged() async {
    final db = await database;
    var res = await db.query("Usuario", limit: 1, where: "logged = 1");
    return res.isNotEmpty ? Usuario.fromJson(res.first) : null;
  }

  Future<Usuario?> getUsuarioByName(String nome) async {
    final db = await database;
    var res = await db.query("Usuario", where: "nome = ?", whereArgs: [nome]);
    return res.isNotEmpty ? Usuario.fromJson(res.first) : null;
  }

  Future<int> updateUsuario(Usuario usuario) async {
    final db = await database;
    var res = await db.update("Usuario", usuario.toJsonDB(),
        where: "nome = ?", whereArgs: [usuario.nome]);
    return res;
  }

  Future<int> deleteUsuario() async {
    final db = await database;
    var res = await db.rawDelete("DELETE FROM Usuario");
    return res;
  }

}

// import 'dart:io';
//
// import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';
//
// class DBProvider {
//   DBProvider._();
//   static final DBProvider db = DBProvider._();
//
//   static Database? _database;
//
//   Future<Database> get database async {
//     if (_database != null) {
//       return _database!;
//     }
//
//     _database = await initDB();
//     return _database!;
//   }
//
//   initDB() async {
//
//     Directory documentsDirectory = await getApplicationDocumentsDirectory();
//
//     String? path = join(documentsDirectory.path, "${AppStrings.nomeEmpresa}.db");
//
//     return await openDatabase(path, version: 12,
//
//         onCreate: (Database db, int? version) async {
//
//           await createDb(db, 0, version);
//
//         },
//
//         onUpgrade: (Database db, int? oldVersion, int? newVersion) async {
//
//           await createDb(db, oldVersion, newVersion);
//
//         }
//
//     );
//
//   }
//
//   createDb(Database db, int? oldVersion, int? newVersion) async {
//
//     int? currentVersion = (oldVersion! + 1);
//
//     while (currentVersion! <= newVersion!) {
//
//       switch (currentVersion) {
//
//         case 1: {
//
//           await db.execute(
//               "CREATE TABLE Usuario ("
//                   "id INTEGER PRIMARY KEY,"
//                   "guidUsuario INTEGER,"
//                   "nome TEXT,"
//                   "email TEXT,"
//                   "senha TEXT,"
//                   "telefone TEXT,"
//                   "dataNascimento TEXT,"
//                   "firebaseToken TEXT,"
//                   "token TEXT"
//                   ")"
//           );
//
//         } break;
//
//         case 2: {
//
//           await db.execute(
//               "ALTER TABLE Usuario ADD foto TEXT;"
//           );
//
//         } break;
//
//         case 3: {
//
//           await db.execute(
//               "ALTER TABLE Usuario ADD rua TEXT;"
//           );
//
//         } break;
//
//         case 4: {
//
//           await db.execute(
//               "ALTER TABLE Usuario ADD numero TEXT;"
//           );
//
//         } break;
//
//         case 5: {
//
//           await db.execute(
//               "ALTER TABLE Usuario ADD cep TEXT;"
//           );
//
//         } break;
//
//         case 6: {
//
//           await db.execute(
//               "ALTER TABLE Usuario ADD bairro TEXT;"
//           );
//
//         } break;
//
//         case 7: {
//
//           await db.execute(
//               "ALTER TABLE Usuario ADD cidade TEXT;"
//           );
//
//         } break;
//
//         case 8: {
//
//           await db.execute(
//               "ALTER TABLE Usuario ADD uf TEXT;"
//           );
//
//         } break;
//
//         case 9: {
//
//           await db.execute(
//               "ALTER TABLE Usuario ADD cpf TEXT;"
//           );
//
//         } break;
//
//         case 10: {
//
//           await db.execute(
//               "ALTER TABLE Usuario ADD cnpj TEXT;"
//           );
//
//         } break;
//
//         case 11: {
//
//           await db.execute(
//               "ALTER TABLE Usuario ADD genero TEXT;"
//           );
//
//         } break;
//
//         case 12: {
//
//           await db.execute(
//               "ALTER TABLE Usuario ADD nomeloja TEXT;"
//           );
//
//         } break;
//
//         default: { }
//
//       }
//
//       currentVersion++;
//
//     }
//
//   }
//
//   novoUsuario(Usuario usuario) async {
//     final db = await database;
//     var res = await db.insert("Usuario", usuario.toJsonDB());
//     return res;
//   }
//
//   getUsuario() async {
//     final db = await database;
//     var res = await db.query("Usuario", limit: 1);
//     return res.isNotEmpty ? Usuario.fromJson(res.first) : null ;
//   }
//
//   updateUsuario(Usuario usuario) async {
//     final db = await database;
//     var res = await db.update("Usuario", usuario.toJsonDB(),
//         where: "guidUsuario = ?", whereArgs: [usuario.guidUsuario]);
//     return res;
//   }
//
//   deleteUsuario() async {
//     final db = await database;
//     var res = await db.rawDelete("DELETE FROM Usuario");
//     return res;
//   }
//
// }

import 'package:abelhinha/model/usuario.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../service/database.dart';

class AdminPage extends StatefulWidget {

  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {

  Future<List<Usuario>?> getListaUsuarios() async {
    return await DBProvider.db.getAllUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder(
        future: getListaUsuarios(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print(snapshot.stackTrace);
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.data != null) {
            print("data not null");
            return listaUsuarios(snapshot.data);
          }
          return Text('Error: ${snapshot.error}');
        },
      ),
    );
  }

  Widget listaUsuarios(List<Usuario>? usuarios) {
    return ListView.builder(
      itemCount: usuarios!.length,
      itemBuilder: (context, index) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              usuarios[index].nome,
              style: const TextStyle(
                  fontSize: 18
              ),
            ),
          ],
        );
      },
    );
  }

}
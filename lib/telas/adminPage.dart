import 'dart:collection';
import 'dart:convert';

import 'package:abelhinha/model/usuario.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

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

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Usuários")
      ),
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
        return ExpansionTile(
          childrenPadding: const EdgeInsets.all(8),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                usuarios[index].nome,
                style: const TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              Text(
                "Último jogo: ${convertDateFormat(usuarios[index].pontuacaoData.entries.last.key)}",
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.white,
          children: [
            buildListaPontuacao(usuarios[index].pontuacaoData),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                usuarios[index].nome != "admin" ? ElevatedButton(
                  onPressed: () => editarNome(usuarios[index]),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text('Editar nome'),
                      SizedBox(width: 8.0),
                      Icon(Icons.edit),
                    ],
                  ),
                ) : const SizedBox(),
                ElevatedButton(
                  onPressed: () => editarSenha(usuarios[index]),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text('Resetar senha'),
                      SizedBox(width: 8.0),
                      Icon(Icons.lock),
                    ],
                  ),
                ),
              ],
            )
          ],
        );
      },
    );
  }

  Widget buildListaPontuacao(Map<String, dynamic> pontuacaoData) {
    pontuacaoData = reverseMapOrder(pontuacaoData);
    return SizedBox(
      height: (45 * pontuacaoData.length).ceilToDouble(),
      child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: pontuacaoData.length,
          itemBuilder: (context, index) {
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      convertDateFormat(pontuacaoData.entries.elementAt(index).key),
                      style: const TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      "${pontuacaoData.entries.elementAt(index).value.toString()} pontos",
                      style: const TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 10,),
              ],
            );
          }
      ),
    );
  }

  void editarNome(Usuario usuario) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Digite o novo nome de usuário'),
          content: TextField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: 'Nome de usuário',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await DBProvider.db.updateUsuarioNome(usuario, _usernameController.text);
                setState(() {
                  Navigator.pop(context);
                  _usernameController.text = "";
                });
              },
              child: const Text('Atualizar!'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  void editarSenha(Usuario usuario) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Digite a senha'),
          content: TextField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Senha',
              prefixIcon: const Icon(Icons.lock),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                var bytes = utf8.encode(_passwordController.text); // data being hashed

                var digest = sha1.convert(bytes);
                await DBProvider.db.updateUsuarioSenha(usuario, digest.toString());
                setState(() {
                  Navigator.pop(context);
                  _passwordController.text = "";
                });
              },
              child: const Text('Atualizar!'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  String convertDateFormat(String inputDate) {
    // Split the input date string by "-"
    List<String> parts = inputDate.split('-');

    // Extract year, month, and day from the parts
    String year = parts[0];
    String month = parts[1];
    String day = parts[2];

    // Create the formatted date string in the new format "dd-MM-yyyy"
    String formattedDate = '$day-$month-$year';

    return formattedDate;
  }

  Map<String, int> reverseMapOrder(Map<String, dynamic> originalMap) {
    // Create a LinkedHashMap to preserve insertion order
    LinkedHashMap<String, int> reversedMap = LinkedHashMap.from(originalMap);

    // Reverse the order of entries in the LinkedHashMap
    List<MapEntry<String, int>> entries = reversedMap.entries.toList();
    reversedMap.clear();

    for (int i = entries.length - 1; i >= 0; i--) {
      reversedMap[entries[i].key] = entries[i].value;
    }

    return reversedMap;
  }

}
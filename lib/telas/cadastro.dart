import 'dart:convert';

import 'package:abelhinha/service/database.dart';
import 'package:abelhinha/telas/login.dart';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';

import '../model/usuario.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController = TextEditingController();

  void _cadastrar() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();
    String passwordConfirmar = _passwordConfirmController.text.trim();

    if(passwordConfirmar != password) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Não foi possível continuar com o cadastro'),
            content: const Text('Senhas não coincidem'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    var bytes = utf8.encode(password); // data being hashed

    var digest = sha1.convert(bytes);

    Usuario usuario = Usuario(nome: username, senha: digest.toString(),
        pontuacaoDataJSON: '{"${getCurrentDate()}": 0}', logged: 0);
    DBProvider.db.novoUsuario(usuario);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
    return;

  }

  String getCurrentDate() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    return formattedDate;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/login.png',
              height: 150,
            ),
            const SizedBox(height: 30.0),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Nome de usuário',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Senha',
                prefixIcon: const Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: _passwordConfirmController,
              decoration: InputDecoration(
                labelText: 'Confirmar senha',
                prefixIcon: const Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 30.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _cadastrar,
                child: const Text('Cadastrar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

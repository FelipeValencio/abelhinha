import 'dart:convert';

import 'package:abelhinha/service/database.dart';
import 'package:abelhinha/telas/cadastro.dart';
import 'package:abelhinha/telas/jogo.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/usuario.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    Usuario? usuario = await DBProvider.db.getUsuarioByName(username);

    // Usuario existe e logar
    if(usuario != null) {
      var bytes = utf8.encode(password); // data being hashed
      var digest = sha1.convert(bytes);

      if(digest.toString() == usuario.senha) {
        usuario.logged = 1;
        DBProvider.db.updateUsuario(usuario);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Jogo(usuario: usuario)),
        );
        return;
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Não foi possível realizar o login'),
              content: const Text('Usuário não existe ou senha incorreta'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }

      return;
    }

    if(usuario == null) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Não foi possível realizar o login'),
            content: const Text('Usuário não existe ou senha incorreta'),
            actions: [
              TextButton(
                onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const CadastroPage()),
                ),
                child: const Text('Me cadastrar!'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tentar novamente'),
              ),
            ],
          );
        },
      );
      return;
    }
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
            const SizedBox(height: 30.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _login,
                child: const Text('Login'),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const CadastroPage())),
                child: const Text('Quero me cadastrar!'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

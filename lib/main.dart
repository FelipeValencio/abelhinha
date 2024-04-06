import 'package:abelhinha/model/usuario.dart';
import 'package:abelhinha/telas/login.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'service/bloc.dart';
import 'service/database.dart';
import 'telas/jogo.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    usuarioBloc.getUsuarioFromDB();
    return MaterialApp(
      title: 'Jogo da abelinha',
      debugShowCheckedModeBanner: false,
      color: Colors.amber,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black54),
        useMaterial3: true,
        splashFactory: NoSplash.splashFactory,
      ),
      home: StreamBuilder(
        stream: usuarioBloc.usuario,
        builder: (context, AsyncSnapshot<Usuario?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {

            return const Scaffold();

          } else {
            if (!snapshot.hasData) {
              return const LoginPage();
            } else {
              return Jogo(usuario: snapshot.data!);
            }

          }

        }
      ),
    );
  }
}


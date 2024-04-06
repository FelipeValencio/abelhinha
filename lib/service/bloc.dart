import 'package:rxdart/rxdart.dart';

import '../model/usuario.dart';
import 'database.dart';

class UsuarioBloc {

  final _usuarioFetcher = PublishSubject<Usuario?>();

  Stream<Usuario?> get usuario => _usuarioFetcher.stream;

  getUsuarioFromDB() async {

    Usuario? usuario = await DBProvider.db.getUsuarioLogged();

    _usuarioFetcher.sink.add(usuario);

  }

  dispose() {

    _usuarioFetcher.close();

  }

}

final usuarioBloc = UsuarioBloc();
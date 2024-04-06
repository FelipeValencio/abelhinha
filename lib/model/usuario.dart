import 'dart:convert';

class Usuario {
  late String nome;
  late String senha;
  late Map<String, dynamic> pontuacaoData;
  late String pontuacaoDataJSON;
  late int logged;

  Usuario({
    required this.nome,
    required this.senha,
    required this.pontuacaoDataJSON, required this.logged,
  }) {decodePontuacaoData(pontuacaoDataJSON);}

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      nome: json['nome'],
      senha: json['senha'],
      pontuacaoDataJSON: json['pontuacaoDataJSON'],
      logged: json['logged'],
    );
  }

  Map<String, dynamic> toJsonDB() {
    return {
      'nome': nome,
      'senha': senha,
      'pontuacaoDataJSON': encodePontuacaoData(),
      'logged': logged,
    };
  }

  String encodePontuacaoData() {
    return jsonEncode(pontuacaoData);
  }

  void decodePontuacaoData(String jsonData) {
    pontuacaoData = jsonDecode(jsonData);
  }
}

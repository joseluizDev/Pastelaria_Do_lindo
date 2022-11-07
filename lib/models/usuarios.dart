import 'package:map_fields/map_fields.dart';

class Usuarios {
  final String user;
  final String pass;
  final bool admin;
  final String? nome;
  Usuarios({
    required this.user,
    required this.pass,
    required this.admin,
    this.nome,
  });

  factory Usuarios.fromJson(Map<String, dynamic> json) {
    final mapFields = MapFields.load(json);
    return Usuarios(
      user: mapFields.getString('user'),
      pass: mapFields.getString('pass'),
      admin: mapFields.getBool('admin'),
      nome: mapFields.getString(
        'nome',
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user,
      'pass': pass,
      'admin': admin,
      'nome': nome,
    };
  }
}

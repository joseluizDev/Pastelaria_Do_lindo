import 'package:pastelaria/models/usuarios.dart';

class LoginData {
  LoginData._();
  static final _instance = LoginData._();
  factory LoginData() => _instance;

  Usuarios? usuario;

  void setUsuario(Usuarios usuario) {
    this.usuario = usuario;
  }

  Usuarios getUsuario() {
    return usuario!;
  }
}

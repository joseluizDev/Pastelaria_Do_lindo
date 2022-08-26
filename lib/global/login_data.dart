import 'package:pastelaria/models/usuarios.dart';

class LoginData {
  LoginData._();
  static final _instance = LoginData._();
  factory LoginData() => _instance;

  Usuarios? _user;

  Usuarios get user => _user!;

  bool get logged => _user != null;

  bool get isAdmin => _user?.admin ?? false;

  void setUser(Usuarios user) => _user = user;
}

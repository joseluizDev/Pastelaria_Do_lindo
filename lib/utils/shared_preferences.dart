import 'package:shared_preferences/shared_preferences.dart';

gravarisLogged(String login, String password) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('login', login);
  prefs.setString('password', password);
}

Future<List<String>> lerisLogged() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final login = prefs.getString('login');
  final password = prefs.getString('password');
  return [login ?? '', password ?? ''];
}

Future<int> contadorShared({bool condicao = false}) async {
  final DateTime now = DateTime.now();
  final String mes = now.month.toString();
  final String dia = now.day.toString();
  final String mesDia = mes + dia;

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final contador = prefs.getInt(mesDia) ?? 1;
  if (condicao) {
    prefs.setInt(mesDia, contador + 1);
  }
  return contador;
}

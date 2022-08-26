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

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

Future<int> contadorShared() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  int contador = prefs.getInt('contador') ?? 0;
  int data = prefs.getInt('data') ?? 0;

  if (data != DateTime.now().day) {
    await prefs.setInt('contador', 1);
    await prefs.setInt('data', DateTime.now().day);
    return 1;
  }

  contador++;
  await prefs.setInt('contador', contador);

  return contador;
}

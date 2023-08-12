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

<<<<<<< Updated upstream
Future<int> contadorShared({bool read = false}) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  int contador = prefs.getInt('contador') ?? 0;
  int data = prefs.getInt('data') ?? 0;

  if (data != DateTime.now().day) {
    await prefs.setInt('contador', 1);
    await prefs.setInt('data', DateTime.now().day);
    return 1;
  }

  contador++;
  if (read) return contador;
  await prefs.setInt('contador', contador);

  return contador;
=======
Future<int> countDay({bool save = false}) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  int count = prefs.getInt('count') ?? 0;
  int day = prefs.getInt('day') ?? 0;

  if (day != DateTime.now().day && day != 0) {
    prefs.setInt('day', DateTime.now().day);
    prefs.setInt('count', 0);
    count = 0;
  }

  count++;

  if (save) {
    prefs.setInt('count', count);
  }

  return count;
>>>>>>> Stashed changes
}

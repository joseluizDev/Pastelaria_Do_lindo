import 'package:flutter/material.dart';

import '../../components/text_field_custom.dart';
import '../../global/login_data.dart';
import '../../utils/shared_preferences.dart';
import '../admin/home_admin.dart';
import '../pedidos/pedidos_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final loginController = TextEditingController();
  final senhaController = TextEditingController();

  Future<void> login() async {}

  @override
  Widget build(BuildContext context) {
    lerisLogged().then((logged) async {
      loginController.text = logged[0];
      senhaController.text = logged[1];
      Future.delayed(const Duration(seconds: 1), () {
        login().then(
          (value) {
            if (LoginData().logged) {
              gravarisLogged(loginController.text, senhaController.text);
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => LoginData().isAdmin
                        ? const HomeAdmin()
                        : const PedidosPage(),
                  ),
                  (route) => false);
            } else {}
          },
        );
      });
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFieldCustom(
                label: 'Usuário',
                controller: loginController,
              ),
              TextFieldCustom(
                label: 'Senha',
                obscure: true,
                controller: senhaController,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                child: const SizedBox(
                  height: 50,
                  width: 120,
                  child: Center(
                    child: Text('Login'),
                  ),
                ),
                onPressed: () {
                  login().then(
                    (value) {
                      if (LoginData().logged) {
                        gravarisLogged(
                            loginController.text, senhaController.text);
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => LoginData().isAdmin
                                  ? const HomeAdmin()
                                  : const PedidosPage(),
                            ),
                            (route) => false);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Usuário ou senha inválidos'),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

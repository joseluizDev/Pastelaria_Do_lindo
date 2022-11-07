import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../components/text_field_custom.dart';
import '../../global/login_data.dart';
import '../../models/usuarios.dart';
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
  Future<void> login() async {
    final usuariosRef = await FirebaseFirestore.instance
        .collection('usuarios')
        .where('user', isEqualTo: loginController.text)
        .where('pass', isEqualTo: senhaController.text)
        .get();
    if (usuariosRef.docs.isNotEmpty) {
      final userData = usuariosRef.docs.first.data();
      final user = Usuarios.fromJson(userData);
      LoginData().setUsuario(user);
    }
  }

  @override
  Widget build(BuildContext context) {
    lerisLogged().then((logged) async {
      loginController.text = logged[0];
      senhaController.text = logged[1];
      Future.delayed(const Duration(seconds: 1), () {
        login().then(
          (value) {
            if (LoginData().getUsuario().user != null) {
              gravarisLogged(loginController.text, senhaController.text);
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => LoginData().getUsuario().admin
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
              const SizedBox(height: 20),
              ElevatedButton(
                child: const SizedBox(
                  height: 50,
                  width: 200,
                  child: Center(
                    child: Text('Login'),
                  ),
                ),
                onPressed: () {
                  login().then(
                    (value) {
                      if (LoginData().getUsuario().user != null) {
                        gravarisLogged(
                            loginController.text, senhaController.text);
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => LoginData().getUsuario().admin
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

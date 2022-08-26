// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pastelaria/components/text_field_custom.dart';
import 'package:pastelaria/models/usuarios.dart';

class UsuarioEditAdd extends StatefulWidget {
  final String? id;
  final Usuarios? user;
  const UsuarioEditAdd({
    Key? key,
    this.id,
    this.user,
  }) : super(key: key);

  @override
  State<UsuarioEditAdd> createState() => _UsuarioEditAddState();
}

class _UsuarioEditAddState extends State<UsuarioEditAdd> {
  final loginController = TextEditingController();
  final senhaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      loginController.text = widget.user?.user ?? '';
      senhaController.text = widget.user?.pass ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuário'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          TextFieldCustom(
            label: 'Usuário',
            controller: loginController,
          ),
          TextFieldCustom(
            label: 'Senha',
            obscure: true,
            controller: senhaController,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final Usuarios user = Usuarios(
            user: loginController.text,
            pass: senhaController.text,
            admin: false,
          );
          if (widget.id == null) {
            await FirebaseFirestore.instance
                .collection('usuarios')
                .add(user.toJson());
          } else {
            await FirebaseFirestore.instance
                .collection('usuarios')
                .doc(widget.id)
                .update(user.toJson());
          }
          Navigator.pop(context);
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}

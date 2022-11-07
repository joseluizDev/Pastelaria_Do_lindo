import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/usuarios.dart';
import 'usuario_edit_add.dart';

class UsuarioList extends StatelessWidget {
  const UsuarioList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuários'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('usuarios')
            .where('admin', isEqualTo: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar usuários'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final usuarios = snapshot.data?.docs ?? [];
          if (usuarios.isEmpty) {
            return const Center(child: Text('Nenhum usuário encontrado'));
          }
          return ListView.builder(
            itemCount: usuarios.length,
            itemBuilder: (_, index) {
              final usuarioData = usuarios[index];
              final usuario = Usuarios.fromJson(usuarioData.data());
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  child: ListTile(
                    title: Text("Nome:${usuario.nome}"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Login: ${usuario.user}'),
                        Text('Senha: ${usuario.pass}'),
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => UsuarioEditAdd(
                            id: usuarioData.id,
                            user: usuario,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('Adicionar'),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const UsuarioEditAdd()),
          );
        },
      ),
    );
  }
}

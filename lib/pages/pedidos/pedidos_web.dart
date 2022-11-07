import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/pedidos.dart';

class PedidosWeb extends StatelessWidget {
  const PedidosWeb({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('pedidos')
            .orderBy('data', descending: false)
            .where('finalizado', isEqualTo: 0)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Erro ao carregar pedidos'),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final pedidos = snapshot.data?.docs ?? [];
          if (pedidos.isEmpty) {
            return const Center(
              child: Text('Nenhum pedido em aberto!'),
            );
          }
          return Wrap(
            direction: Axis.horizontal,
            children: List.generate(
              pedidos.length,
              (index) {
                final pedidoData = pedidos[index];
                final pedido = Pedidos.fromJson(pedidoData.data());
                final titleList = [
                  pedido.cliente.trim().isEmpty
                      ? ''
                      : 'Cliente: ${pedido.cliente}',
                  pedido.mesa.trim().isEmpty ? '' : 'Mesa: ${pedido.mesa}',
                ];
                titleList.removeWhere((t) => t.trim().isEmpty);
                String title = titleList.join(' - ');
                title = title.trim().isEmpty ? 'Sem título' : title;
                final isPar = index % 2 == 0;
                return SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                  height: MediaQuery.of(context).size.height,
                  child: Card(
                    color: isPar
                        ? const Color.fromARGB(255, 255, 232, 199)
                        : const Color.fromARGB(255, 190, 226, 255),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            "Funcionario: ${pedido.funcionario}",
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          if (pedido.produtosAdicionais.isNotEmpty)
                            Text(
                              List.generate(
                                pedido.produtosAdicionais.length,
                                (i) {
                                  final pro = pedido.produtosAdicionais[i];
                                  return '${pro.qtde} x ${pro.nome}\n';
                                },
                              ).fold<String>(
                                '',
                                (previousValue, element) =>
                                    '$previousValue$element',
                              ),
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          const Divider(),
                          Text(
                            List.generate(
                              pedido.produtos.length,
                              (i) {
                                final pro = pedido.produtos[i];
                                return '${pro.qtde} x ${pro.nome}\n';
                              },
                            ).fold<String>(
                              '',
                              (previousValue, element) =>
                                  '$previousValue$element',
                            ),
                            style: TextStyle(
                              decoration: pedido.produtosAdicionais.isNotEmpty
                                  ? TextDecoration.lineThrough
                                  : null,
                              fontSize: 30,
                              decorationStyle: TextDecorationStyle.solid,
                              fontWeight: FontWeight.bold,
                              color: pedido.produtosAdicionais.isNotEmpty
                                  ? Colors.grey[800]
                                  : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

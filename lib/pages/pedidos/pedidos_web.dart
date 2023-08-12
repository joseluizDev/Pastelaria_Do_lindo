import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';

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
                return GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Pedido ${pedido.cliente}'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Numero do pedido: ${pedido.numeroPedido}'),
                              Text(
                                'Cliente: ${pedido.cliente.isNotEmpty ? pedido.cliente : 'Não definido'}',
                              ),
                              Text(
                                'Mesa: ${pedido.mesa.isNotEmpty ? pedido.mesa : 'Não definida'}',
                              ),
                              Text(
                                  'Pedido:${pedido.tipopedido?.index == 0 ? 'Não definido' : pedido.tipopedido?.index == 1 ? 'Delivery' : 'Local'}'),
                              Text(
                                  'Pagamento:${pedido.tipopagamento?.index == 0 ? 'Não definido' : pedido.tipopagamento?.index == 1 ? 'Dinheiro' : pedido.tipopagamento?.index == 2 ? 'Cartão' : 'Pix'}'),
                              Text(
                                  'Funcionário: ${pedido.funcionario ?? 'Não informado'}'),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text(
                                'Não finalizar',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                await FirebaseFirestore.instance
                                    .collection('pedidos')
                                    .doc(pedidoData.id)
                                    .update(
                                  {'finalizado': 1},
                                );
                                Navigator.of(context).pop();
                              },
                              child: const Text(
                                'Finalizar',
                                style: TextStyle(color: Colors.green),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width / 3,
                    height: MediaQuery.of(context).size.height,
                    child: Card(
                      color: isPar
                          ? const Color.fromARGB(255, 255, 242, 224)
                          : const Color.fromARGB(255, 190, 226, 255),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                color: Colors.black87,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  topRight: Radius.circular(8),
                                ),
                              ),
                              width: double.infinity,
                              alignment: Alignment.center,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Pedido: ${index + 1}",
                                  style: const TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 38,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              "Comprovante: ${pedido.numeroPedido}",
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              "Funcionario: ${pedido.funcionario}",
                              style: const TextStyle(
                                fontSize: 38,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              "Tipo: ${pedido.tipopedido?.index == 0 ? 'Não definido' : pedido.tipopedido?.index == 1 ? 'Delivery' : 'Local'}",
                              style: const TextStyle(
                                fontSize: 38,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            // Text(
                            //   "Tipo: ${pedido.tipopedido?.name == '' ? 'Não definido' : pedido.tipopedido!.name == 'delivery' ? 'Delivery' : 'Local'}",
                            //   style: const TextStyle(
                            //     fontSize: 40,
                            //     fontWeight: FontWeight.bold,
                            //     color: Colors.black87,
                            //   ),
                            // ),
                            if (pedido.produtosAdicionais.isNotEmpty) ...[
                              const Divider(),
                              GroupedListView<dynamic, String>(
                                elements: pedido.produtosAdicionais,
                                shrinkWrap: true,
                                groupBy: (element) => element.tipo,
                                groupSeparatorBuilder: (String tipo) =>
                                    Container(
                                  width: double.infinity,
                                  alignment: Alignment.center,
                                  child: Text(
                                    tipo,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 38,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                itemBuilder: (context, element) => Text(
                                  '${element.qtde} x ${element.nome}',
                                  style: const TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                order: GroupedListOrder.ASC,
                              ),
                            ],
                            const Divider(),
                            GroupedListView<dynamic, String>(
                              elements: pedido.produtos,
                              shrinkWrap: true,
                              groupBy: (element) =>
                                  element?.tipo ?? 'Sem categoria',
                              groupSeparatorBuilder: (String tipo) => Text(
                                tipo,
                                style: const TextStyle(
                                  fontSize: 38,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              itemBuilder: (context, element) => Row(
                                children: [
                                  Text(
                                    '${pedido.produtos.indexOf(element) + 1} x ${element.nome}',
                                    style: TextStyle(
                                      decoration:
                                          pedido.produtosAdicionais.isNotEmpty
                                              ? TextDecoration.lineThrough
                                              : null,
                                      fontSize: 30,
                                      decorationStyle:
                                          TextDecorationStyle.solid,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          pedido.produtosAdicionais.isNotEmpty
                                              ? Colors.grey[800]
                                              : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              order: GroupedListOrder.ASC,
                            ),
                          ],
                        ),
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

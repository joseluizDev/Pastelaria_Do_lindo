import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pastelaria/utils/extensions.dart';

import '../../global/login_data.dart';
import '../../models/pedidos.dart';
import 'adicionar_pedido_page.dart';

class PedidosPage extends StatefulWidget {
  const PedidosPage({Key? key}) : super(key: key);

  @override
  State<PedidosPage> createState() => _PedidosPageState();
}

class _PedidosPageState extends State<PedidosPage> {
  bool finalizados = false;

  void setFinalizados(bool value) {
    setState(() {
      finalizados = value;
    });
  }

  List<Pedidos> pedidosFiltrados = [];
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // verificarbeep();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Opacity(
                opacity: finalizados ? .6 : 1,
                child: ElevatedButton(
                  onPressed: () {
                    setFinalizados(false);
                  },
                  child: const SizedBox(
                    height: 42,
                    width: 120,
                    child: Center(
                      child: Text('Pedidos'),
                    ),
                  ),
                ),
              ),
              Opacity(
                opacity: finalizados ? 1 : .6,
                child: ElevatedButton(
                  onPressed: () {
                    setFinalizados(true);
                  },
                  child: const SizedBox(
                    height: 42,
                    width: 120,
                    child: Center(
                      child: Text('Vendas'),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 18),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('pedidos')
                  .orderBy('data', descending: false)
                  .where('finalizado', isEqualTo: finalizados ? 1 : 0)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Erro ao carregar pedidos'),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                List pedidos = (snapshot.data?.docs ?? [])
                    .where(
                      (p) =>
                          (p.data()['finalizado'] ?? 0) ==
                          (finalizados ? 1 : 0),
                    )
                    .where(
                      (p) =>
                          LoginData().getUsuario().admin ||
                          DateTime.parse(p.data()['data']).isAfter(
                              DateTime.now().subtract(const Duration(days: 1))),
                    )
                    .toList();

                if (pedidos.isEmpty) {
                  return Center(
                    child: Text(
                      finalizados
                          ? 'Nenhuma venda encontrada!'
                          : 'Nenhum pedido em aberto!',
                    ),
                  );
                }
                if (finalizados) {
                  pedidos = pedidos.reversed.toList();
                }
                // // se tiver pedidos em finalizados tocar o beep
                // if (finalizados && pedidosFiltrados.isEmpty) {
                //   FlutterBeep.beep();
                // }
                return ListView.builder(
                  itemCount: pedidos.length,
                  itemBuilder: (_, index) {
                    final pedidoData = pedidos[index];
                    final pedido = Pedidos.fromJson(pedidoData.data());
                    return GestureDetector(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Card(
                          child: ListTile(
                            title: Text(pedido.data.formatted),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text((pedido.total + pedido.totalAdicionais)
                                    .formatted),
                                Text(
                                    'Numero do pedido: ${pedido.numeroPedido}'),
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
                            trailing: Visibility(
                              visible: !finalizados,
                              child: IconButton(
                                onPressed: () {
                                  FirebaseFirestore.instance
                                      .collection('pedidos')
                                      .doc(pedidoData.id)
                                      .delete();
                                },
                                icon: const Icon(Icons.delete),
                              ),
                            ),
                          ),
                        ),
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) {
                            return AlertDialog(
                              title: Text(
                                  'Pedido $index \n${(pedido.total + pedido.totalAdicionais).formatted}'),
                              content: SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.5,
                                width: MediaQuery.of(context).size.width * 0.8,
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 8),
                                      ...List.generate(
                                        pedido.produtos.length,
                                        (index) {
                                          return ListTile(
                                            title: Text(
                                                pedido.produtos[index].nome),
                                            subtitle: Text(pedido
                                                .produtos[index]
                                                .unitario
                                                .formatted),
                                            trailing: Text(
                                                'X ${pedido.produtos[index].qtde.toInt()}'),
                                          );
                                        },
                                      ),
                                      if (pedido.produtosAdicionais.isNotEmpty)
                                        const Text(
                                          'Adicionais:',
                                          style: TextStyle(
                                            color: Colors.orange,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ...List.generate(
                                        pedido.produtosAdicionais.length,
                                        (index) {
                                          return ListTile(
                                            title: Text(pedido
                                                .produtosAdicionais[index]
                                                .nome),
                                            subtitle: Text(pedido
                                                .produtosAdicionais[index]
                                                .unitario
                                                .formatted),
                                            trailing: Text(
                                                'X ${pedido.produtosAdicionais[index].qtde.toInt()}'),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                  ),
                                ),
                              ),
                              actions: [
                                !finalizados
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          ElevatedButton(
                                            child:
                                                const Text('Finalizar pedido'),
                                            onPressed: () {
                                              final data = pedidoData.data();
                                              data['finalizado'] = 1;
                                              FirebaseFirestore.instance
                                                  .collection('pedidos')
                                                  .doc(pedidoData.id)
                                                  .update(data)
                                                  .then(
                                                    (value) =>
                                                        Navigator.of(ctx).pop(),
                                                  );
                                            },
                                          ),
                                          const Spacer(),
                                          if (pedido.produtosAdicionais.isEmpty)
                                            ElevatedButton(
                                              child:
                                                  const Text('Editar Pedido'),
                                              onPressed: () async {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) {
                                                      return AdicionarPedidoPage(
                                                        pedido: pedido,
                                                        pedidoData: pedidoData,
                                                        addnovo: false,
                                                        unir: false,
                                                      );
                                                    },
                                                  ),
                                                ).then((value) =>
                                                    Navigator.of(context)
                                                        .pop());
                                              },
                                            )
                                        ],
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          ElevatedButton(
                                            child: const Text('Pedido Pago'),
                                            onPressed: () {
                                              final data = pedidoData.data();
                                              data['finalizado'] = 2;
                                              FirebaseFirestore.instance
                                                  .collection('pedidos')
                                                  .doc(pedidoData.id)
                                                  .update(data)
                                                  .then(
                                                    (value) =>
                                                        Navigator.of(ctx).pop(),
                                                  );
                                            },
                                          ),
                                          const Spacer(),
                                          ElevatedButton(
                                            child:
                                                const Text('Adicionar Pedido'),
                                            onPressed: () async {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) {
                                                    return AdicionarPedidoPage(
                                                      pedido: pedido,
                                                      pedidoData: pedidoData,
                                                      addnovo: true,
                                                      unir: true,
                                                    );
                                                  },
                                                ),
                                              ).then((value) =>
                                                  Navigator.of(context).pop());
                                            },
                                          ),
                                        ],
                                      )
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (ctx) {
              return AdicionarPedidoPage();
            },
          );
        },
        label: const Text('Adicionar pedido'),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pastelaria/utils/extensions.dart';

import '../../models/pedidos.dart';

class VendasTotal extends StatefulWidget {
  const VendasTotal({Key? key}) : super(key: key);

  @override
  State<VendasTotal> createState() => _VendasTotalState();
}

class _VendasTotalState extends State<VendasTotal> {
  DateTime inicio = DateTime.now().start;

  DateTime fim = DateTime.now().end;
  String? pesquisaText;
  TextEditingController pesquisaController = TextEditingController();
  bool isPesquisa = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendas Total'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                pesquisaController.clear();
                isPesquisa = !isPesquisa;
              });
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: Column(
        children: [
          if (isPesquisa)
            Padding(
              padding: const EdgeInsets.only(left: 30.0, right: 10.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: pesquisaController,
                      onChanged: (value) {
                        setState(() {
                          pesquisaText = value;
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: 'Pesquisar',
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        pesquisaController.clear();
                        pesquisaText = null;
                        isPesquisa = !isPesquisa;
                      });
                    },
                    icon: const Icon(Icons.clear),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () async {
                  final value = await chooseDate(context, inicio);
                  if (value != null) {
                    setState(() => inicio = value.start);
                  }
                },
                child: Text('Inicio: ${inicio.dataFormatted}'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final value = await chooseDate(context, fim);
                  if (value != null) {
                    setState(() => fim = value.end);
                  }
                },
                child: Text('Final: ${fim.dataFormatted}'),
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('pedidos')
                  .orderBy('data', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Erro ao carregar vendas'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final vendas = snapshot.data?.docs ?? [];
                if (vendas.isEmpty) {
                  return const Center(child: Text('Nenhuma venda encontrada'));
                }
                final vendasFiltradas = vendas
                    .map((e) => Pedidos.fromJson(e.data()))
                    .where(
                        (p) => p.data.isAfter(inicio) && p.data.isBefore(fim))
                    .toList();
                final total = vendasFiltradas.fold<double>(
                    0.0, (total, e) => total + e.total);
                //pesauisa
                if (pesquisaText != null && pesquisaText!.isNotEmpty) {
                  final pesquisa = pesquisaText!.toLowerCase();
                  //pesquisa por nome dos vendasFiltradas.produtos
                  vendasFiltradas.retainWhere((element) {
                    final cliente = element.cliente.toLowerCase();
                    final produto = element.produtos
                        .map((e) => e.nome.toLowerCase())
                        .join(' ');
                    return cliente.contains(pesquisa) ||
                        produto.contains(pesquisa);
                  });
                }

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: vendasFiltradas.length,
                        itemBuilder: (_, index) {
                          final pedido = vendasFiltradas[index];
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Card(
                              child: ExpansionTile(
                                title: Text(pedido.cliente.isEmpty
                                    ? 'Nenhuma informação'
                                    : 'Cliente: ${pedido.cliente}'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        'Horario: ${pedido.data.dataFormatted}'),
                                    Text(
                                        'Pagemento: ${pedido.tipopagamento?.index == 0 ? 'Não definido' : pedido.tipopagamento?.index == 1 ? 'Dinheiro' : pedido.tipopagamento?.index == 2 ? 'Cartão' : 'Pix'}'),
                                    Text(
                                        'Tipo: ${pedido.tipopedido?.index == 0 ? 'Não definido' : pedido.tipopedido?.index == 1 ? 'Delivery' : 'Local'}'),
                                    Text(
                                        'Funcionario: ${pedido.funcionario ?? 'Não informado'}'),
                                  ],
                                ),
                                trailing: Text(pedido.total.formatted),
                                children: [
                                  Builder(builder: (context) {
                                    // for (final item in (pedido.produtos +
                                    // pedido.produtosAdicionais))
                                    final itens = pedido.produtos +
                                        pedido.produtosAdicionais;
                                    if (pesquisaText != null &&
                                        pesquisaText!.isNotEmpty) {
                                      final pesquisa =
                                          pesquisaText!.toLowerCase();
                                      itens.retainWhere((element) {
                                        final nome = element.nome.toLowerCase();
                                        return nome.contains(pesquisa);
                                      });
                                    }
                                    return Column(
                                        children: itens
                                            .map(
                                              (e) => ListTile(
                                                title: Text(e.nome),
                                                subtitle: Text('X: ${e.qtde}'),
                                                trailing:
                                                    Text(e.total.formatted),
                                              ),
                                            )
                                            .toList());
                                  }),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Builder(builder: (context) {
                      if (pesquisaText != null && pesquisaText!.isNotEmpty) {
                        //remover os itens que não foram encontrados
                        vendasFiltradas.retainWhere((element) {
                          final cliente = element.cliente.toLowerCase();
                          final produto = element.produtos
                              .map((e) => e.nome.toLowerCase())
                              .join(' ');
                          return cliente.contains(pesquisaText!) ||
                              produto.contains(pesquisaText!);
                        });
                        //remover os produtos que não foram encontrados
                        for (final pedido in vendasFiltradas) {
                          pedido.produtos.retainWhere((element) {
                            final nome = element.nome.toLowerCase();
                            return nome.contains(pesquisaText!);
                          });
                          pedido.produtosAdicionais.retainWhere((element) {
                            final nome = element.nome.toLowerCase();
                            return nome.contains(pesquisaText!);
                          });
                        }

                        return Text(
                          'Total: ${vendasFiltradas.fold<double>(0.0, (total, e) => total + e.total).formatted}',
                          style: Theme.of(context).textTheme.headline6,
                        );
                      }

                      return Text(
                        'Total: ${total.formatted}',
                        style: Theme.of(context).textTheme.headline6,
                      );
                    }),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

Future<DateTime?> chooseDate(BuildContext context, DateTime initial) {
  return showDatePicker(
    context: context,
    initialDate: initial,
    firstDate: DateTime(2000),
    lastDate: DateTime.now().start.add(const Duration(days: 30)),
  );
}

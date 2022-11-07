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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendas Total'),
      ),
      body: Column(
        children: [
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
              stream:
                  FirebaseFirestore.instance.collection('pedidos').snapshots(),
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
                              child: ListTile(
                                title: Text(pedido.cliente.isEmpty
                                    ? 'Nenhuma informação'
                                    : 'Cliente: ${pedido.cliente}'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        'Horario: ${pedido.data.dataFormatted}'),
                                    Text(
                                        "Funcionario: ${pedido.funcionario ?? 'Não informado'}"),
                                  ],
                                ),
                                trailing: Text(pedido.total.formatted),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total: ${total.formatted}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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

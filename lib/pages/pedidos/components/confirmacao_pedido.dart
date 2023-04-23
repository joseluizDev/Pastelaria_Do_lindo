import 'package:flutter/material.dart';
import 'package:pastelaria/utils/extensions.dart';

import '../../../models/enum_pagamento.dart';
import '../../../models/produtos.dart';
import 'diveder_custom.dart';
import 'informacoes_pedido.dart';

class ConfirmacaoPedido extends StatefulWidget {
  final String cliente;
  final List<Produto> produtos;
  final double valorTotal;
  final TipoPagamento pagamento;
  final int numeroPedido;
  final String localEntrega;

  const ConfirmacaoPedido({
    super.key,
    required this.cliente,
    required this.localEntrega,
    required this.produtos,
    required this.valorTotal,
    required this.pagamento,
    required this.numeroPedido,
  });

  @override
  State<ConfirmacaoPedido> createState() => _ConfirmacaoPedidoState();
}

class _ConfirmacaoPedidoState extends State<ConfirmacaoPedido> {
  final String data = DateTime.now().toString().substring(0, 10);
  final String hora = DateTime.now().toString().substring(11, 16);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 25,
                vertical: 20,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.black,
                    width: 2,
                  ),
                ),
                padding: const EdgeInsets.only(
                  left: 15,
                  right: 15,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(
                        top: 15,
                      ),
                      child: Text(
                        'Comprovante',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Image.asset(
                      'assets/iconp.png',
                      height: 100,
                      width: 100,
                      color: Colors.black87,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(
                        left: 15,
                        right: 15,
                      ),
                      child: DividerCustom(),
                    ),
                    TituloComprovante(
                      hora: hora,
                      cliente: widget.cliente,
                      localEntrega: widget.localEntrega,
                      numeroPedido: '',
                      data: data,
                      pagamento: widget.pagamento,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(
                        left: 15,
                        right: 15,
                      ),
                      child: DividerCustom(),
                    ),
                    Builder(
                      builder: (context) {
                        // adicionar so um produto sem repetir

                        final produtosUnicos = widget.produtos.toSet().toList();
                        return Column(
                          children: [
                            ...List.generate(
                              produtosUnicos.length,
                              (index) {
                                final produto = produtosUnicos[index];
                                final quantidade = widget.produtos
                                    .where((element) =>
                                        element.nome == produto.nome)
                                    .length;
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 15,
                                        right: 15,
                                        top: 2,
                                        bottom: 2,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '$quantidade X  ',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            produto.nome,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            (produto.unitario * quantidade)
                                                .formatted,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (index == produtosUnicos.length - 1) ...[
                                      const Padding(
                                        padding: EdgeInsets.only(
                                          left: 15,
                                          right: 15,
                                        ),
                                        child: DividerCustom(),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Row(
                                        children: [
                                          const SizedBox(
                                            width: 15,
                                          ),
                                          Text(
                                            'Total: ${widget.valorTotal.formatted}',
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Center(
                                        child: Container(
                                          padding: const EdgeInsets.only(
                                            left: 15,
                                            right: 15,
                                            top: 5,
                                            bottom: 5,
                                          ),
                                          color: Colors.black,
                                          child: Text(
                                            widget.numeroPedido.toString(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                    ]
                                  ],
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.black,
                  width: 2,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

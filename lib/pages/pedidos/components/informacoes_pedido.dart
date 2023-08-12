import 'package:flutter/material.dart';

import '../../../models/enum_pagamento.dart';

class TituloComprovante extends StatelessWidget {
  final String numeroPedido;
  final String cliente;
  final String data;
  final String hora;
  final TipoPagamento pagamento;

  const TituloComprovante({
    super.key,
    required this.numeroPedido,
    required this.cliente,
    required this.data,
    required this.hora,
    required this.pagamento,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 15,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cliente: ${cliente.isEmpty ? 'Nao Definido' : cliente}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                Text(
                  'Horario: $hora  $data',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text(
              'Pagamento: ${TipoPagamento.values[pagamento.index] == TipoPagamento.naoDefinido ? 'Nao Definido' : TipoPagamento.cartao == TipoPagamento.values[pagamento.index] ? 'Cartao' : TipoPagamento.dinherio == TipoPagamento.values[pagamento.index] ? 'Dinheiro' : 'Pix'}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

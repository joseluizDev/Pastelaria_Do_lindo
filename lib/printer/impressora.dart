import 'dart:io';

import 'package:elgin/elgin.dart';
import 'package:flutter/services.dart';
import 'package:pastelaria/utils/extensions.dart';
import 'package:path_provider/path_provider.dart';

import '../models/enum_pagamento.dart';
import '../models/produtos.dart';

Future<void> comproventePrinter(
  final String? cliente,
  final List<Produto> produtos,
  final double valorTotal,
  final int pagamento,
  final String numeroPedido,
) async {
  final driver = ElginPrinter(type: ElginPrinterType.MINIPDV);
  final currentTime = DateTime.now();
  try {
    final int? result = await Elgin.printer.connect(driver: driver);

    if (result != null) {
      if (result == 0) {
        await Elgin.printer.printString('COMPROVANTE DE VENDA',
            align: ElginAlign.CENTER, fontSize: ElginSize.MD, isBold: true);

        Uint8List byte = await _getImageFromAsset('assets/logo_pdf.png');
        Directory tempPath = await getTemporaryDirectory();
        File file = File('${tempPath.path}/dash.png');
        await file.writeAsBytes(byte);
        await file.writeAsBytes(
            byte.buffer.asUint8List(byte.offsetInBytes, byte.lengthInBytes));
        await Elgin.printer.printImage(file, false);

        await Elgin.printer.printString('-----------------------------',
            align: ElginAlign.CENTER, fontSize: ElginSize.MD);
        await Elgin.printer.feed(1);
        await Elgin.printer.printString(
            'HORÁRIO:${currentTime.hour}:${currentTime.minute.toString().length == 1 ? 0 : ''}${currentTime.minute}:${currentTime.second}',
            align: ElginAlign.LEFT,
            fontSize: ElginSize.MD);
        await Elgin.printer.printString(
            'CLIENTE: ${cliente?.toLowerCase() ?? 'CONSUMIDOR'}',
            align: ElginAlign.LEFT,
            fontSize: ElginSize.MD);
        await Elgin.printer.printString(
          'FORMA DE PAGAMENTO: ${TipoPagamento.values[pagamento] == TipoPagamento.dinherio ? 'DINHEIRO' : TipoPagamento.values[pagamento] == TipoPagamento.cartao ? 'CARTÃO' : TipoPagamento.values[pagamento] == TipoPagamento.pix ? 'Pix' : 'OUTROS'}',
        );
        await Elgin.printer.printString('-----------------------------',
            align: ElginAlign.CENTER, fontSize: ElginSize.MD);

        produtos.map((produto) {
          return Elgin.printer.printString(
              //'${qauntidade} X ${nome} ${valor}',
              '${produtos.indexOf(produto)} X ${produto.nome.toUpperCase()} ${produto.unitario.formatted}',
              align: ElginAlign.LEFT,
              fontSize: ElginSize.MD);
        }).toList();
        await Elgin.printer.printString('-----------------------------',
            align: ElginAlign.CENTER, fontSize: ElginSize.MD);

        await Elgin.printer.printString('TOTAL: ${valorTotal.formatted}');
        await Elgin.printer.printString(numeroPedido,
            align: ElginAlign.CENTER, fontSize: ElginSize.MD);
        await Elgin.printer.feed(1);
        await Elgin.printer.cut();
        await Elgin.printer.disconnect();
      } else {
        print('Erro ao conectar a impressora');
      }
    }
  } on PlatformException catch (e) {
    print(e);
  }
}

Future<Uint8List> readFileBytes(String path) async {
  ByteData fileData = await rootBundle.load(path);
  Uint8List fileUnit8List = fileData.buffer
      .asUint8List(fileData.offsetInBytes, fileData.lengthInBytes);
  return fileUnit8List;
}

Future<Uint8List> _getImageFromAsset(String iconPath) async {
  return await readFileBytes(iconPath);
}

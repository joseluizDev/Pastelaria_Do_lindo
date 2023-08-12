import 'dart:io';

import 'package:elgin/elgin.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../models/enum_pagamento.dart';
import '../models/produtos.dart';

Future<void> comproventePrint(
  String? cliente,
  List<Produto> produtos,
  double valorTotal,
  TipoPagamento pagamento,
  String numeroPedido,
  String localDaEntrega,
) async {
  final pedidosUnicos = produtos.toSet().toList();

  final currentTime = DateTime.now();
  final driver = ElginPrinter(type: ElginPrinterType.MINIPDV);
  try {
    final int? result = await Elgin.printer.connect(driver: driver);

    if (result != null) {
      if (result == 0) {
        await Elgin.printer.printString('COMPROVANTE DE VENDA',
            align: ElginAlign.CENTER, fontSize: ElginSize.MD, isBold: true);

        Uint8List byte = await _getImageFromAsset('assets/iconp.png');
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

        //se local da entrega for diferente de vazio, imprime o local da entrega

        await Elgin.printer.printString(
            'CLIENTE: ${cliente ?? 'NÃO INFORMADO'}'.toUpperCase(),
            align: ElginAlign.LEFT,
            fontSize: ElginSize.MD);
        if (localDaEntrega != '') {
          await Elgin.printer.printString(
              'LOCAL DA ENTREGA: $localDaEntrega'.toUpperCase(),
              align: ElginAlign.LEFT,
              fontSize: ElginSize.MD);
        }
        await Elgin.printer.printString(
          'FORMA DE PAGAMENTO: ${pagamento.index == 0 ? 'Não definido' : pagamento.index == 1 ? 'Dinheiro' : pagamento.index == 2 ? 'Cartão' : 'Pix'}',
        );
        await Elgin.printer.printString('-----------------------------',
            align: ElginAlign.LEFT, fontSize: ElginSize.MD);
        pedidosUnicos.map((produto) {
          final qtd = produtos.where((element) => element == produto).length;
          return Elgin.printer.printString(
              //'${produto.qtde} X ${produto.tipo.length} ${produto.tipo}  ${produto.nome}',
              '$qtd X ${produto.tipo}  ${produto.nome}',
              align: ElginAlign.LEFT,
              fontSize: ElginSize.MD);
        }).toList();
        await Elgin.printer.printString('-----------------------------',
            align: ElginAlign.CENTER, fontSize: ElginSize.MD);

        await Elgin.printer.printString('TOTAL: R\$ $valorTotal',
            align: ElginAlign.LEFT, fontSize: ElginSize.MD);
        await Elgin.printer.printString('-----------------------------',
            align: ElginAlign.CENTER, fontSize: ElginSize.MD);

        Uint8List byte2 = await _getImageFromAsset('assets/qrcode.png');
        Directory tempPath2 = await getTemporaryDirectory();
        File file2 = File('${tempPath2.path}/dash.png');
        await file2.writeAsBytes(byte2);
        await file2.writeAsBytes(
            byte2.buffer.asUint8List(byte2.offsetInBytes, byte2.lengthInBytes));
        await Elgin.printer.printImage(file2, false);

        await Elgin.printer.printString('Obrigado pela preferência❤️!',
            align: ElginAlign.CENTER, fontSize: ElginSize.MD);
        await Elgin.printer.cut(lines: 5);

        await Elgin.printer.disconnect();
      }
    }
  } on ElginException {
    print('Erro ao imprimir');
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

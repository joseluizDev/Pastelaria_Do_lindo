import 'dart:io';

import 'package:elgin/elgin.dart';
import 'package:flutter/services.dart';
<<<<<<< Updated upstream
import 'package:pastelaria/utils/extensions.dart';
=======
>>>>>>> Stashed changes
import 'package:path_provider/path_provider.dart';

import '../models/enum_pagamento.dart';
import '../models/produtos.dart';

<<<<<<< Updated upstream
Future<void> comproventePrinter(
  final String? cliente,
  final List<Produto> produtos,
  final double valorTotal,
  final int pagamento,
  final String numeroPedido,
) async {
  final driver = ElginPrinter(type: ElginPrinterType.MINIPDV);
  final currentTime = DateTime.now();
=======
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
>>>>>>> Stashed changes
  try {
    final int? result = await Elgin.printer.connect(driver: driver);

    if (result != null) {
      if (result == 0) {
        await Elgin.printer.printString('COMPROVANTE DE VENDA',
            align: ElginAlign.CENTER, fontSize: ElginSize.MD, isBold: true);

<<<<<<< Updated upstream
        Uint8List byte = await _getImageFromAsset('assets/logo_pdf.png');
=======
        Uint8List byte = await _getImageFromAsset('assets/iconp.png');
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
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
=======

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
>>>>>>> Stashed changes
              align: ElginAlign.LEFT,
              fontSize: ElginSize.MD);
        }).toList();
        await Elgin.printer.printString('-----------------------------',
            align: ElginAlign.CENTER, fontSize: ElginSize.MD);

<<<<<<< Updated upstream
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
=======
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
>>>>>>> Stashed changes
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

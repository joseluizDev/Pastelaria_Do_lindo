import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_scan_bluetooth/flutter_scan_bluetooth.dart';
import 'package:image/image.dart' as img;
import 'package:pastelaria/utils/extensions.dart';

import '../../../models/enum_pagamento.dart';
import '../../../models/produtos.dart';
import '../../../printer/impressora.dart';
import 'diveder_custom.dart';
import 'informacoes_pedido.dart';

class ConfirmacaoPedido extends StatefulWidget {
  final String? cliente;
  final List<Produto> produtos;
  final double valorTotal;
  final TipoPagamento pagamento;
  final String numeroPedido;
  final String localDaEntrega;
  @override
  const ConfirmacaoPedido({
    super.key,
    this.cliente,
    required this.produtos,
    required this.valorTotal,
    required this.pagamento,
    required this.numeroPedido,
    required this.localDaEntrega,
  });

  @override
  State<ConfirmacaoPedido> createState() => _ConfirmacaoPedidoState();
}

class _ConfirmacaoPedidoState extends State<ConfirmacaoPedido> {
  final String datahorario = DateTime.now().toString().substring(0, 10);
  final String hora = DateTime.now().toString().substring(11, 16);
  var thumbnail;
  ByteData? logoBytes;
  bool pdv = true;
  final FlutterScanBluetooth _bluetooth = FlutterScanBluetooth();
  PrinterBluetoothManager printerManager = PrinterBluetoothManager();
  List<PrinterBluetooth> _devices = [];

  init() async {
    final ByteData data = await rootBundle.load('assets/iconp.png');
    final Uint8List bytesImage = data.buffer.asUint8List();
    final image = img.decodeImage(bytesImage)!;
    thumbnail = img.copyResize(image, width: 100);
  }

  @override
  void initState() {
    super.initState();
    init();
    _bluetooth.startScan(pairedDevices: true);
    printerManager.scanResults.listen((devices) async {
      setState(() {
        _devices = devices;
      });
    });
    _bluetooth.stopScan();
    _startScanDevices();
  }

  void _startScanDevices() {
    setState(() {
      _devices = [];
    });
    printerManager.startScan(const Duration(seconds: 4));
  }

  Future<List<int>> demoReceipt(
      PaperSize paper, CapabilityProfile profile) async {
    final Generator ticket = Generator(paper, profile);
    List<int> bytes = [];
    //imagem
    bytes += ticket.beep();

    bytes += ticket.text(
      "COMPROVANTE",
      styles: const PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );

    bytes += ticket.image(thumbnail);
    bytes += ticket.hr();

    final client = widget.cliente == '' ? 'Nao definido' : widget.cliente!;
    bytes += ticket.text(
      "Cliente:" + client,
      styles: const PosStyles(
        align: PosAlign.left,
        height: PosTextSize.size1,
        width: PosTextSize.size1,
      ),
    );

    bytes += ticket.text(
      "Data:" + datahorario + " " + hora,
      styles: const PosStyles(
        align: PosAlign.left,
        height: PosTextSize.size1,
        width: PosTextSize.size1,
      ),
    );

    final pagamento = widget.pagamento.index == 0
        ? 'Nao definido'
        : widget.pagamento.index == 1
            ? 'Dinheiro'
            : widget.pagamento.index == 2
                ? 'Cartao'
                : 'Pix';
    bytes += ticket.text(
      "Pagamento: $pagamento",
      styles: const PosStyles(
        align: PosAlign.left,
        height: PosTextSize.size1,
        width: PosTextSize.size1,
      ),
    );

    if (widget.localDaEntrega != '') {
      bytes += ticket.text(
        "Endereco: " + widget.localDaEntrega,
        styles: const PosStyles(
          align: PosAlign.left,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ),
      );
    }

    bytes += ticket.hr();


    // List<Produto> produtosUnicos = widget.produtos.toSet().toList();
    List<Produto> produtosUnicos = [];
    for (var p = 0; p < widget.produtos.length; p++) {
      if (produtosUnicos == null) {
        produtosUnicos = [];
      }
      if (produtosUnicos
          .where((element) =>
              element.nome == widget.produtos[p].nome &&
              element.adicionais.hashCode ==
                  widget.produtos[p].adicionais.hashCode)
          .isEmpty) {
        produtosUnicos.add(widget.produtos[p]);
      }
    }

    for (var produtoUnico in produtosUnicos) {
      final nome = produtoUnico.nome;
      final qtd = widget.produtos
          .where((element) =>
              element.nome == produtoUnico.nome &&
              element.adicionais.hashCode == produtoUnico.adicionais.hashCode)
          .length;
      final valor = produtoUnico.unitario;
      bytes += ticket.row([
        PosColumn(
          text: qtd.toString() + 'x',
          width: 1,
          styles: const PosStyles(
            align: PosAlign.right,
          ),
        ),
        PosColumn(
          text: nome,
          width: 8,
          styles: const PosStyles(
            align: PosAlign.center,
          ),
        ),
        PosColumn(
          text: (qtd * valor).formatted,
          width: 3,
          styles: const PosStyles(
            align: PosAlign.right,
          ),
        ),
      ]);

      if (produtoUnico.adicionais != null) {
        Map<String, int> qtdAdicionais = {};
        for (var adicional in produtoUnico.adicionais!) {
          qtdAdicionais.update(adicional.nome, (value) => value + 1,
              ifAbsent: () => 1);
        }
        for (var adicional in produtoUnico.adicionais!.toSet().toList()) {
          final nomeAdicional = adicional.nome;
          final qtdAdicional = qtdAdicionais[nomeAdicional] ?? 0;
          final valorAdicional = adicional.unitario;
          bytes += ticket.row([
            PosColumn(
              text: qtdAdicional.toString() + 'x',
              width: 1,
              styles: const PosStyles(
                align: PosAlign.right,
              ),
            ),
            PosColumn(
              text: nomeAdicional,
              width: 8,
              styles: const PosStyles(
                align: PosAlign.center,
              ),
            ),
            PosColumn(
              text: valorAdicional.formatted,
              width: 3,
              styles: const PosStyles(
                align: PosAlign.right,
              ),
            ),
          ]);
        }
      }
    }


    bytes += ticket.hr();

    bytes += ticket.row([
      PosColumn(
        text: 'Total',
        width: 8,
        styles: const PosStyles(
          align: PosAlign.right,
        ),
      ),
      PosColumn(
        text: widget.valorTotal.formatted,
        width: 4,
        styles: const PosStyles(
          align: PosAlign.right,
        ),
      ),
    ]);
    bytes += ticket.text(
      widget.numeroPedido,
      styles: const PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
    bytes += ticket.hr(ch: ' ', linesAfter: 2);
    bytes += ticket.feed(2);

    return bytes;
  }

  void _testPrint(PrinterBluetooth printer) async {
    try {
      printerManager.selectPrinter(printer);
      const PaperSize paper = PaperSize.mm58;
      final profile = await CapabilityProfile.load();
      final impressao = await demoReceipt(paper, profile);
      await printerManager.printTicket(impressao);
    } catch (e) {
      print("erro$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black87, width: 2),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
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
                    cliente: widget.cliente ?? '',
                    numeroPedido: '',
                    data: datahorario,
                    pagamento: widget.pagamento,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(
                      left: 15,
                      right: 15,
                    ),
                    child: DividerCustom(),
                  ),
                  Builder(builder: (context) {
                    List<Produto> produtosWidget = widget.produtos;
                    List<Produto> produtosUnicos = [];
    
                    for (var p = 0; p < produtosWidget.length; p++) {
                      if (produtosUnicos == null) {
                        produtosUnicos = [];
                      }
                      if (produtosUnicos
                          .where((element) =>
                              element.nome == produtosWidget[p].nome &&
                              element.adicionais.hashCode ==
                                  produtosWidget[p].adicionais.hashCode)
                          .isEmpty) {
                        produtosUnicos.add(produtosWidget[p]);
                      }
                    }
                    return ListView.builder(
                      itemCount: produtosUnicos.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (_, index) {
                        final produto = produtosUnicos[index];
                        final quantidade = produtosWidget
                            .where((element) =>
                                element.nome == produto.nome &&
                                element.adicionais.hashCode ==
                                    produto.adicionais.hashCode)
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
                                    (produto.unitario * quantidade).formatted,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (produto.adicionais != null)
                              ...List.generate(
                                  produto.adicionais!.length,
                                  (index) => Padding(
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
                                              '1 X  ',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              produto.adicionais![index].nome,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              (produto.adicionais![index]
                                                          .unitario *
                                                      1)
                                                  .formatted,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
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
                                    widget.numeroPedido,
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
                    );
                  }),
                ],
              ),
            ),
          ),
          StreamBuilder<bool>(
            stream: printerManager.isScanningStream,
    
            initialData: false,
            builder: (c, snapshot) {
              if (snapshot.data!) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (_devices.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () async {
                        comproventePrint(
                          widget.cliente,
                          widget.produtos,
                          widget.valorTotal,
                          widget.pagamento,
                          widget.numeroPedido,
                          widget.localDaEntrega,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: const Text('Imprimir PDV'),
                      ),
                    ),
                  ),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _devices.length,
                itemBuilder: (BuildContext context, int index) {
                  if (_devices[index].name != 'KP-1025') {
                    return const SizedBox();
                  }
                  return InkWell(
                    onTap: () async {
                      _testPrint(_devices[index]);
                    },
                    child: Card(
                      child: Container(
                        height: 60,
                        padding: const EdgeInsets.only(left: 10),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: <Widget>[
                            const Icon(Icons.print),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(_devices[index].name ?? ''),
                                Text(_devices[index].address!),
                                Text(
                                  'Clique para imprimir',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
